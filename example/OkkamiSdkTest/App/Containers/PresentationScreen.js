// @flow

import React from 'react'
import {ScrollView, Text, Image, View} from 'react-native'
import {Images} from '../Themes'
import RoundedButton from '../Components/RoundedButton'
import {Actions as NavigationActions} from 'react-native-router-flux'
import OkkamiSdk from 'okkami-sdk'

import {DeviceEventEmitter} from 'react-native'

// Styles
import styles from './Styles/PresentationScreenStyle'

export default class PresentationScreen extends React.Component {

  subscriptions = [];

  constructor (props) {
    super(props);

    /* ----a sample for how to use the sdk calls :) --- */
    (async function () {
      try {
        console.log('calling : connectToHub')
        var result = await OkkamiSdk.connectToHub()
      } catch (e) {
        console.log('connectToRoom failed . error : ' + e.message)
      }
    })()// call myself !
  }

  componentWillMount () {
    console.log('subscribe here')
    aSubscription = DeviceEventEmitter.addListener('onHubCommand', function (e) {
      console.log('onHubCommand --> ', e, e.command)
    })

    this.subscriptions.push(aSubscription)
  }

  componentWillUnmount () {
    console.log('unsubscribe here ' + this.subscriptions.length)
    for (var i = 0; i < this.subscriptions.length; i++) {
      // subscriptions[i].remove();
    }
  }

  render () {
    return (
      <View style={styles.mainContainer}>
        <Image source={Images.background} style={styles.backgroundImage} resizeMode='stretch' />
        <ScrollView style={styles.container}>
          <View style={styles.centered}>
            <Image source={Images.clearLogo} style={styles.logo} />
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionText}>
              Default screens for development, debugging, and alpha testing
              are available below.
            </Text>
          </View>

          <RoundedButton onPress={NavigationActions.componentExamples}>
            Component Examples Screen
          </RoundedButton>

          <RoundedButton onPress={NavigationActions.usageExamples}>
            Usage Examples Screen
          </RoundedButton>

          <RoundedButton onPress={NavigationActions.apiTesting}>
            API Testing Screen
          </RoundedButton>

          <RoundedButton onPress={NavigationActions.theme}>
            Theme Screen
          </RoundedButton>

          <RoundedButton onPress={NavigationActions.deviceInfo}>
            Device Info Screen
          </RoundedButton>

          <View style={styles.centered}>
            <Text style={styles.subtitle}>Made with ❤️ by Infinite Red</Text>
          </View>

        </ScrollView>
      </View>
    )
  }
}
