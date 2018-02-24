import { StyleSheet } from 'react-native'
import { Fonts, Colors, Metrics } from '../../Themes'

const width = Metrics.screenWidth
const height = Metrics.screenHeight

export default StyleSheet.create({
  container: {
    paddingTop: 50,
    backgroundColor: Colors.background,
    flex: 1
  },
  item: {
    width: width,
    height: height
  },
  slide: {

  },
  slideImage: {
    width: width,
    height: height
  },
  mainButton: {
    position: 'absolute',
    width: width,
    height: 120,
    bottom: 50,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: Colors.ember
  },
  button: {
    width: width / 3,
    height: 45,
    borderRadius: 5,
    marginHorizontal: Metrics.section,
    marginVertical: Metrics.baseMargin,
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
