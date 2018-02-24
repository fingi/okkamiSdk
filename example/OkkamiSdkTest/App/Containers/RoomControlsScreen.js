import React, {PropTypes} from 'react'
import {
  View,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  Switch,
  DeviceEventEmitter
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/RoomControlsScreenStyle'
import Img from './Styles/Images'
import { Images, Colors, Metrics } from '../Themes'
import {Actions as NavigationActions} from 'react-native-router-flux'
import ModalPicker from '../Components/Picker'
import Icon from 'react-native-vector-icons/FontAwesome'
import OkkamiSdk from 'okkami-sdk'

// I18n
import I18n from 'react-native-i18n'

handlePress = () => {
  // command
}

class RoomControlsScreen extends React.Component {

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

    this.state = {
      selectLanguage: '',
      light6: false,
      ac1: false,
      ac1Setpoint: '0',
      ac1Speed: 'LOW',
      tvPower: false
    }
  }

  componentWillMount () {
    console.log('subscribe here')
    aSubscription = DeviceEventEmitter.addListener('onHubCommand', function (e) {
      console.log('onHubCommand --> ', e, e.command)
    })

    this.subscriptions.push(aSubscription)
  }

  componentWillUnmount () {
    console.log('unsubscribe here')
    for (var i = 0; i < this.subscriptions.length; i++) {
      // subscriptions[i].remove();
    }
  }

  // componentWillMount() {
  //   var _myself = this;
  //   DeviceEventEmitter.addListener('onHubCommand', function (e) {
  //     console.log(e);

  //     if (e.command.indexOf('light-6 ON') != -1) {
  //       _myself.setState({light6: true});
  //     } else if (e.command.indexOf('light-6 OFF') != -1) {
  //       _myself.setState({light6: false});
  //     } else if (e.command.indexOf('ac-1 ON') != -1) {
  //       _myself.setState({ac1: true});
  //     } else if (e.command.indexOf('ac-1 OFF') != -1) {
  //       _myself.setState({ac1: false});
  //     } else if (e.command.indexOf('THERMOSTAT ac-1') != -1) {
  //       var temp = e.command.lastIndexOf(' ') + 1;
  //       _myself.setState({ac1Setpoint: temp});
  //     } else if (e.command.indexOf('FAN ac-1') != -1) {
  //       var speed = e.command.lastIndexOf(' ') + 1;
  //       _myself.setState({ac1Speed: speed});
  //     }

  //   });
  // }

  render () {
    return (

      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />

        <ScrollView style={Styles.container} >
          <View style={Styles.formOver}>

            <View style={Styles.formButton}>
              <Text style={{fontSize: 18, color: Colors.snow, fontWeight: 'bold'}}>
                Meeting room ( Light-6 )
              </Text>
              <Switch
                onValueChange={(value) => {
                  this.setState({light6: value})
                }}
                value={this.state.light6} />
            </View>

            <View style={Styles.formButton}>
              <Text style={{fontSize: 18, color: Colors.snow, fontWeight: 'bold'}}>
                AC Meeting Room ( ac-1 )
              </Text>
              <Switch
                onValueChange={(value) => {
                  // command
                  // this.setState({ac1: value});
                }}
                value={this.state.ac1} />
            </View>

            <View style={Styles.spaceLine} />

            <View style={Styles.formButton}>
              <Text style={{fontSize: 18, color: Colors.snow, fontWeight: 'bold'}}>
                TV Innvue Power ( tv-2 )
              </Text>
              <Switch
                onValueChange={(value) => {
                  // command
                  // this.setState({tvPower: value});
                }}
                value={this.state.tvPower} />
            </View>

            <View style={Styles.formButton}>
              <Text style={{fontSize: 18, color: Colors.snow, fontWeight: 'bold'}}>
                Volume ( tv-2 )
              </Text>
              <View style={{flex: 1, flexDirection: 'row', justifyContent: 'space-between', marginLeft: 20}}>

                <TouchableOpacity onPress={this.handlePress} >
                  <Icon name='volume-up'
                    size={Metrics.icons.medium}
                    color={Colors.snow}
                  />
                </TouchableOpacity>
                <TouchableOpacity onPress={this.handlePress} >
                  <Icon name='volume-down'
                    size={Metrics.icons.medium}
                    color={Colors.snow}
                  />
                </TouchableOpacity>
                <TouchableOpacity onPress={this.handlePress} >
                  <Icon name='volume-off'
                    size={Metrics.icons.medium}
                    color={Colors.snow}
                  />
                </TouchableOpacity>

              </View>
            </View>

            <View style={Styles.formButton}>
              <Text style={{fontSize: 18, color: Colors.snow, fontWeight: 'bold'}}>
                CHANNEL ( tv-2 )
              </Text>
              <View style={{flex: 1, flexDirection: 'row', justifyContent: 'space-between', marginLeft: 20}}>

                <TouchableOpacity onPress={this.handlePress} >
                  <Icon name='angle-up'
                    size={Metrics.icons.medium}
                    color={Colors.snow}
                  />
                </TouchableOpacity>
                <TouchableOpacity onPress={this.handlePress} >
                  <Icon name='angle-down'
                    size={Metrics.icons.medium}
                    color={Colors.snow}
                  />
                </TouchableOpacity>

              </View>
            </View>

            <View style={Styles.formButton}>
              <Text style={{fontSize: 18, color: Colors.snow, fontWeight: 'bold'}}>
                DIRECTIONAL ( tv-2 )
              </Text>
              <View style={{flex: 1, flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>

                <View style={{flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}>
                  <TouchableOpacity onPress={this.handlePress}>
                    <Icon name='angle-up'
                      size={Metrics.icons.large}
                      color={Colors.snow}
                    />
                  </TouchableOpacity>
                </View>
                <View style={{flex: 1, flexDirection: 'row', justifyContent: 'space-between' }}>
                  <TouchableOpacity style={{padding: 10, marginRight: 20}} onPress={this.handlePress}>
                    <Icon name='angle-left'
                      size={Metrics.icons.large}
                      color={Colors.snow}
                    />
                  </TouchableOpacity>
                  <TouchableOpacity style={{padding: 10}} onPress={this.handlePress}>
                    <Icon name='check'
                      size={Metrics.icons.medium}
                      color={Colors.snow}
                    />
                  </TouchableOpacity>
                  <TouchableOpacity style={{padding: 10, marginLeft: 20}} onPress={this.handlePress}>
                    <Icon name='angle-right'
                      size={Metrics.icons.large}
                      color={Colors.snow}
                    />
                  </TouchableOpacity>
                </View>

                <View style={{flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}>
                  <TouchableOpacity onPress={this.handlePress}>
                    <Icon name='angle-down'
                      size={Metrics.icons.large}
                      color={Colors.snow}
                    />
                  </TouchableOpacity>
                </View>

              </View>
            </View>

          </View>

        </ScrollView>

      </View>

    )
  }

}

RoomControlsScreen.propTypes = {
  // commandToRoomRequest: PropTypes.func
}

RoomControlsScreen.defaultProps = {
  // sendingCommand: false,
}

const mapStateToProps = state => {
  return {
    // sendingCommand: state.fingiSdk.sendingCommand,
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    // commandToRoomRequest: (command) => dispatch(OkkamiSdk.commandToRoomRequest(command))
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(RoomControlsScreen)
