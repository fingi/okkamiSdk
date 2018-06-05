import {NativeModules, DeviceEventEmitter} from 'react-native'
import Metrics from '../App/Themes/Metrics'
import moment from 'moment'
// import {convertRgbaToHex} from '../App/Lib/Utilities'
const OkkamiSdkManager = NativeModules.OkkamiSdk

class OkkamiSdk {
  constructor () {

  }

  /* -------------------------------------- Utility   -------------------------------------------------- */

  /* --------------------------------------------------------------------------------------------------- */
  /* -------------------------------------- Hub & Core ------------------------------------------------- */

  lineLogin () {
    return OkkamiSdkManager.lineLogin()
  }

  executeCoreRESTCall (endPoint, getPost, payLoad, secret, token, force) {
    console.log('Attemptng to cexecuteCoreRESTCall with endpoint : ', endPoint, ' method :',
      getPost, ' using secret : ', secret,
      ' and token : ', token, ' forcing : ', force)

    return OkkamiSdkManager.executeCoreRESTCall(endPoint, getPost, payLoad, secret, token, force)
  }

  connectToHub (uid, secret, token, hubUrl, hubPort) {
    return OkkamiSdkManager.connectToHub(uid, secret, token, hubUrl, hubPort)
  }

  disconnectFromHub () {
    return OkkamiSdkManager.disconnectFromHub()
  }

  reconnectToHub (userId) {
    return OkkamiSdkManager.reconnectToHub(userId)
  }

  sendCommandToHub (command) {
    return OkkamiSdkManager.sendCommandToHub(command)
  }

  setAppBadgeIcon (number) {
    return OkkamiSdkManager.setAppBadgeIcon(number)
  }

  setUserId (userId, brandId) {
    return OkkamiSdkManager.setUserId(userId, brandId)
  }

  async isHubLoggedIn () {
    return await OkkamiSdkManager.isHubLoggedIn()
  }

  async isHubConnected () {
    return await OkkamiSdkManager.isHubConnected()
  }

  checkNotif () {
    return OkkamiSdkManager.checkNotif()
  }

  checkEvent () {
    return OkkamiSdkManager.checkEvent()
  }

  setLanguage (language) {
    return OkkamiSdkManager.setLanguage(language)
  }
  /* --------------------------------------------------------------------------------------------------- */

  /* -------------------------------------- SMOOCH -------------------------------------------- */

  /**
   * Returns the list of conversations as shown in : https://projects.invisionapp.com/share/2XAK26Y4G#/screens/223142641
   * returns a Promise which resolves to a json like this:
   *
   *  {
  "OKKAMI_CHAT": [
    {
      "unread_messages": "2",
      "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
      "channel_name": "OKKAMI Concierge",
      "last_message": "We'll be happy to help your find good activities to do tonight",
      "time_since_last_message": "5 min"
    }
  ],
  "ACTIVE_CHATS": [
    {
      "unread_messages": "1",
      "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
      "channel_name": "Intercontinental Montreal",
      "last_message": "Your room upgrade can be purchased using the link below",
      "time_since_last_message": "1 hr 10 min"
    },
    {
      "unread_messages": "3",
      "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
      "channel_name": "Aloft Bangkok",
      "last_message": "Food and wine at XYZ Bar",
      "time_since_last_message": "5 hr"
    }
  ],
  "INACTIVE_CHATS": [ // for inactive chats, take a look at this : https://fingi1.atlassian.net/browse/FD-3529
    {
      "unread_messages": "0",
      "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
      "channel_name": "Grand President Hotel",
      "last_message": "",
      "time_since_last_message": ""
    },
    {
      "unread_messages": "0",
      "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
      "channel_name": "Ambassador Bangkok",
      "last_message": "",
      "time_since_last_message": ""
    }
  ]
}
   *
   *
   * @returns {Promise}
   */
  async getConversationsList (smoochAllAppTokenArray, userID) {
    return await OkkamiSdkManager.getConversationsList(smoochAllAppTokenArray, userID)
  }

