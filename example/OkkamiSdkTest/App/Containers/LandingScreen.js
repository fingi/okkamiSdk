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
  ListView,
  TouchableHighlight
} from 'react-native'
import {connect} from 'react-redux'
import Styles from './Styles/LandingScreenStyle'
import {Images, Metrics} from '../Themes'
import Img from './Styles/Images'
import {Actions as NavigationActions} from 'react-native-router-flux'
import OkkamiSdk from 'okkami-sdk'
import Swiper from 'react-native-swiper'
import { SwipeListView, SwipeRow } from 'react-native-swipe-list-view'
import LinearGradient from 'react-native-linear-gradient'

// I18n
import I18n from 'react-native-i18n'

import Dimensions from 'Dimensions'

class LandingScreen extends React.Component {

  constructor (props) {
    super(props)
    this.ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2})
    this.state = {
      items: [
        { title: 'Title 1', image: require('../Images/promotion/okkami_slide_01.jpg') },
        { title: 'Title 2', image: require('../Images/promotion/okkami_slide_02.jpg') },
        { title: 'Title 3', image: require('../Images/promotion/okkami_slide_03.jpg') },
        { title: 'Title 4', image: require('../Images/promotion/okkami_slide_04.jpg') }
      ],
      basic: true,
      interval: null,
      position: 0,
      listViewData: [
        ['CONNECT TO MY HOTEL', true, true, 'text', '', 'signUpScreen'],
        ['TOURS & ACTIVITIES', true, false, 'text', 'Detail Tours & activities', 'signInScreen'],
        ['TRAVEL RESOURCES', true, false, 'text', 'Detail Travel resources', ''],
        ['ESSENTIAL TRAVEL APPS', true, false, 'text', 'Detail essential travel', ''],
        ['MY REWARDS', true, false, 'text', 'Detail my rewards', '']
      ]
    }
  }

  _renderDetail = (type, data, head = false) => {
    if (type == 'text') {
      return (
        <Text style={{color: '#000000'}}>{data}</Text>
      )
    } else if (type == 'img') {
      // Can not use error unknow module
      let url = './Images/' + data
      let img = require(url)
      return (
        <Image source={img} />
      )
    } else {
      return null
    }
  }

  handlePressItem = () => {
    // NavigationActions.apiScreen()
  }

  render () {
    let bgHead = ['#C52A1A', '#EC222F', '#C52A1A'],
      bgItem = ['#FAFAFA', '#EAE8E9'],
      itemStyle = null

    return (
      <View style={Styles.mainContainer}>
        <Image source={Img.backgroundOkkami} style={Styles.backgroundImage} />
        <Swiper showsButtons autoplay dotColor={'#ffffff'} loop autoplayTimeout={5} height={Metrics.screenHeight / 4}>
          {this.state.items.map((item, key) => {
            return (
              <View key={key} style={Styles.slide} >
                <Image source={item.image} style={Styles.slideImage} />
              </View>
            )
          })}
        </Swiper>
        <ScrollView style={Styles.container} >
          {/* Swipe listview */}
          <View style={Styles.bodyView} >
            {
              <SwipeListView
                dataSource={this.ds.cloneWithRows(this.state.listViewData)}
                renderRow={(data, secId, rowId, rowMap) => (

                  <SwipeRow
                    disableRightSwipe={data[1]}
                    disableLeftSwipe={data[2]}
                    rightOpenValue={-(Metrics.screenWidth)}
              >
                    <View style={Styles.standaloneRowBack}>
                      {/* <Text style={{color:"#000000"}}>detail</Text> */}
                      { this._renderDetail(data[3], data[4]) }
                    </View>
                    <LinearGradient colors={(rowId == 0) ? bgHead : bgItem} style={Styles.linearGradient}>
                      <TouchableOpacity onPress={this.handlePressItem}>
                        <Text style={(rowId == 0) ? Styles.buttonTextWhite : Styles.buttonText}>
                          {data[0]}
                        </Text>
                      </TouchableOpacity>
                    </LinearGradient>

                  </SwipeRow>
            )}
            />
            }

          </View>
        </ScrollView>

        <View style={Styles.bottomView} >
          <View style={Styles.bottomViewSub}>
            <TouchableOpacity>
              <View>
                <Text style={Styles.buttonTextBottom}>
                    About
                  </Text>
              </View>
            </TouchableOpacity>
          </View>
          <View style={Styles.bottomViewSub}>
            <TouchableOpacity>
              <View>
                <Text style={Styles.buttonTextBottom}>
                    App website
                  </Text>
              </View>
            </TouchableOpacity>
          </View>
        </View>

      </View>
    )
  }

}

LandingScreen.propTypes = {

}

LandingScreen.defaultProps = {

}

const mapStateToProps = state => {
  return {

  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(LandingScreen)
