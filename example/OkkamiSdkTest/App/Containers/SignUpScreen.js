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
  Picker,
  ActivityIndicator
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/SignUpScreenStyle'
import Img from './Styles/Images'
// import { Metrics } from '../Themes'
import {Actions as NavigationActions} from 'react-native-router-flux'
import ModalPicker from '../Components/Picker'
import ApiUserConn from '../Services/ApiUserConn'
import UserConnectActions, { isAppToken, isLoggedIn } from '../Redux/UserConnectRedux'
import FacebookLoginActions from '../Redux/FacebookLoginRedux'
import FJSON from 'format-json'
import {FBLoginManager} from 'react-native-facebook-login'


// I18n
import I18n from 'react-native-i18n'

class SignUpScreen extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selectLanguage: '',
      first_name: 'yo',
      last_name: 'fingi',
      email: 'yo@fingi.com',
      password: '12345678',
      password_confirmation: '12345678',
      phone: '0877777777',
      avatar: '',
      country: 'Thailand',
      state: 'thai',
      city: 'bangkok',
      response: '',
      wait: false,
      appToken:null,
      userToken:null,
    }
  }

  componentWillReceiveProps (newProps) {
  }

  componentWillMount () {
    this.logoutFacebook()

    if(!this.props.appTokenStatus){
      this.getAppToken()
    }else{
      this.setState({appToken:this.props.appToken})
    }
  }

  componentWillUnmount () {

  }

  getAppToken = () => {
    let obj = {}
    this.api = ApiUserConn.appToken(obj)
    this.api['getAppToken'].apply(this, ['']).then((res)=>{
      if(res.status == 200){
        this.setState({appToken: res.data.access_token})
        this.props.attemptAppToken(res.data)
      }
    })
  }

  createUser = () => {
    let obj = {
      appToken: this.state.appToken,
      data: {
        user:{
          "first_name" : this.state.first_name,
          "last_name":  this.state.last_name,
          "email":  this.state.email,
          "password" : this.state.password,
          "password_confirmation":  this.state.password_confirmation,
          "phone":  this.state.phone,
          "country":  this.state.country,
          "state":  this.state.state,
          "city" : this.state.city,
          "language" : this.state.language
        }
      }
    }

    this.api = ApiUserConn.appCreateUser(obj)
    this.api['getCreateUser'].apply(this, ['']).then((res)=>{
      this.setState({wait: false}) //Close wait
      if(res.status == 200){
        // attemptUser
        if(res.data.status != false){
          //updatae user data
          this.props.attemptUpdateUserData(res.data)
          window.alert(FJSON.plain(res.data))
          NavigationActions.landingScreen({type: "reset"});
        }else{
          this.logoutFacebook()
          this.props.logoutStateFb()
          window.alert(FJSON.plain(res.data.error))
        }
      }else{
        this.logoutFacebook()
        this.props.logoutStateFb()
        window.alert(FJSON.plain(res))
      }
    })
  }

  handlePressLogin = () => {
    this.setState({wait: true})
    this.createUser()
  }

  handleChangeFirstname = (text) => {
    this.setState({ first_name: text })
  }

  handleChangeLastname = (text) => {
    this.setState({ last_name: text })
  }

  handleChangeEmail = (text) => {
    this.setState({ email: text })
  }

  handleChangePassword = (text) => {
    this.setState({ password: text })
  }

  handleChangePasswordConfirmation = (text) => {
    this.setState({ password_confirmation: text })
  }

  handleChangePhone = (text) => {
    this.setState({ phone: text })
  }

  handleChangeAvatar= (text) => {
    this.setState({ avatar: text })
  }

  handleChangeCountry = (text) => {
    this.setState({ country: text })
  }

  handleChangeState = (text) => {
    this.setState({ state: text })
  }

  handleChangeCity = (text) => {
    this.setState({ city: text })
  }

  _renderWait = () => {
    if(this.state.wait){
      return (
        <View style={Styles.indicatorView}>
          <ActivityIndicator
            color="#EA4335"
            // animating={this.state.wait}
            style={[{'transform': [{scale: 1.5}]}]}
            size="large"
             />
        </View>
      )
    }else{
      return null
    }
  }

  logoutFacebook = () => {
    FBLoginManager.logout(function(error, data){
      if (!error) {
        // _this.props.onLogout && _this.props.onLogout();
        console.log(data)
      } else {
        console.log(error, data);
      }
    });
  }

  render() {
    const {
      first_name,
      last_name ,
      email,
      password,
      password_confirmation,
      phone,
      avatar,
      country,
      state,
      city
    } = this.state

    let index = 0;
    const data = [
        { key: '', section: true, label: 'Prefer Languages' },
        { key: 'en', label: 'English' },
        { key: 'ch', label: 'Chinese' },
        { key: 'jp', label: 'Japanese' },
        { key: 'ru', label: 'Russian' },
    ];

    const { appTokenStatus, loggedIn, appToken } = this.props

    if(loggedIn){
      console.log('User login')
    }else{
      console.log('User not login [' + appToken +']')
    }

    return (
      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />

        <ScrollView style={Styles.container} >
          <View style={Styles.formOver}>
            <View style={{justifyContent: 'center'}}>
              <TextInput
                ref='email'
                value={email}
                style={Styles.textInput}
                keyboardType='email-address'
                placeholder='Email'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangeEmail}
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
              <TextInput
                ref='password_confirmation'
                value={password_confirmation}
                style={Styles.textInput}
                keyboardType='default'
                placeholder='Password confirmation'
                secureTextEntry
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangePasswordConfirmation}
                returnKeyType='next' />
              <TextInput
                ref='first_name'
                value={first_name}
                style={Styles.textInput}
                keyboardType='default'
                placeholder='First name'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangeFirstname}
                returnKeyType='next' />
              <TextInput
                ref='last_name'
                value={last_name}
                style={Styles.textInput}
                keyboardType='default'
                placeholder='Last name'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangeLastname}
                returnKeyType='next' />
              <TextInput
                ref='phone'
                value={phone}
                style={Styles.textInput}
                keyboardType='phone-pad'
                placeholder='Phone'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangePhone}
                returnKeyType='next' />
              <TextInput
                ref='country'
                value={country}
                style={Styles.textInput}
                keyboardType='default'
                placeholder='Country'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangeCountry}
                returnKeyType='next' />
              <TextInput
                ref='state'
                value={state}
                style={Styles.textInput}
                keyboardType='default'
                placeholder='State'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangeState}
                returnKeyType='next' />
              <TextInput
                ref='city'
                value={city}
                style={Styles.textInput}
                keyboardType='default'
                placeholder='City'
                underlineColorAndroid='transparent'
                onChangeText={this.handleChangeCity}
                returnKeyType='next' />

            </View>

            <ModalPicker
                style={Styles.selectInput}
                selectTextStyle={Styles.sectionTextStyle}
                sectionTextStyle={Styles.sectionTextStyle}
                selectStyle={{height:100}}
                data={data}
                initValue="Prefer Languages"
                onChange={(lang) => this.setState({selectLanguage: lang.key})} />

            <TouchableOpacity style={Styles.buttonSnow} onPress={NavigationActions.socialConnectionScreen}>
              <Text style={Styles.buttonTextSnow}>Social Connection</Text>
            </TouchableOpacity>
            <TouchableOpacity style={Styles.buttonSnow} onPress={NavigationActions.uploadPictureScreen}>
              <Text style={Styles.buttonTextSnow}>Avatar/Picture</Text>
            </TouchableOpacity>
            <TouchableOpacity style={Styles.buttonCreate} onPress={this.handlePressLogin}>
              <Text style={Styles.buttonText}>Create</Text>
            </TouchableOpacity>

          </View>
        </ScrollView>

        {this._renderWait()}

      </View>

    )
  }

}

SignUpScreen.propTypes = {
  appTokenStatus: PropTypes.bool,
  loggedIn: PropTypes.bool,
  appToken: PropTypes.string,
  logoutStateFb: PropTypes.func,
}

SignUpScreen.defaultProps = {

}

const mapStateToProps = state => {
  let appToken = (state.userConnect.appToken != null)?state.userConnect.appToken.access_token:null
  return {
    appTokenStatus: isAppToken(state.userConnect),
    loggedIn: isLoggedIn(state.userConnect.userData),
    appToken: appToken
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    logout: () => dispatch(UserConnectActions.logout()),
    logoutStateFb: () => dispatch(FacebookLoginActions.logout()),
    attemptUpdateUserData: (userData) => dispatch(UserConnectActions.userConnectUserData(userData)),
    attemptAppToken: (appToken) => dispatch(UserConnectActions.userConnectRequest(appToken))
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SignUpScreen)