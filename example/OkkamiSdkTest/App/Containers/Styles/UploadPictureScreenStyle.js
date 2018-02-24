import { StyleSheet } from 'react-native'
import { Fonts, Colors, Metrics, ApplicationStyles } from '../../Themes'

const width = Metrics.screenWidth
const height = Metrics.screenHeight
const inputWidth = width * 0.75 // width 75%

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
  avatar: {
    marginTop: 50,
    marginBottom: 50,
    alignSelf: 'center',
    width: inputWidth,
    height: inputWidth,
    borderRadius: inputWidth / 2
  },
  formButton: {
    width: inputWidth,
    marginTop: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  buttonFireSplitTwo: {
    width: inputWidth / 2.5,
    height: 40,
    borderRadius: 5,
    marginTop: 10,
    backgroundColor: Colors.fire,
    justifyContent: 'center'
  },
  buttonText: {
    color: Colors.snow,
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: Fonts.size.medium,
    marginVertical: Metrics.baseMargin
  }

})
