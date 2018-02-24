import { StyleSheet } from 'react-native'
import { Fonts, Colors, Metrics, ApplicationStyles } from '../../Themes/'

const width = Metrics.screenWidth
const height = Metrics.screenHeight
const inputWidth = width * 0.85 // width 75%

export default StyleSheet.create({
  ...ApplicationStyles.screen,
  backgroundImage: {
    width: width,
    height: height,
    position: 'absolute'
  },
  container: {
    flex: 1,
    paddingTop: Metrics.baseMargin,
    backgroundColor: Colors.windowTint
  },
  formOver: {
    paddingTop: 50,
    paddingBottom: 50,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center'
  },
  formButton: {
    width: inputWidth,
    marginTop: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  spaceLine: {
    width: inputWidth,
    height: 20,
    paddingBottom: 20,
    borderBottomWidth: 2,
    borderColor: 'white'
  },
  logo: {
    height: Metrics.images.logo,
    width: Metrics.images.logo,
    resizeMode: 'contain'
  },
  centered: {
    alignItems: 'center'
  }
})
