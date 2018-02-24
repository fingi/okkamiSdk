// @flow

import React, { Component, PropTypes } from 'react'
import { ScrollView, Image, BackAndroid, View, Text, ListView, TouchableOpacity, TouchableHighlight } from 'react-native'
import Styles from './Styles/DrawerContentStyle'
import { Images, Colors, Metrics } from '../Themes'
import DrawerButton from '../Components/DrawerButton'
import { Actions as NavigationActions } from 'react-native-router-flux'
import Icon from 'react-native-vector-icons/FontAwesome'
import { connect } from 'react-redux'
import Panel from '../Components/Panel'
import UserConnectActions, { isLoggedIn } from '../Redux/UserConnectRedux'
import FacebookLoginActions from '../Redux/FacebookLoginRedux'
import Img from './Styles/Images'
import {FBLoginManager} from 'react-native-facebook-login'

class DrawerContent extends Component {

  constructor (props) {
    super(props)
    this.state = {
      login: 'llllllll',
      first_name: 'Fingi',
      last_name: 'Test',
      userImage: Img.avatar
    }
  }

  componentWillMount () {

  }

  componentDidMount () {
    BackAndroid.addEventListener('hardwareBackPress', () => {
      if (this.context.drawer.props.open) {
        this.toggleDrawer()
        return true
      }
      return false
    })
  }

  toggleDrawer () {
    this.setState({login: 'oooooooo'})
    this.context.drawer.toggle()
  }

  handlePressLogin = () => {
    this.toggleDrawer()
    NavigationActions.login()
  }

  handlePressLobby = () => {
    this.toggleDrawer()
    NavigationActions.listviewExample()
  }

  handlePressControl = () => {
    this.toggleDrawer()
    NavigationActions.presentationScreen()
  }

  handlePromotionScreen = () => {
    this.toggleDrawer()
    NavigationActions.promotionScreen()
  }

  handleWebview (url) {
    this.toggleDrawer()
    NavigationActions.openWebView({url: url})
  }

  handleLandingScreen = () => {
    this.toggleDrawer()
    NavigationActions.landingScreen()
  }

  handleVideoScreen = () => {
    this.toggleDrawer()
    NavigationActions.videoScreen()
  }

  handleApiScreen = () => {
    this.toggleDrawer()
    NavigationActions.apiScreen()
  }

  handleApiTestScreen = () => {
    this.toggleDrawer()
    NavigationActions.apiTesting()
  }

  handlePresentationScreen= () => {
    this.toggleDrawer()
    NavigationActions.presentationScreen()
  }

  handleRoomControlsScreen= () => {
    this.toggleDrawer()
    NavigationActions.roomControlsScreen()
  }

  handlePressPresent= () => {
    this.toggleDrawer()
    NavigationActions.presentationScreen()
  }

  handleFacebookLogin= () => {
    this.toggleDrawer()
    NavigationActions.facebookLoginScreen()
  }

  handlePressLogout = () => {
    this.props.logout()
    this.props.logoutStateFb()
    this.logoutFacebook()
    this.toggleDrawer()
    NavigationActions.promotionScreen({type: 'reset'})
  }

  handleEditProfile = () => {
    this.toggleDrawer()
    NavigationActions.editProfileScreen()
  }

  _renderButtonLogout = () => {
    if (this.props.loggedIn) {
      return (
        <Panel title='Logout' child='false' onPress={this.handlePressLogout}>
          <View />
        </Panel>
      )
    } else {
      return null
    }
  }

  logoutFacebook = () => {
    FBLoginManager.logout(function (error, data) {
      if (!error) {
        // _this.props.onLogout && _this.props.onLogout();
        console.log(data)
      } else {
        console.log(error, data)
      }
    })
  }

