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
    paddingTop: 25,
    paddingBottom: 50,
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
    alignSelf: 'center'
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
    // marginVertical: Metrics.baseMargin,
    marginTop: 10,
    backgroundColor: Colors.snow,
    justifyContent: 'center'
  },
  buttonFireSplitTwo: {
    width: inputWidth / 2.5,
    height: 40,
    borderRadius: 5,
    marginTop: 10,
    backgroundColor: Colors.fire,
    justifyContent: 'center'
  },
  buttonFire: {
    width: inputWidth,
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
  avatar: {
    marginTop: 10,
    marginBottom: 10,
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
  backgroundVideo: {
    position: 'absolute',
    top: 0,
    left: 0,
    bottom: 0,
    right: 0
  },
  indicatorView: {
    marginTop: -50,
    width: width,
    height: height,
    position: 'absolute',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: Colors.windowTint
  }

})