  /**
   * Open the smooch chat window for a particular channel
   * @param smoochAppToken
   * @returns {Promise.<void>}
   */
  async openChatWindow (smoochAppToken, userID, hotelName, color, textColor, smoochUserJwt) {
    console.log('smoochAppToken: ' + smoochAppToken)
    console.log('userID: ' + userID)
    console.log('userJWT: ' + smoochUserJwt)
    var newColor = color
    var newTextColor = textColor
    var rgbColor = false
    var rgbTextColor = false
    if (!color.includes('#')) {
      rgbColor = true
    }
    if (!textColor.includes('#')) {
      rgbTextColor = true
    }

    // if(color != ""){
    //   if(!color.includes("#")){
    //     var colorsOnly = color.substring(color.indexOf('(') + 1, color.lastIndexOf(')')).split(/,\s*/)
    //     var red = parseFloat(colorsOnly[0])
    //     var green = parseFloat(colorsOnly[1])
    //     var blue = parseFloat(colorsOnly[2])
    //     var opacity = parseFloat(colorsOnly[3])
    //
    //     console.log("r g b a: ",red,green,blue,opacity);
    //
    //     newColor = convertRgbaToHex(red, green, blue, opacity)
    //     newColor = newColor.substring(0,6)
    //   }
    // }
    // if(textColor != ""){
    //   if(!textColor.includes("#")){
    //     var colorsOnly = textColor.substring(textColor.indexOf('(') + 1, textColor.lastIndexOf(')')).split(/,\s*/)
    //     var red = colorsOnly[0]
    //     var green = colorsOnly[1]
    //     var blue = colorsOnly[2]
    //     var opacity = colorsOnly[3]
    //     newTextColor = convertRgbaToHex(red, green, blue, opacity)
    //     newTextColor = newTextColor.substring(0,6)
    //     console.log("r g b a: ",red,green,blue,opacity);
    //   }
    // }
    // console.log("newColor: "+newColor);
    // console.log("newTextColor: "+newTextColor);
    return await OkkamiSdkManager.openChatWindow(smoochAppToken, userID, hotelName, newColor, newTextColor, rgbColor, rgbTextColor, smoochUserJwt)
  }

  /**
   * Get number of unread messages in a channel
   * To be used in a screen like this : https://projects.invisionapp.com/share/2XAK26Y4G#/screens/223161039
   * @param smoochAppToken
   * @returns {Promise.<int>}
   */
  async getUnreadMessageCount (smoochAppToken, userID) {
    return await OkkamiSdkManager.getUnreadMessageCount(smoochAppToken, userID)
  }

  /**
   * Closese the current chat window
   * @returns {Promise}
   */
  async logoutChatWindow () {
    return await OkkamiSdkManager.logoutChatWindow()
  }

  async convertTime (time) {
    return await OkkamiSdkManager.convertTime(time)
  }

  /**
   * Open an external app with a given android package name
   * @param pName Android package name
   * @returns {*}
   */
  openAndroidExternalApp (pName) {
    console.log('Open android package name ', pName)
    return OkkamiSdkManager.openAndroidExternalApp(pName)
  }

  onAppLanded () {
    console.log('On app landed')
    OkkamiSdkManager.onAppLanded()
  }

  shutdownApp () {
    console.log('shutting down the app...')
    OkkamiSdkManager.shutdownApp()
  }

  /**
   * Subscribe pusher channel with device id
   * @param dId
   */
  subscribePusher (dId) {
    console.log('subscribing pusher with device id: ', dId)
    OkkamiSdkManager.subscribePushser(dId)
  }

  /**
   * Unsubscribe pusher channel with device id
   * @param dId
   */
  unsubscribePusher (dId) {
    console.log('unsubscribing pusher with device id: ', dId)
    OkkamiSdkManager.unsubscribePushser(dId)
  }

