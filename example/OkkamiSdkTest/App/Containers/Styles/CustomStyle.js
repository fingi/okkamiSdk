import { StyleSheet } from 'react-native'
import { Fonts, Colors, Metrics } from '../../Themes'

const formWidth = Metrics.screenWidth / 1.3

export default StyleSheet.create({
  container: {
    paddingTop: 50,
    backgroundColor: Colors.background,
    flex: 1
  },
  backgroundImage: {
    width: Metrics.screenWidth,
    height: Metrics.screenHeight,
    position: 'absolute'
  }

})
