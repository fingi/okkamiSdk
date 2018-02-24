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
import Styles from './Styles/FacebookLoginScreenStyle'
import {Images, Metrics} from '../Themes'
import Img from './Styles/Images'
import {Actions as NavigationActions} from 'react-native-router-flux'
import OkkamiSdk from 'okkami-sdk'
import ApiUserConn from '../Services/ApiUserConn'
import {FBLogin, FBLoginManager} from 'react-native-facebook-login'
import FacebookLoginActions, { isLoggedIn } from '../Redux/FacebookLoginRedux'
import UserConnectActions, { isAppToken } from '../Redux/UserConnectRedux'
import FJSON from 'format-json'

// I18n
import I18n from 'react-native-i18n'

import Dimensions from 'Dimensions'

class FacebookLoginScreen extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      user: null,
      facebookProfile: null,
      uid: null,
      appToken: null,
      userToken: null,
      wait: false
    }
  }

  facebookLogin = () => {
    const { facebookAction } = this.props
    let _this = this

    FBLoginManager.setLoginBehavior(FBLoginManager.LoginBehaviors.Native) // defaults to Native , web
    FBLoginManager.loginWithPermissions(['email', 'user_friends'], function (error, data) {
      _this.setState({wait: true})

      if (!error) {
        userProfile = JSON.parse(data.profile)
        _this.setState({ user: data.credentials, facebookProfile: userProfile})
        _this.props.attemptLogin(userProfile.name, 'xxx', userProfile)

        if (facebookAction == 'signup') {
          _this.sendCreateUser()
        } else {
          _this.sendSignInWithFacebook()
        }
      } else {
        window.alert(error.message)
        NavigationActions.promotionScreen({type: 'reset'})
      }
    })
  }

  componentWillMount () {
    this.setState({appToken: this.props.appToken})
    this.facebookLogin()
  }

  componentDidMount () {

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

  sendSignInWithFacebook = () => {
    let obj = {
      uid: this.state.facebookProfile.id
    }
    this.api = ApiUserConn.userTokenWithFacebook(obj)
    this.api['getUserTokenWithFacebook'].apply(this, ['']).then((res) => {
      // this.setState({wait:false})
      if (res.status == 200) {
        this.setState({userToken: res.data.access_token})
        this.getUserProfile()
        this.props.attemptUpdateUserToken(res.data)
        NavigationActions.landingScreen({type: 'reset'})
      } else {
        window.alert('Please check your facebook or Signup')
        NavigationActions.promotionScreen({type: 'reset'})
      }
    })
  }

  sendCreateUser = () => {
    let obj = {
      appToken: this.state.appToken,
      data: {
        user: {
          'first_name': this.state.facebookProfile.first_name,
          'last_name': this.state.facebookProfile.last_name,
          'email': this.state.facebookProfile.email,
          'password': '12345678',
          'password_confirmation': '12345678',
          'phone': '087654321',
          'country': 'Thailand',
          'country_code': 'US',
          'state': 'Nevada',
          'city': 'Las Vagas',
          'language': 'en',
          'provider': 'facebook',
          'uid': this.state.facebookProfile.id
        }
      }
    }

    this.api = ApiUserConn.createUserWithFacebook(obj)
    this.api['getCreateUserWithFacebook'].apply(this, ['']).then((res) => {
      if (res.status == 200) {
        if (res.data.status != false) {
          // updatae user data
          this.props.attemptUpdateUserData(res.data)
          NavigationActions.landingScreen({type: 'reset'})
        } else {
          window.alert(FJSON.plain(res.data.error))
          NavigationActions.promotionScreen({type: 'reset'})
        }
      } else {
        window.alert('Please check facebook')
        NavigationActions.promotionScreen({type: 'reset'})
      }
    })
  }

  handlePressSignup = () => {
    NavigationActions.signUpScreen({type: 'replace'})
  }

  handlePressLogin = () => {
    NavigationActions.landingScreen({type: 'replace'})
  }

  handleFacebookLogin = (data) => {
    username = data.profile.name
    password = 'xxx'
    facebookData = data.profile

    this.setState({ user: data.credentials, facebookProfile: data.profile})
    this.props.attemptLogin(username, password, facebookData)
    this.sendCreateUser()
  }

  handleFacebookLogout = () => {
    this.setState({ user: null, facebookProfile: null })
    this.props.logout()
    NavigationActions.promotionScreen({type: 'reset'})
  }

  handleFacebookLoginFound = (data) => {
    console.log('Existing login found.')
    console.log(data)
    this.setState({ user: data.credentials})
  }

  handleFacebookLoginNotFound = () => {
    console.log('No user logged in.')
    this.setState({ user: null })
  }

  handleFacebookLoginError = (data) => {
    console.log('ERROR')
    console.log(data)
  }

  handleFacebookLoginCancel = (data) => {
    console.log('User cancelled.')
  }

  handleFacebookLoginPermissionsMissing = (data) => {
    console.log('Check permissions!')
    console.log(data)
  }

  _renderWait = () => {
    if (this.state.wait) {
      console.log('Render wait')
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
    return (

      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />

        <ScrollView style={Styles.container} >
          <View style={Styles.formOver}>

            {/* <FBLogin
              ref={(fbLogin) => { this.fbLogin = fbLogin }}
              permissions={["email","user_friends","public_profile"]}
              loginBehavior={FBLoginManager.LoginBehaviors.Native}
              onLogin={(data) => this.handleFacebookLogin(data)}
              onLogout={() => this.handleFacebookLogout()}
              onLoginFound={(data) => this.handleFacebookLoginFound(data)}
              onLoginNotFound={() => this.handleFacebookLoginNotFound()}
              onError={(data) => this.handleFacebookLoginError(data)}
              onCancel={() => this.handleFacebookLoginCancel()}
              onPermissionsMissing={() => this.handleFacebookLoginPermissionsMissing()}
            /> */}

          </View>
        </ScrollView>

        {this._renderWait()}

      </View>
    )
  }

}

FacebookLoginScreen.propTypes = {
  loggedIn: PropTypes.bool,
  logout: PropTypes.func,
  username: PropTypes.string,
  facebookData: PropTypes.object,
  appToken: PropTypes.string,
  facebookAction: PropTypes.string
}

FacebookLoginScreen.defaultProps = {

}

const mapStateToProps = state => {
  let appToken = (state.userConnect.appToken != null) ? state.userConnect.appToken.access_token : null
  return {
    loggedIn: isLoggedIn(state.facebookLogin),
    username: state.facebookLogin.username,
    facebookData: state.facebookLogin.facebookData,
    appToken: appToken
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    logout: () => dispatch(FacebookLoginActions.logout()),
    attemptUpdateUserData: (userData) => dispatch(UserConnectActions.userConnectUserData(userData)),
    attemptUpdateUserToken: (userToken) => dispatch(UserConnectActions.userConnectUserToken(userToken)),
    attemptLogin: (username, password, facebookData) => dispatch(FacebookLoginActions.facebookLoginRequest(username, password, facebookData))
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(FacebookLoginScreen)
