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
    paddingTop: 10,
    paddingBottom: 10,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center'
  },
  textInput: {
    width: inputWidth,
    height: 40,
    borderRadius: 2,
    backgroundColor: Colors.snow,
    marginTop: 10,
    textAlign: 'center'
  },
  selectInput: {
    width: inputWidth,
    height: 40,
    borderRadius: 2,
    backgroundColor: Colors.snow,
    marginTop: 10
  },
  buttonSnow: {
    width: inputWidth,
    height: 40,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
    marginTop: 10,
    backgroundColor: Colors.snow,
    justifyContent: 'center'
  },
  buttonFire: {
    width: inputWidth,
    height: 40,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
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
  },
  buttonTextSnow: {
    color: Colors.coal,
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: Fonts.size.medium,
    marginVertical: Metrics.baseMargin
  },
  buttonCreate: {
    width: inputWidth,
    height: 45,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
    marginTop: 30,
    backgroundColor: Colors.fire,
    justifyContent: 'center'
  },
  sectionTextStyle: {
    fontWeight: 'bold',
    fontSize: Fonts.size.large
  },
  selectTextStyle: {
    fontWeight: 'bold',
    fontSize: Fonts.size.medium
  },
  indicatorView: {
    marginTop: -50,
    width: width,
    height: height,
    position: 'absolute',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center'
    // backgroundColor: Colors.windowTint
  }

})
