import React from 'react'
import {View, Text, Image, KeyboardAvoidingView} from 'react-native'
import {connect} from 'react-redux'
// Add Actions - replace 'Your' with whatever your reducer is called :)
// import YourActions from '../Redux/YourRedux'
import {Metrics} from '../Themes'
// external libs
import Icon from 'react-native-vector-icons/FontAwesome'
import Animatable from 'react-native-animatable'
import {Actions as NavigationActions} from 'react-native-router-flux'
import Img from './Styles/Images'

// I18n
import I18n from 'react-native-i18n'

const width = Metrics.screenWidth
const height = Metrics.screenHeight

class Splash extends React.Component {

  componentDidMount () {
    setTimeout(function () {
      NavigationActions.promotionScreen({type: 'reset'})
    }, 2000)
  }

  render () {
    return (
      <View style={{ width: width, height: height }}>
        <Image source={Img.backgroundOkkami} style={{width: width, height: height}} />
      </View>
    )
  }
}

const mapStateToProps = (state) => {
  return {}
}

const mapDispatchToProps = (dispatch) => {
  return {}
}

export default connect(mapStateToProps, mapDispatchToProps)(Splash)
