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
  Picker
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/UploadPictureScreenStyle'
import Img from './Styles/Images'
// import { Metrics } from '../Themes'
import {Actions as NavigationActions} from 'react-native-router-flux'
import ModalPicker from '../Components/Picker'

// I18n
import I18n from 'react-native-i18n'

class UploadPictureScreen extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      selectLanguage: ''
    }
  }

  render () {
    return (

      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />
        <ScrollView style={Styles.container} >
          <View style={Styles.formOver}>
            <Image
              source={Img.avatar}
              style={Styles.avatar}
            />
            <View style={Styles.formButton}>
              <TouchableOpacity style={Styles.buttonFireSplitTwo} >
                <Text style={Styles.buttonText}>Upload</Text>
              </TouchableOpacity>
              <TouchableOpacity style={Styles.buttonFireSplitTwo} >
                <Text style={Styles.buttonText}>Save</Text>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>
      </View>

    )
  }

}

UploadPictureScreen.propTypes = {

}

UploadPictureScreen.defaultProps = {

}

const mapStateToProps = state => {
  return {

  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(UploadPictureScreen)
