package com.okkami.okkamisdk;

import static com.facebook.FacebookSdk.getApplicationContext;

import android.app.Activity;
import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Build;
import android.os.SystemClock;
import android.preference.PreferenceManager;
import android.support.annotation.Nullable;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;

import com.facebook.FacebookSdk;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.linecorp.linesdk.auth.LineLoginApi;
import com.linecorp.linesdk.auth.LineLoginResult;
import com.okkami.android.sdk.SDK;
import com.okkami.android.sdk.config.MockConfigModule;
import com.okkami.android.sdk.domain.legacy.NonceManagerModule;
import com.okkami.android.sdk.domain.legacy.NumberFormatterModule;
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
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.smooch.core.InitializationStatus;
import io.smooch.core.Message;
import io.smooch.core.Settings;
import io.smooch.core.Smooch;
import io.smooch.core.SmoochConnectionStatus;
import io.smooch.ui.ConversationActivity;
import me.leolin.shortcutbadger.ShortcutBadger;
import okhttp3.ResponseBody;
import retrofit2.Response;

public class OkkamiSdkModule extends ReactContextBaseJavaModule implements
        OnHubCommandReceivedListener {

    public interface MethodInvokeListener {
        void invoke(String methodName, String arg);
        void invokeUnsubscribePusher();
        void setAppLocale(String locale);
        String getAppLocale();
    }

    private MethodInvokeListener mMethodInvoker;

    private static final String TAG = "OKKAMISDK";
    private static final int LINE_LOGIN_REQUEST_CODE = 10;
    private HubModule hubModule;
    private final NonceManagerModule nonce = new NonceManagerModule();
    private final CommandSerializerModule cmdSerializer = new CommandSerializerModule();
    private final NumberFormatterModule numberFormatter = new NumberFormatterModule();
    private Application mApp;
    private static Context mContext;
    private String lineLoginChannelId = "1499319131";
    private SDK okkamiSdk;
    private Promise lineLoginPromise = null;

    private static String userId;

    public static String getUserId() {
        return userId;
    }

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode,
                                     Intent data) {
            super.onActivityResult(activity, requestCode, resultCode, data);
            Log.d(TAG, "onActivityResult: " + requestCode);
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
                        if (result.getLineProfile() != null && result.getLineProfile().getPictureUrl() != null) {
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
                        lineLoginPromise.reject("error", "The login was successful. but something happened when constructed json object.");
                    }

                    lineLoginPromise.resolve(jObj.toString());
                    break;
                case CANCEL:
                    // Login was cancelled by the user
                    // Do something...
                    lineLoginPromise.reject("error", "The login failed because the user canceled the login process.");
                    break;
                case SERVER_ERROR:
                    lineLoginPromise.reject("error", "The login failed due to a server-side error.");
                    break;
                case NETWORK_ERROR:
                    lineLoginPromise.reject("error", "The login failed because the SDK could not connect to the LINE Login servers.");
                    break;
                case INTERNAL_ERROR:
                    lineLoginPromise.reject("error", "The login failed due to an unknown error.");
                    break;
                default:
                    // Login was cancelled by the user
                    // Do something...
            }
        }

    };
    private MockConfigModule mock;
    private DeviceAuth mDeviceAuth;
    private CommandFactoryModule mCmdFactory;

    public OkkamiSdkModule(ReactApplicationContext reactContext, Application app, MethodInvokeListener invoker) {

        super(reactContext);

        mMethodInvoker = invoker;
        mApp = app;
        mContext = reactContext;
        reactContext.addActivityEventListener(mActivityEventListener);

        String baseUrl = (String) BuildConfigUtil.getBuildConfigValue(getReactApplicationContext(), "BASE_URL");
        Log.d(TAG, "baseUrl=" + baseUrl);

        okkamiSdk = new SDK().init(reactContext, baseUrl);
        initMockData();

//        lineLoginChannelId = reactContext.getString(R.string.line_login_channel_id);
        lineLoginChannelId = (String) BuildConfigUtil.getBuildConfigValue(getReactApplicationContext(), "LINE_APP_ID");
        Log.d(TAG, "lineLoginChannelId=" + lineLoginChannelId);
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

/*-------------------------------------- Utility   --------------------------------------------------*/

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from javascript.
     */
    @Override
    public String getName() {
        return "OkkamiSdk";
    }

    // have a connection to any network
    public static boolean isNetworkConnected() {
        NetworkInfo info = getActiveNetworkInfo();

        boolean isConnected = (info != null && info.isConnected());

        Log.d(TAG, "isConnected=" + isConnected);

        return isConnected;
    }

    private static NetworkInfo getActiveNetworkInfo() {
        return ((ConnectivityManager) mContext.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE))
                .getActiveNetworkInfo();
    }

    // have an internet access
    public boolean isOnline() {
        Runtime runtime = Runtime.getRuntime();
        try {
            Process ipProcess = runtime.exec("/system/bin/ping -c 1 8.8.8.8");
            int exitValue = ipProcess.waitFor();
            return (exitValue == 0);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return false;
    }

    @ReactMethod
    public void setFacebookEnvironment(ReadableMap fbConfig) {

//        String fbAppId = fbConfig.getString("fbAppId");

        String fbAppId = (String) BuildConfigUtil.getBuildConfigValue(getReactApplicationContext(), "FB_APP_ID");
        Log.d(TAG, "fbAppId=" + fbAppId);

        if (FacebookSdk.isInitialized() && FacebookSdk.getApplicationId().equals(fbAppId)) {
            return;
        }

        FacebookSdk.setApplicationId(fbAppId);
        FacebookSdk.sdkInitialize(mContext);
    }

    @ReactMethod
    public void setLineEnvironment(ReadableMap lineConfig) {
//        lineLoginChannelId = lineConfig.getString("lineAppId");
        lineLoginChannelId = (String) BuildConfigUtil.getBuildConfigValue(getReactApplicationContext(), "LINE_APP_ID");
        Log.d(TAG, "lineLoginChannelId=" + lineLoginChannelId);
    }

    /**
     * Set the badge app icon with provided number
     *
     * @param unreadMsgNumber - the number to be show in badge app icon
     */
    @ReactMethod
    public void setAppBadgeIcon(int unreadMsgNumber) {
        if (mContext == null) {
            throw new IllegalArgumentException("mContext can't be null");
        }

        if (unreadMsgNumber > 0) {
            ShortcutBadger.applyCount(mContext, unreadMsgNumber);
        } else {
            //  same as: (unreadMsgNumber <= 0)
            ShortcutBadger.removeCount(this.mContext);
        }
    }

    /**
     * Set app's locale
     *
     * @param locale - a locale string to set in the app
     */
    @ReactMethod
    public void setLanguage(String locale) {
        Log.e(TAG, "setLanguage: "+locale );
        if (locale != null) {
            mMethodInvoker.setAppLocale(locale);
        }
    }

    /*---------------------------Core------------------------------------------------------------------------*/
    @ReactMethod
    public void lineLogin(Promise lineLoginPromise) {

        if (!isNetworkConnected()) {
            lineLoginPromise.reject("error", "have no network connected.");
            return;
        }

        if (!isOnline()) {
            lineLoginPromise.reject("error", "have no internet connection");
            return;
        }

        this.lineLoginPromise = lineLoginPromise;
        Intent loginIntent = LineLoginAPI.getLoginIntent(mContext, lineLoginChannelId);
        getCurrentActivity().startActivityForResult(loginIntent, LINE_LOGIN_REQUEST_CODE);
    }

/*-------------------------------------- Hub -------------------------------------------------*/

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
                                    if (value.raw().code() >= 400 || value.body() == null) {
                                        downloadFromCorePromise.reject(value.raw().code() + "", value.raw().message());
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
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
            } else if (getPost.compareTo("GET") == 0) {
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
                                    if (value.raw().code() >= 400 || value.body() == null) {
                                        if (value.raw().message().contains("Not Found") && value.raw().code() == 404
                                                && value.raw().request().url().toString().contains("messages?before")) {
                                            String msg = "{\"error\":\"conversation not found\","
                                                    + "\"code\":\"404\"}";
                                            downloadFromCorePromise.resolve(msg);
                                        } else {
                                            downloadFromCorePromise.reject(value.raw().code() + "", value.raw().message());
                                        }
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
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
                                    if (value.raw().code() >= 400 || value.body() == null) {
                                        downloadFromCorePromise.reject(value.raw().code() + "", value.raw().message());
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {

                            }
                        });
            } else if (getPost.compareTo("DELETE") == 0) {

                okkamiSdk.getBACKEND_SERVICE_MODULE().doCoreDeleteCall(endPoint, "DELETE", payload, b)
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
                                    if (value.raw().code() >= 400 || value.body() == null) {
                                        downloadFromCorePromise.reject(value.raw().code() + "", value.raw().message());
                                    } else {
                                        String x = value.body().string();
                                        downloadFromCorePromise.resolve(x);
                                    }
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {

                            }
                        });
            }
        } catch (Exception e) {
            downloadFromCorePromise.reject(e);
        }
    }

    private void initMockData() {
        try {
            mock = new MockConfigModule(mContext, CommonUtil.loadProperty(mContext));
        } catch (IOException e) {
            Log.e("ERR", "Couldn't load mock config...");
        }
    }

    private HubModule initHub(String deviceId, String hubDnsName, int hubSslPort,
                              BaseAuthentication auth) {

        Log.d(TAG, "deviceId=" + deviceId);
        Log.d(TAG, "this.userId=" + getUserId());

        if (TextUtils.isEmpty(deviceId) || auth == null || TextUtils.isEmpty(hubDnsName)) {
            throw new IllegalArgumentException("deviceId and authentication can not be null");
        }

        mCmdFactory = getCmdFactotry(deviceId, auth);
        mock.setHubDnsName(hubDnsName);
        mock.setHubSslPort(hubSslPort);

        if (hubModule != null) {
            hubModule.disconnect();
            hubModule = null;
        }

        hubModule = new HubModule(
                mContext,
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


    static String secret;
    static String token;
    static String hubUrl;
    static String hubPort;

    /**
     * Connects to hub using the presets and attempts to login ( send IDENTIFY)
     * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
     * on success: hubConnectionPromise.resolve(true)
     * on failure:  hubConnectionPromise.reject(Throwable e)
     * Native module should also take care of the PING PONG and reconnect if PING drops
     *
     * @param secret               device id logged in to room
     * @param secret               secrect obtained from core
     * @param token                oken obtained from core
     * @param hubUrl               hub url
     * @param token                hub port
     * @param hubConnectionPromise
     */
    @ReactMethod
    public void connectToHub(final String userId, String secret, String token, final String hubUrl, final String hubPort, final Promise hubConnectionPromise) {

        this.userId = userId;
        this.secret = secret;
        this.token = token;
        this.hubUrl = hubUrl;
        this.hubPort = hubPort;



        Log.d(TAG, "this.userId=" + this.userId);
        Log.d(TAG, "userId=" + userId);

        final BaseAuthentication auth = new DeviceAuth(token, secret);

        final OkkamiSdkModule __myself = this;
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    __myself.initHub(userId, hubUrl, Integer.parseInt(hubPort), auth);
                    __myself.hubModule.connect(userId);
                    if (hubConnectionPromise != null)
                        hubConnectionPromise.resolve(true);
                    sendEvent((ReactContext) mContext, "onHubConnected", null);

                } catch (Exception e) {
                    if (hubConnectionPromise != null)
                        hubConnectionPromise.reject(e);
                }
            }
        }).start();
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
    public void disconnectFromHub(final Promise hubDisconnectionPromise) {
        final OkkamiSdkModule __myself = this;
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    if(__myself.hubModule != null) {
                        __myself.hubModule.disconnect();
                        __myself.hubModule = null;
                        hubDisconnectionPromise.resolve(true);
                        sendEvent((ReactContext) mContext, "onHubDisconnected", null);
                    } else {
                        hubDisconnectionPromise.reject("NullException", "HubModule is null object");
                    }

                } catch (Exception e) {
                    hubDisconnectionPromise.reject(e);
                }
            }
        }).start();

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
    public void reconnectToHub(final String userId, final Promise hubReconnectionPromise) {
        new AsyncTask<Void, Void, Void>() {

            @Override
            protected Void doInBackground(Void... params) {
                try {
                    hubModule.connect(userId);
                } catch (Exception e) {
                    hubReconnectionPromise.reject(e);
                }
                hubReconnectionPromise.resolve(true);
                sendEvent((ReactContext) mContext, "onHubConnected", null);

                return null;
            }
        }.execute();
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
            boolean result = hubModule.sendCommand(command);


            if (result == false) {

                Log.e(TAG, "sendCommandToHub: failed, reconnecting");

                //connectToHub(final String userId, String secret, String token, final String hubUrl, final String hubPort, final Promise hubConnectionPromise) {
                connectToHub(this.userId, this.secret, this.token, this.hubUrl, this.hubPort, null);
            }else{
                Log.d(TAG,"Successfully sent command to hub..");
            }

            sendMessageToHubPromise.resolve(true);
        } catch (Exception e) {
            Log.e(TAG, "sendCommandToHub: failed : " + e.getMessage());
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
            sendEvent((ReactContext) mContext, "onHubLoggedIn", null);
        } catch (Exception e) {
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
        } catch (Exception e) {
            hubConnectedPromise.reject(e);
        }
    }

    @Override
    public void onCommandReceived(Command cmd) {
        WritableMap params = Arguments.createMap();
        params.putString("command", cmd.toString());
        sendEvent((ReactContext) mContext, "onHubCommand", params);
    }

    @Override
    public void onCommandReceived(boolean isPong, Command cmd) {
        WritableMap params = Arguments.createMap();
        params.putString("command", cmd.toString());
        sendEvent((ReactContext) mContext, "onHubCommand", params);
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

    private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

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

                String appToken = smoochAllAppTokenArray.getString(i);
                Settings settings = new Settings(appToken);
                settings.setUserId(userId);
                Smooch.getSettings().setFirebaseCloudMessagingAutoRegistrationEnabled(false);
                Smooch.init(mApp, settings);

                List<Message> listMsg = Smooch.getConversation().getMessages();
                int unreadMsgCount = Smooch.getConversation().getUnreadCount();

                if (listMsg.size() == 0) {
                    continue; // this smooch mApp token not start conversation yet
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

            getConversationListPromise.resolve(jsonObj.toString());

        } catch (Exception e) {
            getConversationListPromise.reject(e.getMessage(), e.getMessage());
            okkamiSdk.getLoggerModule().logE("" + e);
        }
    }

    /**
     * Open the smooch chat window for a particular channel
     *
     * @param smoochAppToken
     */
    @ReactMethod
    public void openChatWindow(String smoochAppToken,
                               String userId,
                               String windowTitle,
                               String windowHexStringColor,
                               String titleHexStringColor,
                               boolean windowInRgb,
                               boolean titleInRgb) {
        try {

            Log.d(TAG, "smoochAppToken=" + smoochAppToken);
            Log.d(TAG, "userId=" + userId);

            Settings settings = new Settings(smoochAppToken);
            settings.setUserId(userId);
            Smooch.init(mApp, settings);

            Intent chatWindow = new Intent();
            ComponentName cmp = new ComponentName(getReactApplicationContext().getPackageName(),
                    "com.okkami.android.app.OkkamiConversationActivity");

            chatWindow.setComponent(cmp);
            chatWindow.putExtra("SMOOCH_SDK_INITIALIZED", true);
            chatWindow.putExtra("SMOOCH_APP_TOKEN", smoochAppToken);
            chatWindow.putExtra("USER_ID", userId);
            chatWindow.putExtra("CHAT_WINDOW_COLOR", windowHexStringColor);
            chatWindow.putExtra("CHAT_WINDOW_TITLE_COLOR", titleHexStringColor);
            chatWindow.putExtra("CHAT_WINDOW_TITLE", windowTitle);
            chatWindow.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(chatWindow);
        } catch (Exception e) {
            Log.e(TAG, "" + e);
        }
    }

    // React native layer will call this function upon user
    // login and|or application starts up event
    @ReactMethod
    public void setUserId(String id) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(mApp);
        prefs.edit().putString("USER_ID", userId);
        prefs.edit().commit();
        userId = id;

        invokeInitPushNoti();
    }

    private void invokeInitPushNoti() {
        // Method name is currently optional.
        mMethodInvoker.invoke("initPusherFcmService", userId);
    }

    // React native calling as looping with different appTokens
    @ReactMethod
    public void loginChatWindow(String userId, String appToken) {
        Settings settings = new Settings(appToken);
        settings.setUserId(userId);
        Smooch.init(mApp, settings);
    }

    /**
     * returns the number of unread message in a channel
     * getUnreadMessageCountPromise.resolve(Int) on success
     * getUnreadMessageCountPromise.reject(Exception) on failure
     *
     * @param smoochAppToken
     * @param getUnreadMessageCountPromise
     */
    @ReactMethod
    public void getUnreadMessageCount(String smoochAppToken, String userId, Promise getUnreadMessageCountPromise) {
        try {
            Smooch.init(mApp, smoochAppToken);
            getUnreadMessageCountPromise.resolve(Smooch.getConversation().getUnreadCount());
        } catch (Exception e) {
            getUnreadMessageCountPromise.reject(e.getMessage(), e.getMessage());
        }
    }


    /**
     * Closes the current chat window / destroy
     * logoutChatWindowPromise.resolve(Int) on success
     * logoutChatWindowPromise.reject(Exception) on failure
     *
     * @param logoutChatWindowPromise
     */
    @ReactMethod
    public void logoutChatWindow(Promise logoutChatWindowPromise) {
        try {
            if (Smooch.getInitializationStatus() == InitializationStatus.Success &&
                    Smooch.getSmoochConnectionStatus() == SmoochConnectionStatus.Connected) {
                Smooch.logout();
                ConversationActivity.close();
                logoutChatWindowPromise.resolve(1);
            }
            mMethodInvoker.invokeUnsubscribePusher();
        } catch (Exception e) {
            logoutChatWindowPromise.reject(e.getMessage(), e.getMessage());
        }
    }
}
