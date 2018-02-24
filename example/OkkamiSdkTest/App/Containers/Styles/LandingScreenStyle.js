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
    paddingTop: 0,
    backgroundColor: '#FFFFFF'
  },
  formOver: {
    paddingTop: 0,
    paddingBottom: 50,
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'center'
  },
  bodyView: {
    flex: 1,
    width: Metrics.screenWidth,
    backgroundColor: '#FFFFFF'
  },
  buttonText: {
    fontSize: 18,
    fontWeight: 'bold',
    fontFamily: 'Gill Sans',
    textAlign: 'center',
    color: '#000000',
    backgroundColor: 'transparent'
  },
  buttonTextWhite: {
    fontSize: 18,
    fontWeight: 'bold',
    fontFamily: 'Gill Sans',
    textAlign: 'center',
    color: '#FFFFFF',
    backgroundColor: 'transparent'
  },
  standaloneRowBack: {
    width: Metrics.screenWidth,
    alignItems: 'center',
    backgroundColor: '#DDDDDD',
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 15
  },
  linearGradient: {
    width: Metrics.screenWidth,
    height: 60,
    paddingLeft: 15,
    paddingRight: 15,
    borderTopColor: '#ffffff',
    borderTopWidth: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center'
    // backgroundColor: "#9BBACF"
  },
  bottomView: {
    // flex: 1,
    height: 50,
    width: Metrics.screenWidth,
    backgroundColor: '#FFFFFF',
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: '#CECECE',
    padding: 5
  },
  bottomViewSub: {
    flex: 1,
    // height:50,
    borderRightWidth: 1,
    borderRightColor: '#CECECE',
    flexDirection: 'row',
    justifyContent: 'center',
    // backgroundColor: '#B2CADA',
    alignItems: 'center'
  },
  buttonTextBottom: {
    fontSize: 16,
    // fontFamily: 'Gill Sans',
    textAlign: 'center',
    color: '#000000',
    backgroundColor: 'transparent'
  }

})
