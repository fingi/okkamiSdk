package com.okkami.okkamisdk;

import android.content.Context;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.okkami.android.sdk.SDK;
import com.okkami.android.sdk.config.MockConfig;

import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import lombok.Getter;
import okhttp3.ResponseBody;
import retrofit2.Response;

class OkkamiSdkModule extends ReactContextBaseJavaModule {
    private Context context;
    private static final String TAG = "OKKAMISDK";

    @Getter
    private static MockConfig mock;
    @Getter
    private static SDK mSdk;

    private SDK initSDK() {
        if (this.mSdk == null) {
            this.mSdk = new SDK().init(this.context, mock.getBASE_URL());
        }

        return this.mSdk;
    }

    public OkkamiSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
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



     /*---------------------------Core------------------------------------------------------------------------*/

    /**
     * The purpose of this method is to provide general purpose way to call any core endpoint.
     * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
     * <p>
     * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
     * on failure:  downloadFromCorePromise.reject(Throwable e)
     *
     * @param endPoint                full core url . https://api.fingi.com/devices/v1/register
     * @param getPost                 "GET" or "POST"
     * @param payload                 JSON encoded payload if it is POST
     * @param downloadFromCorePromise
     */
    @ReactMethod
    public void executeCoreRESTCall(String endPoint, String getPost, String payload, Promise downloadFromCorePromise) {
        mPromise = downloadFromCorePromise;
        this.mSdk = initSDK();

        if (method.equalsIgnoreCase(POST)){
            mSdk.getBACKEND_SERVICE_MODULE()
                    .doCorePostCall(endPoint, method, payload, mock.getCOMPANY_AUTH())
                    .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new Observer<Response<ResponseBody>>() {
                        @Override
                        public void onSubscribe(Disposable d) {
                            System.out.println("Disposable method.");
                        }

                        @Override
                        public void onNext(Response<ResponseBody> value) {
                            mPromise.resolve(value.message());
//                        try {
//                            handlePreconnectResponse(value);
//                        } catch (Exception e) {
//                            sdk.getLoggerModule().logE("" + e);
//                        }
                        }

                        @Override
                        public void onError(Throwable e) {
//                        sdk.getLoggerModule().logE("" + e);
                        }

                        @Override
                        public void onComplete() {
                            // Nothing for now.
                        }
                    });
        } else {
            mSdk.getBACKEND_SERVICE_MODULE()
                    .doCoreGetCall(endPoint, method, payload, mock.getCOMPANY_AUTH())
                    .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe(new Observer<Response<ResponseBody>>() {
                        @Override
                        public void onSubscribe(Disposable d) {
                            System.out.println("Disposable method.");
                        }

                        @Override
                        public void onNext(Response<ResponseBody> value) {
                            mPromise.resolve(value.message());
//                        try {
//                            handlePreconnectResponse(value);
//                        } catch (Exception e) {
//                            sdk.getLoggerModule().logE("" + e);
//                        }
                        }

                        @Override
                        public void onError(Throwable e) {
//                        sdk.getLoggerModule().logE("" + e);
                        }

                        @Override
                        public void onComplete() {
                            // Nothing for now.
                        }
                    });
        }
    }

    /*-------------------------------------- Hub -------------------------------------------------*/


    /**
     * Connects to hub using the presets and attempts to login ( send IDENTIFY)
     * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
     * on success: hubConnectionPromise.resolve(true)
     * on failure:  hubConnectionPromise.reject(Throwable e)
     * Native module should also take care of the PING PONG and reconnect if PING drops
     *
     * @param secrect secrect obtained from core
     * @param token   token obtained from core
     * @param hubConnectionPromise
     */
    @ReactMethod
    public void connectToHub(String secrect,String token , Promise hubConnectionPromise) {

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
        /*
            //ok
            hubLoggedPromise.resolve(true);
            //not ok!
            hubLoggedPromise.resolve(false);
        */
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
        /*
            //connected
            hubConnectedPromise.resolve(true);
            //not connected
            hubConnectedPromise.resolve(false);
        */
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

    /*---------------------------------------------------------------------------------------------------*/



}