  /**
   * Use to indicate user is on my request screen
   * @param isUserInMyRequesScreen - boolean to indicate whether user is on my request screen
   */
  onUserInMyRequestScreen (isUserInMyRequesScreen) {
    console.log('onUserInMyRequestScreen: ', isUserInMyRequesScreen)
    OkkamiSdkManager.onUserInMyRequestScreen(isUserInMyRequesScreen)
  }

  /**
   * Use to enable single app
   */
  enableSingleAppMode () {
    OkkamiSdkManager.enableSingleAppMode()
  }


  /**
   * Use to disable single app
   */
  disableSingleAppMode () {
    OkkamiSdkManager.disableSingleAppMode()
  }

  // ============================================== Device Information  ==============================================

  /**
   * Return last received push notification string
   */
  async getLastReceivedPushNotification () {
    try {
      return await OkkamiSdkManager.getLastReceivedPushNotification()
    } catch (e) {
      return e
    }
  }


  /**
   * Return last received push notification string
   */
  async getLastFCMRegistrationStatus() {
    try {
      let {lastFcmStatus} = await OkkamiSdkManager.getLastFcmRegistrationStatus()
      return lastFcmStatus
    } catch (e) {
      return e
    }
  }

  /**
   * Get the current battery level
   */
  async getBatteryLevel () {
    try {
      if (Metrics.platform === 'android') {
        let batt = await OkkamiSdkManager.getBatteryLevel()
        return batt.bLevel
      } else {
        return await OkkamiSdkManager.getBatteryLevel()
      }
    } catch (e) {
      return e
    }
  }

  /**
   * Returns milliseconds since boot, not counting time spent in deep sleep.
   */
  async getUptimeMillis () {
    try {
      if (Metrics.platform === 'android') {
        let uptime = await OkkamiSdkManager.getUptimeMillis()
        return moment().subtract(uptime.uptime, 'ms').fromNow(true)
      } else {
        return await moment().subtract(OkkamiSdkManager.getUptimeMillis(), 'ms').fromNow(true)
      }
    } catch (e) {
      return e
    }
  }

  /**
   * Returns WIFI signal strength and link speed in Mbps.
   */
  async getWifiSignalStrength () {
    try {
      if (Metrics.platform === 'android') {
        let s = await OkkamiSdkManager.getWifiSignalStrength()
        return s.strength
      } else {
        return await OkkamiSdkManager.getWifiSignalStrength()
      }
    } catch (e) {
      return e
    }
  }

  /**
   * Returns WIFI SSID String
   */
  async getWifiSSID () {
    try {
      if (Metrics.platform === 'android') {
        let ssid = await OkkamiSdkManager.getWifiSSID()
        return  ssid.ssid
      } else {
        return await OkkamiSdkManager.getWifiSSID()
      }
    } catch (e) {
      return e
    }
  }

  /**
   * Returns IPv4 String
   */
  async getIPv4 () {
    try {
      if (Metrics.platform === 'android') {
        let ipv4 = await OkkamiSdkManager.getIPv4()
        return ipv4.ipv4
      } else {
        return await OkkamiSdkManager.getIPv4()
      }
    } catch (e) {
      return e
    }
  }

  /**
   * Returns IPv6 String
   */
  async getIPv6 () {
    try {
      if (Metrics.platform === 'android') {
        let ipv6 = await OkkamiSdkManager.getIPv6()
        return ipv6.ipv6
      } else {
        return await OkkamiSdkManager.getIPv6()
      }
    } catch (e) {
      return e
    }
  }

  /**
   * Returns WIFI Mac Address String
   */
  async getWifiMac () {
    try {
      if (Metrics.platform === 'android') {
        let mac = await OkkamiSdkManager.getWifiMac()
        return mac.mac
      } else {
        return await OkkamiSdkManager.getWifiMac()
      }
    } catch (e) {
      return e
    }
  }

}
let okkamiSdk = new OkkamiSdk()
export default okkamiSdk