  render () {
    const { loggedIn, first_name, last_name } = this.props
    return (
      <View style={Styles.container}>

        <View style={Styles.header}>
          <View style={Styles.headerLeft}>
            <Image
              // source={{uri:'https://s3.amazonaws.com/fingi/assets/thumbnail_guest_avatar-2f5072fba40190f1114c2dd37f3bb907.png'}}
              source={this.state.userImage}
              style={Styles.avatar}
            />
          </View>
          <View style={Styles.headerRight}>
            <View style={Styles.headerRightTextTop}>
              <Text style={Styles.headerRightTextName}>Vivianne White</Text>
              <View style={{flex: 1, height: 30}}>
                {/* <Image
                  source={require('../Images/option.png')}
                  style={{width:30,height:30}}
                /> */}
                <Icon name='gear'
                  size={Metrics.icons.medium}
                  color={Colors.snow}
                  onPress={this.handleEditProfile}
                />
              </View>
            </View>
            <View style={Styles.headerRightTextButtom}>
              <Text style={Styles.headerRightTextRoom}>RM 100 | {first_name} {last_name}</Text>
            </View>

          </View>
        </View>

        <View style={Styles.mainMenu}>
          <ScrollView style={{
            flex: 1,
            backgroundColor: Colors.fire,
            paddingTop: 0}}
          >

            <Panel title='My Account' child='false' onPress={this.handleLandingScreen} >
              <TouchableHighlight underlayColor='#ffffff' onPress={this.handlePromotionScreen} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Detail account</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight underlayColor='#ffffff' onPress={this.handleLandingScreen} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Landing Screen</Text>
                </View>
              </TouchableHighlight>
            </Panel>

            <Panel title='Okkami Conclerge' child='false' onPress={this.handlePressLobby}>
              <View />
            </Panel>

            <Panel title='My Booking' child='true' >
              <TouchableHighlight underlayColor='#ffffff' onPress={this.handleWebview.bind(this, 'http://whitelabel.dohop.com/w/okkami/')} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Flights</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight underlayColor='#ffffff' onPress={this.handleWebview.bind(this, 'http://www.booking.com/?aid=1151726')} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Hotels</Text>
                </View>
              </TouchableHighlight>
              <TouchableHighlight underlayColor='#ffffff' onPress={this.handleWebview.bind(this, 'https://www.partner.viator.com/en/19488')} >
                <View style={Styles.panelRow}>
                  <Text style={Styles.panelText}>Activities</Text>
                </View>
              </TouchableHighlight>
            </Panel>
            <Panel title='Concierge Chat' child='false' onPress={this.handlePressLobby}>
              <View />
            </Panel>
            <Panel title='Check Out' child='false' onPress={this.handlePressLobby}>
              <View />
            </Panel>
            <Panel title='Languages' child='false' onPress={this.handlePressLogin}>
              <View />
            </Panel>
            {/* <Panel title="Facebook Login" child="false" onPress={this.handleFacebookLogin}>
              <View></View>
            </Panel> */}

            {this._renderButtonLogout()}

          </ScrollView>
        </View>
      </View>
    )
  }

}

DrawerContent.propTypes = {
  loggedIn: PropTypes.bool,
  logout: PropTypes.func,
  first_name: PropTypes.string,
  last_name: PropTypes.string,
  logoutStateFb: PropTypes.func
}

const mapStateToProps = (state) => {
  let first_name = (state.userConnect.userData != null) ? state.userConnect.userData.first_name : 'Guest'
  let last_name = (state.userConnect.userData != null) ? state.userConnect.userData.last_name : ''
  return {
    loggedIn: isLoggedIn(state.userConnect.userData),
    first_name: first_name,
    last_name: last_name
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    logout: () => dispatch(UserConnectActions.logout()),
    logoutStateFb: () => dispatch(FacebookLoginActions.logout())
  }
}

DrawerContent.contextTypes = {
  drawer: React.PropTypes.object
}

// export default DrawerContent
export default connect(mapStateToProps, mapDispatchToProps)(DrawerContent)
