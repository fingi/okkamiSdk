package com.okkami.okkamisdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.fasterxml.jackson.databind.JsonNode;
import com.linecorp.linesdk.auth.LineLoginApi;
import com.linecorp.linesdk.auth.LineLoginResult;
import com.okkami.android.sdk.SDK;
import com.okkami.android.sdk.config.MockConfigModule;
import com.okkami.android.sdk.domain.legacy.NonceManagerModule;
import com.okkami.android.sdk.domain.legacy.NumberFormatterModule;
import com.okkami.android.sdk.domain.response.ConnectResponse;
import com.okkami.android.sdk.domain.response.PreConnectResponse;
import com.okkami.android.sdk.helper.CommonUtil;
import com.okkami.android.sdk.hub.Command;
import com.okkami.android.sdk.hub.CommandFactoryModule;
import com.okkami.android.sdk.hub.CommandSerializerModule;
import com.okkami.android.sdk.hub.OnHubCommandReceivedListener;
import com.okkami.android.sdk.model.BaseAuthentication;
import com.okkami.android.sdk.model.CompanyAuth;
import com.okkami.android.sdk.model.DeviceAuth;
import com.okkami.android.sdk.module.HubModule;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URL;
import java.security.InvalidKeyException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.smooch.core.InitializationStatus;
import io.smooch.core.Message;
import io.smooch.core.Settings;
import io.smooch.core.Smooch;
import io.smooch.core.SmoochConnectionStatus;
import io.smooch.core.User;
import io.smooch.ui.ConversationActivity;
import okhttp3.ResponseBody;
import retrofit2.Response;

class OkkamiSdkModule extends ReactContextBaseJavaModule implements OnHubCommandReceivedListener{
    private Application app;
    private Context context;
    private static final String TAG = "OKKAMISDK";
    private static final int LINE_LOGIN_REQUEST_CODE = 10;
    private SDK okkamiSdk;
    private Promise lineLoginPromise = null;
    private MockConfigModule mock;
    private DeviceAuth mDeviceAuth;
    private static HubModule hubModule;
    private final NonceManagerModule nonce = new NonceManagerModule();
    private final CommandSerializerModule cmdSerializer = new CommandSerializerModule();
    private final NumberFormatterModule numberFormatter = new NumberFormatterModule();
    private CommandFactoryModule mCmdFactory;


    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode,
                Intent data) {
            super.onActivityResult(activity, requestCode, resultCode, data);
            Log.d(TAG, "onActivityResult: "+requestCode);
            if (requestCode != LINE_LOGIN_REQUEST_CODE) return;
            LineLoginResult result;
            String accessToken;
            try {
                result = LineLoginApi.getLoginResultFromIntent(data);
                accessToken = result.getLineCredential().getAccessToken().getAccessToken();
            } catch (Exception e) {
                e.printStackTrace();
                lineLoginPromise.reject("error", e.getMessage());
                return;
            }

            switch (result.getResponseCode()) {

                case SUCCESS:
                    // Login is successful
                    // Do something...
                    JSONObject jObj = new JSONObject();
                    try {
                        String picUrl;
                        if (result.getLineProfile() != null && result.getLineProfile().getPictureUrl() != null){
                            picUrl = result.getLineProfile().getPictureUrl().toString();
                        } else {
                            picUrl = "";
                        }
                        jObj.put("accessToken", accessToken);
                        jObj.put("user_id", result.getLineProfile().getUserId());
                        jObj.put("display_name", result.getLineProfile().getDisplayName());
                        jObj.put("picture", picUrl);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        lineLoginPromise.reject("error", e.getMessage());
                    }

                    lineLoginPromise.resolve(jObj.toString());
                    break;
                case CANCEL:
                    // Login was cancelled by the user
                    // Do something...
                    lineLoginPromise.reject("error", "error");
                    break;
                default:
                    // Login was cancelled by the user
                    // Do something...
            }
        }

    };

    public OkkamiSdkModule(ReactApplicationContext reactContext, Application app) {
        super(reactContext);
        this.context = reactContext;
        Log.d(TAG, "OkkamiSdkModule: "+app);
        reactContext.addActivityEventListener(mActivityEventListener);
        okkamiSdk = new SDK().init(reactContext, "https://app.develop.okkami.com"); // TODO : how do we pass the URL dynamically from react??
        initMockData();
        this.app = app;
    }

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from javascript.
     */
    @Override
    public String getName() {
        return "OkkamiSdk";
    }


     /*-------------------------------------- Utility   --------------------------------------------------*/

    // have a connection to any network
    public boolean isNetworkConnected() {
        ConnectivityManager cm =
                (ConnectivityManager) this.context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo netInfo = cm.getActiveNetworkInfo();
        return netInfo != null && netInfo.isConnectedOrConnecting();
    }

    // have an internet access
    public boolean isOnline() {
        Runtime runtime = Runtime.getRuntime();
        try {
            Process ipProcess = runtime.exec("/system/bin/ping -c 1 8.8.8.8");
            int     exitValue = ipProcess.waitFor();
            return (exitValue == 0);
        }
        catch (IOException e)          { e.printStackTrace(); }
        catch (InterruptedException e) { e.printStackTrace(); }

        return false;
    }

    @ReactMethod
    public void lineLogin(Promise lineLoginPromise) {
        if (!isNetworkConnected()) {
            lineLoginPromise.reject("error", "have no network connected.");
            return;
        } else if (!isOnline()) {
            lineLoginPromise.reject("error", "have no internet connection");
            return;
        }
        this.lineLoginPromise = lineLoginPromise;
        Intent loginIntent = LineLoginApi.getLoginIntent(this.context, "1508019538");
        getCurrentActivity().startActivityForResult(loginIntent, LINE_LOGIN_REQUEST_CODE);
    }


    //NOTE: commented out by KHAN. it seems the following methods dont exist in ios and also not being called from js anywhere?
    //      also causing compilation to fail on android because SDK does not have them .

