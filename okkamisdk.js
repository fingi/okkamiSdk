import {NativeModules, DeviceEventEmitter} from 'react-native';
const OkkamiSdkManager = NativeModules.OkkamiSdk;


class OkkamiSdk {
    constructor() {

    }

    /*-------------------------------------- Utility   --------------------------------------------------*/



    /*---------------------------------------------------------------------------------------------------*/
    /*-------------------------------------- Hub & Core -------------------------------------------------*/

    lineLogin() {
        return OkkamiSdkManager.lineLogin();
    }

    smoochChat(appToken, userID) {
      return OkkamiSdkManager.smoochChat(appToken, userID);
    }

    smoochLogout() {
      return OkkamiSdkManager.smoochLogout();
    }

    executeCoreRESTCall (endPoint,getPost,payLoad,secret,token,force) {
        return OkkamiSdkManager.executeCoreRESTCall(endPoint,getPost,payLoad,secret,token,force);
    }

    connectToHub(uid,secret,token,hubUrl,hubPort) {
        return OkkamiSdkManager.connectToHub(uid, secret, token, hubUrl, hubPort);
    }

    disconnectFromHub() {
        return OkkamiSdkManager.disconnectFromHub();
    }

    reconnectToHub() {
        return OkkamiSdkManager.reconnectToHub();
    }

    sendCommandToHub(command) {
        return OkkamiSdkManager.sendCommandToHub(command);
    }

    async isHubLoggedIn() {
        return await OkkamiSdkManager.isHubLoggedIn();
    }

    async isHubConnected() {
        return await OkkamiSdkManager.isHubConnected();
    }

    /*---------------------------------------------------------------------------------------------------*/

    /*-------------------------------------- SIP / PhoneCall --------------------------------------------*/



}
let okkamiSdk = new OkkamiSdk();
export default okkamiSdk;



