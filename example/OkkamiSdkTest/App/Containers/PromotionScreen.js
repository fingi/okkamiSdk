import React, {PropTypes} from 'react'
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/PromotionScreenStyle'
import {Images, Metrics} from '../Themes'
import {Actions as NavigationActions} from 'react-native-router-flux'
import Swiper from 'react-native-swiper'
import { isAppToken, isLoggedIn } from '../Redux/UserConnectRedux'
import {FBLoginManager} from 'react-native-facebook-login'

// I18n
import I18n from 'react-native-i18n'

class PromotionScreen extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      items: []
    }
  }

  componentWillMount () {
    const {loggedIn } = this.props
    let _this = this
    if (loggedIn) {
      NavigationActions.landingScreen({type: 'reset'})
    } else {
    //   FBLoginManager.logout(function(error, data){
    //     if (!error) {
    //       // _this.props.onLogout && _this.props.onLogout();
    //       console.log(data)
    //     } else {
    //       console.log(error, data);
    //     }
    //   });
    }
  }

  componentDidMount () {
    this.setState({
      items: [
        { title: 'Title 1', image: require('../Images/promotion/okkami_slide_01.jpg') },
        { title: 'Title 2', image: require('../Images/promotion/okkami_slide_02.jpg') },
        { title: 'Title 3', image: require('../Images/promotion/okkami_slide_03.jpg') },
        { title: 'Title 4', image: require('../Images/promotion/okkami_slide_04.jpg') }
      ]
    })
  }

  render () {
    return (
      <View style={Styles.container}>
        <Swiper showsButtons autoplay dotColor={'#ffffff'} loop autoplayTimeout={5} height={Metrics.screenHeight - 50}>
          {this.state.items.map((item, key) => {
            return (
              <View key={key} style={Styles.slide} >
                <Image
                  // source={{uri:'https://s3.amazonaws.com/fingi/assets/thumbnail_guest_avatar-2f5072fba40190f1114c2dd37f3bb907.png'}}
                  source={item.image}
                  style={Styles.slideImage}
                />
              </View>
            )
          })}
        </Swiper>
        <View style={Styles.mainButton} >
          <TouchableOpacity style={Styles.button} onPress={NavigationActions.signUpScreen}>
            <Text style={Styles.buttonText}>Sign Up</Text>
          </TouchableOpacity>
          <TouchableOpacity style={Styles.button} onPress={NavigationActions.signInScreen}>
            <Text style={Styles.buttonText}>Sign In</Text>
          </TouchableOpacity>
        </View>
      </View>

    )
  }

}

PromotionScreen.propTypes = {
  loggedIn: PropTypes.bool,
  onLogout: PropTypes.func
}

const mapStateToProps = (state) => {
  return {
    loggedIn: isLoggedIn(state.userConnect.userData)
  }
}

const mapDispatchToProps = (dispatch) => {
  return {

  }
}

export default connect(mapStateToProps, mapDispatchToProps)(PromotionScreen)
