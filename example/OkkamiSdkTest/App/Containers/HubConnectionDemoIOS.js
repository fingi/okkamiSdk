// @flow

import React from 'react'
import { ScrollView, Text, Image, View, KeyboardAvoidingView } from 'react-native'
import { connect } from 'react-redux'
// Add Actions - replace 'Your' with whatever your reducer is called :)
// import YourActions from '../Redux/YourRedux'
import { Metrics } from '../Themes'
// external libs
import RoundedButton from '../Components/RoundedButton'
import Icon from 'react-native-vector-icons/FontAwesome'
import Animatable from 'react-native-animatable'
import { Actions as NavigationActions } from 'react-native-router-flux'
import OkkamiSdk from 'okkami-sdk'

// Styles
import styles from './Styles/HubConnectionDemoIOSStyle'

// I18n
import I18n from 'react-native-i18n'
import {DeviceEventEmitter} from 'react-native'

var subscriptions = Array()

class HubConnectionDemoIOS extends React.Component {

  constructor (props) {
    super(props)
    this.preconnect()
  }
  async preconnect () {
    try {
      var result = await OkkamiSdk.start()
      console.log('preconnect successful...' + result)
    } catch (e) {
      console.log('preconnect failed . error : ' + e.message)
    }
  }
  componentWillMount () {
    console.log('subscribe here')

    aSubscription = DeviceEventEmitter.addListener('onStart', function (e) {
      console.log('Command --> ', e, e.command)
    })

    aSubscription = DeviceEventEmitter.addListener('connectToRoom', function (e) {
      console.log('Command --> ', e, e.command)
    })

    aSubscription = DeviceEventEmitter.addListener('disconnectFromRoom', function (e) {
      console.log('Command --> ', e, e.command)
    })

    aSubscription = DeviceEventEmitter.addListener('onHubCommand', function (e) {
      console.log('Command -->', e, e.currentData)
    })

    aSubscription = DeviceEventEmitter.addListener('onHubLoggedIn', function (e) {
      console.log('Command --> ', e, e.command)
    })

    aSubscription = DeviceEventEmitter.addListener('downloadPresets', function (e) {
      console.log('Command --> ', e, e.command)
    })

    aSubscription = DeviceEventEmitter.addListener('downloadRoomInfo', function (e) {
      console.log('Command --> ', e, e.command)
    })

    aSubscription = DeviceEventEmitter.addListener('guestService', function (e) {
      console.log('Command --> ', e, e.command)
    })

    subscriptions.push(aSubscription)
  }

  componentWillUnmount () {
    console.log('unsubscribe here')
    for (var i = 0; i < subscriptions.length; i++) {
      subscriptions[i].remove()
    }
  }

  connectToHub () {
    /* <RoundedButton onPress={NavigationActions.HubConnectionEventDemoIOS}>
            Hub Connection Event Demo IOS
          </RoundedButton>

      try {
        var result = OkkamiSdk.connectToHub();
        console.log("connectToHub successful..." + result );

      } catch (e) {
        console.log("connectToHub failed . error : " + e.message)
      } */
    try {
      var result = OkkamiSdk.connectToHub()
      console.log('connectToHub successful...' + result)

        /* aSubscription = DeviceEventEmitter.addListener('onHubConnected', function (e) {
            console.log('onHubCommand --> ',e, e.currentData)
        });
        subscriptions.push(aSubscription) */
    } catch (e) {
      console.log('connectToHub failed . error : ' + e.message)
    }
  }
  disconnectFromHub () {
    try {
      var result = OkkamiSdk.disconnectFromHub()
      console.log('disconnectFromHub successful...' + result)
    } catch (e) {
      console.log('disconnectFromHub failed . error : ' + e.message)
    }
  }
  sendCommandToHub () {
    try {
      var result = OkkamiSdk.sendCommandToHub('Power')
//        var hubLoggedIn = await OkkamiSdk.isHubLoggedIn();
      console.log('sendCommandToHub successful...' + result)
    } catch (e) {
      console.log('sendCommandToHub failed . error : ' + e.message)
    }
  }

  isHubLoggedIn () {
    try {
      var result = OkkamiSdk.isHubLoggedIn()
      console.log('onHubLoggedIn successful...' + result)

        /* aSubscription = DeviceEventEmitter.addListener('onHubLoggedIn', function (e) {
          console.log('onHubCommand --> ',e, e.command)
        });

        subscriptions.push(aSubscription) */
    } catch (e) {
      console.log('onHubLoggedIn failed . error : ' + e.message)
    }
  }
  isHubConnected () {
    try {
      var result = OkkamiSdk.isHubConnected()
      console.log('onHubConnected successful...' + result)
    } catch (e) {
      console.log('onHubConnected failed . error : ' + e.message)
    }
  }

  connectToRoom () {
    try {
      var result = OkkamiSdk.connectToRoom()
      console.log('connectToRoom successful...' + result)
    } catch (e) {
      console.log('connectToRoom failed . error : ' + e.message)
    }
  }

  disconnectFromRoom () {
    try {
      var result = OkkamiSdk.disconnectFromRoom()
      console.log('disconnectToRoom successful...' + result)
    } catch (e) {
      console.log('disconnectToRoom failed . error : ' + e.message)
    }
  }
  /* preconnect(){
    try {
        var result = OkkamiSdk.start();
        console.log("preconnect successful..." + result );

      } catch (e) {
        console.log("preconnect failed . error : " + e.message)
    }
  } */

  downloadPresets () {
    try {
      var result = OkkamiSdk.downloadPresets(1)
      console.log('downloadPresets successful...' + result)
    } catch (e) {
      console.log('downloadPresets failed . error : ' + e.message)
    }
  }
  downloadRoomInfo () {
    try {
      var result = OkkamiSdk.downloadRoomInfo(1)
      console.log('downloadRoomInfo successful...' + result)
    } catch (e) {
      console.log('downloadRoomInfo failed . error : ' + e.message)
    }
  }
  guestService () {
    try {
      var result = OkkamiSdk.connectToHub()
      console.log('guestService successful...' + result)
    } catch (e) {
      console.log('guestService failed . error : ' + e.message)
    }
  }
  /* <RoundedButton onPress={this.preconnect}>
            preconnect
          </RoundedButton>
          <RoundedButton onPress={this.connectToHub}>
            Connect To Hub
          </RoundedButton>

          <RoundedButton onPress={this.disconnectFromHub}>
            Disconnect From Hub
          </RoundedButton>

          <RoundedButton onPress={this.sendCommandToHub}>
            Send Command To Hub
          </RoundedButton>

          <RoundedButton onPress={this.isHubLoggedIn}>
            Is Hub Logged In
          </RoundedButton>

          <RoundedButton onPress={this.isHubConnected}>
            Is Hub Connected
          </RoundedButton>
          */
  render () {
    return (
      <View style={styles.mainContainer}>
        <ScrollView style={styles.container}>

          <RoundedButton onPress={this.connectToRoom}>
            Connect To Room
          </RoundedButton>

          <RoundedButton onPress={this.disconnectFromRoom}>
            Disconnect To Room
          </RoundedButton>

          <RoundedButton onPress={this.downloadPresets}>
            Download Presets
          </RoundedButton>

          <RoundedButton onPress={this.downloadRoomInfo}>
            Download Room Info
          </RoundedButton>

          <RoundedButton onPress={this.guestService}>
            Guest Service
          </RoundedButton>

        </ScrollView>
      </View>
    )
  }

}

const mapStateToProps = (state) => {
  return {
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(HubConnectionDemoIOS)
