import { StyleSheet } from 'react-native'
import { Fonts, Colors, Metrics } from '../../Themes'

export default StyleSheet.create({
  container: {
    flex: 1,
    padding: 0,
    backgroundColor: Colors.fire
  },
  logo: {
    alignSelf: 'center'
  },
  header: {
    flex: 1,
    flexDirection: 'row'
  },
  headerLeft: {
    flex: 1,
    backgroundColor: Colors.clear,
    flexDirection: 'row',
    justifyContent: 'center'
  },
  headerRight: {
    flex: 2.8,
    backgroundColor: Colors.clear
  },
  headerRightTextTop: {
    flex: 1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-end'
  },
  headerRightTextName: {
    flex: 5, fontSize: 18, fontWeight: 'bold', color: '#ffffff'
  },
  headerRightTextRoom: {
    fontSize: 14, height: 30, color: '#ffffff'
  },
  headerRightTextButtom: {
    flex: 1, flexDirection: 'row', alignItems: 'flex-start'
  },
  mainMenu: {
    flex: 4
  },
  avatar: {
    alignSelf: 'center',
    width: 50,
    height: 50,
    borderRadius: 25
  },
  panelRow: {
    flexDirection: 'row', alignItems: 'center', height: 55, backgroundColor: '#421213', borderTopWidth: 2, borderTopColor: '#7B1500'
  },
  panelText: {
    color: '#ffffff', fontWeight: 'bold', fontSize: 16, marginLeft: 35
  }
})