//    /**
//     * Set new the Smooch app token to Okkami SDK for switching channel to let user talk to different hotels
//     * @param appToken - an app token provided by Smooch
//     */
//    @ReactMethod
//     public void setSmoochAppToken(String appToken){
//        okkamiSdk.setSmoochAppToken(appToken);
//     }
//
//     @ReactMethod
//     public void showSmoochUI(){
//         okkamiSdk.showSmoochUI();
//     }


     /*---------------------------Core------------------------------------------------------------------------*/

    /**
     * The purpose of this method is to provide general purpose way to call any core endpoint.
     * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
     * <p>
     * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
     * on failure:  downloadFromCorePromise.reject(Throwable e)
     *
     * @param endPoint full core url . https://api.fingi.com/devices/v1/register
     * @param getPost  "GET" or "POST"
     * @param payload  JSON encoded payload if it is POST
     */
    @ReactMethod
    public void executeCoreRESTCall(String endPoint, String getPost, String payload, String secret, String token, Boolean force, final Promise downloadFromCorePromise) {
        try {
//            URL u = new URL(endPoint);
//            String path = u.getPath();
            BaseAuthentication b = new CompanyAuth(token, secret);
            if (getPost.compareTo("POST") == 0) {

                okkamiSdk.getBACKEND_SERVICE_MODULE().doCorePostCall(endPoint, "POST", payload, b)
                        .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Observer<Response<ResponseBody>>() {
                            @Override
                            public void onSubscribe(Disposable d) {
                                System.out.println("Disposable method.");
                            }

                            @Override
                            public void onNext(Response<ResponseBody> value) {
                                try {
                                    if (value.raw().code() >= 400 || value.body() == null){
                                        downloadFromCorePromise.reject(value.raw().code()+"",value.raw().message());
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                    // e.printStackTrace();
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {


                                // Nothing for now.
                            }
                        });
            } else if (getPost.compareTo("GET") == 0){
                okkamiSdk.getBACKEND_SERVICE_MODULE().doCoreGetCall(endPoint, "GET", payload, b)
                        .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Observer<Response<ResponseBody>>() {
                            @Override
                            public void onSubscribe(Disposable d) {
                                System.out.println("Disposable method.");
                            }

                            @Override
                            public void onNext(Response<ResponseBody> value) {
                                try {
                                    String x = value.body().string();
                                    downloadFromCorePromise.resolve(x);
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                    // e.printStackTrace();
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {



                                // Nothing for now.
                            }
                        });
            } else if (getPost.compareTo("PUT") == 0) {

                okkamiSdk.getBACKEND_SERVICE_MODULE().doCorePostCall(endPoint, "PUT", payload, b)
                        .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Observer<Response<ResponseBody>>() {
                            @Override
                            public void onSubscribe(Disposable d) {
                                System.out.println("Disposable method.");
                            }

                            @Override
                            public void onNext(Response<ResponseBody> value) {
                                try {
                                    if (value.raw().code() >= 400 || value.body() == null){
                                        downloadFromCorePromise.reject(value.raw().code()+"",value.raw().message());
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                    // e.printStackTrace();
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {


                                // Nothing for now.
                            }
                        });
            }
        } catch (Exception e) {
            downloadFromCorePromise.reject(e);


        }

    }

    /*-------------------------------------- Hub -------------------------------------------------*/

    private void initMockData () {
        try {
            mock = new MockConfigModule(this.context, CommonUtil.loadProperty(this.context));
        } catch (IOException e) {
            Log.e("ERR", "Couldn't load mock config...");
        }
    }

    private HubModule initHub(String deviceId, String hubDnsName, int hubSslPort,
            BaseAuthentication auth) {

        if (TextUtils.isEmpty(deviceId) || auth == null || TextUtils.isEmpty(hubDnsName)) {
            throw new IllegalArgumentException("deviceId and authentication can not be null");
        }

        mCmdFactory = getCmdFactotry(deviceId, auth);
        mock.setHubDnsName(hubDnsName);
        mock.setHubSslPort(hubSslPort);
        hubModule = new HubModule(
                context,
                mock,
                mCmdFactory,
                okkamiSdk.getLoggerModule(),
                this
        );

        return hubModule;
    }


    private CommandFactoryModule getCmdFactotry(
            String deviceId, BaseAuthentication auth) {

        return new CommandFactoryModule(
                deviceId,
                auth == null ? mock.getCOMPANY_AUTH() : auth,
                mock,
                okkamiSdk.getSingerModule(),
                nonce,
                cmdSerializer,
                numberFormatter,
                okkamiSdk.getLoggerModule()
        );
    }

        /**
         * Connects to hub using the presets and attempts to login ( send IDENTIFY)
         * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
         * on success: hubConnectionPromise.resolve(true)
         * on failure:  hubConnectionPromise.reject(Throwable e)
         * Native module should also take care of the PING PONG and reconnect if PING drops
         *
         * @param secret              device id logged in to room
         * @param secret              secrect obtained from core
         * @param token               oken obtained from core
         * @param hubUrl              hub url
         * @param token               hub port
         * @param hubConnectionPromise
         */
    @ReactMethod
    public void connectToHub(String uid, String secret, String token, String hubUrl, String hubPort, Promise hubConnectionPromise) {

        BaseAuthentication auth = new DeviceAuth(token, secret);
        try {
            initHub(uid, hubUrl, Integer.parseInt(hubPort), auth);
            hubModule.connect();
            hubConnectionPromise.resolve(true);
            sendEvent((ReactContext) this.context, "onHubConnected", null);
        } catch (Exception e){
            hubConnectionPromise.reject(e);
        }
    }

    /**
     * Disconnects and cleans up the existing connection
     * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
     * on success: hubDisconnectionPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     *
     * @param hubDisconnectionPromise
     */
    @ReactMethod
    public void disconnectFromHub(Promise hubDisconnectionPromise) {
        try {
            hubModule.disconnect();
            hubDisconnectionPromise.resolve(true);
            sendEvent((ReactContext) this.context, "onHubDisconnected", null);
        } catch (Exception e){
            hubDisconnectionPromise.reject(e);
        }
    }

    /**
     * Disconnects and cleans up the existing connection
     * Then attempt to connect to hub again.
     * on success ( hub has been successfully reconnected and logged in ) : hubReconnectionPromise.resolve(true)
     * on failure:  hubReconnectionPromise.reject(Throwable e)
     *
     * @param hubReconnectionPromise
     */
    @ReactMethod
    public void reconnectToHub(Promise hubReconnectionPromise) {
        try {
            hubModule.connect();
        } catch (Exception e){
            hubReconnectionPromise.reject(e);
            return;
        }
        hubReconnectionPromise.resolve(true);
        sendEvent((ReactContext) this.context, "onHubConnected", null);
    }

    /**
     * Send command to hub. a command can look like this:
     * POWER light-1 ON
     * 2311 Default | POWER light-1 ON
     * 1234 2311 Default | POWER light-1 ON
     * <p>
     * The native module should fill in the missing info based on the command received
     * such as filling in room , group , none if not provided and skip those if provied already
     * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     *
     * @param sendMessageToHubPromise
     */
    @ReactMethod
    public void sendCommandToHub(String command, Promise sendMessageToHubPromise) {
        try {
            hubModule.sendCommand(command);
            sendMessageToHubPromise.resolve(true);
        } catch (Exception e){
            sendMessageToHubPromise.reject(e);
        }
    }


    /**
     * if hub is currently connected + logged in :
     * hubLoggedPromise.resolve(true);
     * else
     * hubLoggedPromise.resolve(false);
     *
     * @param hubLoggedPromise
     */
    @ReactMethod
    public void isHubLoggedIn(Promise hubLoggedPromise) {
        try {
            hubLoggedPromise.resolve(hubModule.isHubConnected() && hubModule.isCheckedIn());
            sendEvent((ReactContext) this.context, "onHubLoggedIn", null);
        } catch (Exception e){
            hubLoggedPromise.reject(e);
        }
    }

    /**
     * if hub is currently connected ( regardless of logged in ) :
     * hubConnectedPromise.resolve(true);
     * else
     * hubConnectedPromise.resolve(false);
     *
     * @param hubConnectedPromise
     */
    @ReactMethod
    public void isHubConnected(Promise hubConnectedPromise) {
        try {
            boolean isConnected = hubModule.isHubConnected();
            hubConnectedPromise.resolve(isConnected);
        } catch (Exception e){
            hubConnectedPromise.reject(e);
        }
    }


    //Events emission
    /*
    *  onHubCommand
    *            WritableMap map = Arguments.createMap();
    *            map.putString("command", "1234 2311 Default | POWER light-1 ON");
    *            this.sendEventToJs("onHubCommand", map);
    *  onHubConnected
    *             this.sendEventToJs("onHubConnected", null);
    *  onHubLoggedIn ( when IDENTIFIED is received )
    *             this.sendEventToJs("onHubLoggedIn", null);
    *  onHubDisconnected
    *            WritableMap map = Arguments.createMap();
    *            map.putString("command", "DISCONNECT_REASON");
    *            this.sendEventToJs("onHubDisconnected", map);
    * */



    @Override
    public void onCommandReceived(Command cmd) {
        WritableMap params = Arguments.createMap();
        params.putString("command", cmd.toString());
        sendEvent((ReactContext) this.context, "onHubCommand", params);
    }

    @Override
    public void onCommandReceived(boolean isPong, Command cmd) {
        WritableMap params = Arguments.createMap();
        params.putString("command", cmd.toString());
        sendEvent((ReactContext) this.context, "onHubCommand", params);
    }

    @Override
    public void reconnectToHub() {

    }

    @Override
    public void sendCommandToHub(Command cmd) {

    }

    @Override
    public boolean isHubLoggedIn() {
        return false;
    }

    @Override
    public boolean isHubConnected() {
        return false;
    }

    private void sendEvent(ReactContext reactContext,
            String eventName,
            @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }


    /*---------------------------------------------------------------------------------------------------*/


    /**
     * Returns the list of conversations as shown in : https://projects.invisionapp.com/share/2XAK26Y4G#/screens/223142641
     * returns a Promise which resolves to a json like this:
     * <p>
     * {
     * "OKKAMI_CHAT": [
     * {
     * "unread_messages": "2",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "OKKAMI Concierge",
     * "last_message": "We'll be happy to help your find good activities to do tonight",
     * "time_since_last_message": "5 min"
     * }
     * ],
     * "ACTIVE_CHATS": [
     * {
     * "unread_messages": "1",
     * "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
     * "channel_name": "Intercontinental Montreal",
     * "last_message": "Your room upgrade can be purchased using the link below",
     * "time_since_last_message": "1 hr 10 min"
     * },
     * {
     * "unread_messages": "3",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "Aloft Bangkok",
     * "last_message": "Food and wine at XYZ Bar",
     * "time_since_last_message": "5 hr"
     * }
     * ],
     * "INACTIVE_CHATS": [
     * {
     * "unread_messages": "0",
     * "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
     * "channel_name": "Grand President Hotel",
     * "last_message": "",
     * "time_since_last_message": ""
     * },
     * {
     * "unread_messages": "0",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "Ambassador Bangkok",
     * "last_message": "",
     * "time_since_last_message": ""
     * }
     * ]
     * }
     *
     * @param getConversationListPromise
     */
    @ReactMethod
    public void getConversationsList(ReadableArray smoochAllAppTokenArray, String userId, Promise getConversationListPromise) {

        try {
            final String ALL_CHAT_STR = "ALL_CHAT";
            final String OKKAMI_CHAT_STR = "OKKAMI_CHAT";
            final String ACTIVE_CHATS_STR = "ACTIVE_CHATS";
            final String INACTIVE_CHATS_STR = "INACTIVE_CHATS";
            JSONObject jsonObj = new JSONObject();
            ArrayList<JSONObject> okkamiChatList = new ArrayList<>();
            ArrayList<JSONObject> activeChatList = new ArrayList<>();
            ArrayList<JSONObject> inactiveChatList = new ArrayList<>();

            for (int i = 0; i < smoochAllAppTokenArray.size(); i++) {
                Settings settings = new Settings(smoochAllAppTokenArray.getString(i));
                settings.setUserId(userId);
                Smooch.init(app, settings);
                Smooch.login(userId, null);

                // Optional for now
                okkamiSdk.getDbModule().saveSmoochCredentials(Smooch.getSettings().getAppToken(),
                        Smooch.getSettings().getUserId());

                List<Message> listMsg = Smooch.getConversation().getMessages();
                int unreadMsgCount = Smooch.getConversation().getUnreadCount();

                if (listMsg.size() == 0 ) {
                    continue; // this smooch app token not start conversation yet
                }

                String iconUrl = "";
                String channelName = "";
                for (Message msg : listMsg) {
                    if (!msg.isFromCurrentUser()) {
                        iconUrl = msg.getAvatarUrl();
                        channelName = msg.getName();
                        break;
                    }
                }

                Message lastMsg = listMsg.get(listMsg.size() - 1);
                String lastMsgText = lastMsg.getText();
                Date epTime = lastMsg.getDate();
                Log.d(TAG, "getConversationsList: " + listMsg.toString());
                long different = (new Date()).getTime() - epTime.getTime();
                long secondsInMilli = 1000;
                long minutesInMilli = secondsInMilli * 60;
                long hoursInMilli = minutesInMilli * 60;
                long daysInMilli = hoursInMilli * 24;

                long elapsedDays = different / daysInMilli;
                different = different % daysInMilli;

                long elapsedHours = different / hoursInMilli;
                different = different % hoursInMilli;

                long elapsedMinutes = different / minutesInMilli;
                different = different % minutesInMilli;

                long elapsedSeconds = different / secondsInMilli;

                String epTimeString = "n/a";
                if (elapsedDays == 1) epTimeString = elapsedDays + " Day";
                else if (elapsedDays > 1) epTimeString = elapsedDays + "Days";
                else if (elapsedHours > 0) epTimeString = elapsedHours + "Hours";
                else if (elapsedMinutes > 0) epTimeString = elapsedMinutes + "Minutes";
                else epTimeString = elapsedSeconds + "Seconds";

                TimeZone tz = TimeZone.getTimeZone("UTC");
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
                df.setTimeZone(tz);
                String lastTimeAsISO = df.format(epTime);

                JSONObject okkamiJsonObj = createConversationJsonObj(unreadMsgCount,
                        iconUrl, channelName,
                        lastMsgText, lastTimeAsISO, epTimeString, smoochAllAppTokenArray.getString(i));

                if (i == 0) {
                    okkamiChatList.add(okkamiJsonObj);
                } else if (i > 0 && unreadMsgCount > 0) {
                    activeChatList.add(okkamiJsonObj);
                } else { // unactive chat
                    inactiveChatList.add(okkamiJsonObj);
                }
            }

            jsonObj.put(OKKAMI_CHAT_STR, new JSONArray(okkamiChatList));
            jsonObj.put(ACTIVE_CHATS_STR, new JSONArray(activeChatList));
            jsonObj.put(INACTIVE_CHATS_STR, new JSONArray(inactiveChatList));

            Log.d(TAG, "getConversationsList: "+jsonObj.toString());
            getConversationListPromise.resolve(jsonObj.toString());

        } catch (Exception e) {
            getConversationListPromise.reject(e.getMessage(), e.getMessage());
            e.printStackTrace();
        }
    }

    private static JSONObject createConversationJsonObj(int unreadMsgCount, String iconUrl,
            String channelName, String lastMsgText, String lastTime, String epTime, String smoochAppToken) throws JSONException {
        JSONObject jsonObj = new JSONObject();
        jsonObj.put("unread_messages", unreadMsgCount);
        jsonObj.put("icon", iconUrl);
        jsonObj.put("channel_name", channelName);
        jsonObj.put("last_message", lastMsgText);
        jsonObj.put("last_time", lastTime);
        jsonObj.put("time_since_last_message", epTime);
        jsonObj.put("app_token", smoochAppToken);
        return jsonObj;
    }

    /**
     * Open the smooch chat window for a particular channel
     * openChatWindowPromise.resolve(true) on success
     * openChatWindowPromise.reject(Exception) on failure
     * @param smoochAppToken
     * @param openChatWindowPromise
     */
    @ReactMethod
    public void openChatWindow(String smoochAppToken, String userId, String windowHexStringColor, String titleHexStringColor, Promise openChatWindowPromise) {
        try {
            Smooch.init(app, smoochAppToken);
            Intent chatWindow = new Intent(context, ConversationActivity.class);
            chatWindow.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(chatWindow);
            openChatWindowPromise.resolve(true);
        } catch (Exception e){
            openChatWindowPromise.reject(e);
        }
    }


    /**
     * returns the number of unread message in a channel
     * getUnreadMessageCountPromise.resolve(Int) on success
     * getUnreadMessageCountPromise.reject(Exception) on failure
     * @param smoochAppToken
     * @param getUnreadMessageCountPromise
     */
    @ReactMethod
    public void getUnreadMessageCount(String smoochAppToken, String userId, Promise getUnreadMessageCountPromise){
        try {
            Smooch.init(this.app, smoochAppToken);
            getUnreadMessageCountPromise.resolve(Smooch.getConversation().getUnreadCount());
        } catch (Exception e) {
            getUnreadMessageCountPromise.reject(e.getMessage(), e.getMessage());
        }
    }


    /**
     * Closes the current chat window / destroy
     * logoutChatWindowPromise.resolve(Int) on success
     * logoutChatWindowPromise.reject(Exception) on failure
     * @param logoutChatWindowPromise
     */
    @ReactMethod
    public void logoutChatWindow(Promise logoutChatWindowPromise){
        try {
            if (Smooch.getInitializationStatus() == InitializationStatus.Success &&
                    Smooch.getSmoochConnectionStatus() == SmoochConnectionStatus.Connected) {
                Smooch.logout();
                ConversationActivity.close();
                logoutChatWindowPromise.resolve(1);
            }
        } catch (Exception e) {
            logoutChatWindowPromise.reject(e.getMessage(), e.getMessage());
        }
    }

}
