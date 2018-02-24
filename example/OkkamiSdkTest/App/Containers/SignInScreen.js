import React, {PropTypes} from 'react'
import {
  View,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  Keyboard,
  LayoutAnimation,
  ActivityIndicator
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/SignInScreenStyle'
import {Images, Metrics} from '../Themes'
import Img from './Styles/Images'
import {Actions as NavigationActions} from 'react-native-router-flux'
import Video from 'react-native-video'
import OkkamiSdk from 'okkami-sdk'
import KeyboardSpacer from 'react-native-keyboard-spacer'
import ApiUserConn from '../Services/ApiUserConn'
import UserConnectActions, { isAppToken, isLoggedIn } from '../Redux/UserConnectRedux'
import FacebookLoginActions from '../Redux/FacebookLoginRedux'
import {FBLoginManager} from 'react-native-facebook-login'

// I18n
import I18n from 'react-native-i18n'

import Dimensions from 'Dimensions'

class SignInScreen extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      username: 'yo24@fingi.com',
      password: '012345678',
      selectLanguage: 'en',
      paused: false,
      rate: 1,
      volume: 1,
      muted: false,
      resizeMode: 'cover', // cover contain stretch
      duration: 0.0,
      currentTime: 0.0,
      wait: false,
      userToken: null
    }
    this.isAttempting = false
  }

  componentWillMount () {
    this.logoutFacebook()
    this.props.logoutStateFb()
  }

  handlePressSignup = () => {
    NavigationActions.signUpScreen({type: 'replace'})
  }

  getUserProfile = () => {
    let obj = {
      userToken: this.state.userToken
    }
    this.api = ApiUserConn.appUserProfile(obj)
    this.api['getProfile'].apply(this, ['']).then((res) => {
      if (res.status == 200) {
        this.props.attemptUpdateUserData(res.data)
      } else {
        window.alert('Cannot update profile')
      }
    })
  }

  sendSignIn = () => {
    let obj = {
      email: this.state.username,
      password: this.state.password
    }
    this.api = ApiUserConn.userToken(obj)
    this.api['getUserToken'].apply(this, ['']).then((res) => {
      this.setState({wait: false})
      if (res.status == 200) {
        this.setState({userToken: res.data.access_token})
        this.getUserProfile()
        this.props.attemptUpdateUserToken(res.data)
        NavigationActions.landingScreen({type: 'reset'})
      } else {
        window.alert('Please check Username and Password')
      }
    })
  }

  handlePressLogin = () => {
    const {username, password} = this.state
    this.isAttempting = true
    // this.props.attemptLogin(username, password)
    if ((username != null) && (password != null)) {
      this.setState({wait: true})
      this.sendSignIn()
    } else {
      window.alert('Please check Username and Password')
    }
    // NavigationActions.landingScreen({type: "replace"})
  }

  renderLoginButton () {
    return (
      <TouchableOpacity style={Styles.buttonFireSplitTwo} onPress={this.handlePressLogin} >
        <Text style={Styles.buttonText}>Sign In</Text>
      </TouchableOpacity>
    )
  }

  renderLogoutButton () {
    return (
      <TouchableOpacity style={Styles.buttonFireSplitTwo} onPress={this.props.logout} >
        <Text style={Styles.buttonText}>Sign Out</Text>
      </TouchableOpacity>
    )
  }

  handleChangeUsername = (text) => {
    this.setState({ username: text })
  }

  handleChangePassword = (text) => {
    this.setState({ password: text })
  }

  handlePressFacebookLogin = () => {
    this.setState({wait: false})
    NavigationActions.facebookLoginScreen({type: 'replace'})
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

  _renderWait = () => {
    if (this.state.wait) {
      return (
        <View style={Styles.indicatorView}>
          <ActivityIndicator
            color='#EA4335'
            style={[{'transform': [{scale: 1.5}]}]}
            size='large'
             />
        </View>
      )
    } else {
      return null
    }
  }

  render () {
    const {username, password} = this.state
    const { loggedIn } = this.props

    return (

      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />

        <TouchableOpacity style={Styles.backgroundVideo} onPress={() => { this.setState({paused: !this.state.paused}) }}>
          {/* <Video source={{uri:'https://www.fingi.com/wp-content/uploads/2014/28/Aloft%20BKK%207%20FEB12.mov%20-%20Batch%20upload-20120207.mp4'}}  */}
          <Video source={Img.videoBg}
            style={Styles.backgroundVideo}
            rate={this.state.rate}
            paused={this.state.paused}
            volume={this.state.volume}
            muted={this.state.muted}
            resizeMode={this.state.resizeMode}
              // onLoad={this.onLoad}
              // onProgress={this.onProgress}
            onEnd={() => { console.log('Done!') }}
            repeat={false} />
        </TouchableOpacity>

        <ScrollView style={Styles.container} >
          <View style={Styles.formOver}>
            <Image
              source={require('../Images/avatar.png')}
              style={Styles.avatar}
          />
            <TextInput
              ref='username'
              value={username}
              style={Styles.textInput}
              keyboardType='default'
              placeholder='Username or Email'
              underlineColorAndroid='transparent'
              onChangeText={this.handleChangeUsername}
              returnKeyType='next' />

            <TextInput
              ref='password'
              value={password}
              style={Styles.textInput}
              keyboardType='default'
              placeholder='Password'
              secureTextEntry
              underlineColorAndroid='transparent'
              onChangeText={this.handleChangePassword}
              returnKeyType='next' />

            <View style={Styles.formButton}>
              <TouchableOpacity style={Styles.buttonFireSplitTwo} onPress={this.handlePressSignup} >
                <Text style={Styles.buttonText}>Sign Up</Text>
              </TouchableOpacity>

              {/* TODO login to core */}
              {/* <TouchableOpacity style={Styles.buttonFireSplitTwo} onPress={this.handlePressLogin} >
              <Text style={Styles.buttonText}>Sign In</Text>
            </TouchableOpacity> */}
              {loggedIn ? this.renderLogoutButton() : this.renderLoginButton()}
            </View>

            {/* <TouchableOpacity style={Styles.buttonFire} onPress={NavigationActions.login} >
            <Text style={Styles.buttonText}>Social Login</Text>
          </TouchableOpacity> */}
            <TouchableOpacity style={Styles.buttonFacebook} onPress={this.handlePressFacebookLogin} >
              <Text style={Styles.buttonText}>Facebook Login</Text>
            </TouchableOpacity>

            <KeyboardSpacer />

          </View>
        </ScrollView>

        {this._renderWait()}

      </View>
    )
  }

}

SignInScreen.propTypes = {
  loggedIn: PropTypes.bool,
  logout: PropTypes.func,
  user_name: PropTypes.string,
  logoutStateFb: PropTypes.func
}

SignInScreen.defaultProps = {

}

const mapStateToProps = state => {
  return {
    loggedIn: isLoggedIn(state.userConnect.userData)
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    logoutStateFb: () => dispatch(FacebookLoginActions.logout()),
    logout: () => dispatch(UserConnectActions.logout()),
    attemptUpdateUserData: (userData) => dispatch(UserConnectActions.userConnectUserData(userData)),
    attemptUpdateUserToken: (userToken) => dispatch(UserConnectActions.userConnectUserToken(userToken))
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SignInScreen)
