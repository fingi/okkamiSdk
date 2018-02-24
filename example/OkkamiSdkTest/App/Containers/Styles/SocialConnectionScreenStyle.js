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
  formScroll: {
    height: height,
    width: width,
    backgroundColor: Colors.windowTint
  },
  form: {
    paddingTop: 10,
    width: width,
    height: height,
    position: 'absolute',
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center',
    backgroundColor: '#000000',
    opacity: 0.7
  },
  formOver: {
    paddingTop: 50,
    paddingBottom: 50,
    width: width,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center'
  },
  buttonFire: {
    width: inputWidth,
    height: 40,
    borderRadius: 5,
    marginTop: 10,
    backgroundColor: Colors.fire,
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
  buttonText: {
    color: Colors.snow,
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: Fonts.size.medium,
    marginVertical: Metrics.baseMargin
  },
  avatar: {
    marginTop: 10,
    marginBottom: 10,
    alignSelf: 'center',
    width: inputWidth,
    height: inputWidth,
    borderRadius: inputWidth / 2
  },
  formCheckBox: {
    width: inputWidth,
    height: 50,
    marginTop: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
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
  textAreaInput: {
    width: inputWidth,
    height: 100,
    borderRadius: 2,
    backgroundColor: Colors.snow,
    marginTop: 10,
    textAlignVertical: 'top'
  },
  textForm: {
    width: inputWidth / 2.5,
    // height: 40,
    color: '#ffffff',
    fontWeight: 'bold',
    fontSize: 18,
    textAlignVertical: 'center',
    backgroundColor: Colors.clear
  },
  indicatorView: {
    paddingTop: 100,
    width: Metrics.screenWidth,
    height: 200,
    position: 'absolute',
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center'
  }
})
