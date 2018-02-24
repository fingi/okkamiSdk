import React, { Component } from 'react'
import {StyleSheet, Text, View, Image, TouchableHighlight, Animated} from 'react-native'
import { Fonts, Colors, Metrics } from '../Themes'
import Icon from 'react-native-vector-icons/FontAwesome'

class Panel extends Component {
  constructor (props) {
    super(props)

    this.icons = {
      'up': require('./images/Arrowhead-01-128.png'),
      'down': require('./images/Arrowhead-Down-01-128.png')
    }

    this.state = {
      title: props.title,
      expanded: false,
      animation: new Animated.Value(),
      firstStart: true,
      child: props.child,
      maxHeight: 1,
      minHeight: 1
    }

    console.log('-- Start panel --')
  }

  toggle () {
          // console.log(this.state.minHeight + " " + this.state.maxHeight)

    let initialValue = this.state.expanded ? this.state.maxHeight + this.state.minHeight : this.state.minHeight,
      finalValue = this.state.expanded ? this.state.minHeight : this.state.maxHeight + this.state.minHeight

    this.setState({
      expanded: !this.state.expanded
    })

    this.state.animation.setValue(initialValue)
    Animated.spring(
              this.state.animation,
      {
        toValue: finalValue
      }
          ).start()
  }

  _setMaxHeight (event) {
    let h = event.nativeEvent.layout.height
    if (this.state.maxHeight < h) {
          // console.log("setmax : " + event.nativeEvent.layout.height);
      this.setState({
        maxHeight: event.nativeEvent.layout.height
      })
    }
  }

  _setMinHeight (event) {
    this.setState({
      minHeight: event.nativeEvent.layout.height
    })
    if (this.state.firstStart) {
      this.state.firstStart = false
      this.state.animation.setValue(event.nativeEvent.layout.height)
    }
  }

  render () {
    let icon = this.icons['down']

    if (this.state.expanded) {
      icon = this.icons['up']
    }

    return (
      <Animated.View
        style={[styles.container, {height: this.state.animation}]}>
        <View style={styles.titleContainer} onLayout={this._setMinHeight.bind(this)}>

          <TouchableHighlight
            style={{flex: 1, height: 60, borderTopWidth: 2, borderTopColor: '#7B1500'}}
                        // onPress={this.toggle.bind(this)}
            onPress={(this.state.child == 'true') ? this.toggle.bind(this) : this.props.onPress}
            underlayColor='#CB0000'>

            <View style={styles.button}>
              <Text style={styles.titleText}>{this.state.title}</Text>
              <View style={{flex: 1, height: 30, alignItems: 'center'}}>
                <Image
                  style={(this.state.child == 'true') ? styles.buttonImage : styles.imageHidden}
                  source={icon}
                            />
              </View>
            </View>
          </TouchableHighlight>

        </View>

        <View style={styles.body} onLayout={this._setMaxHeight.bind(this)}>
          {this.props.children}
        </View>

      </Animated.View>
    )
  }
}

Panel.propTypes = {

}

Panel.defaultProps = {

}

var styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.fire,
      // margin:10,
    overflow: 'hidden'
  },
  titleContainer: {
    flexDirection: 'row'
      // backgroundColor: Colors.fire,
  },
  titleViewLeft: {

  },
  titleText: {
    flex: 5,
    paddingLeft: 10,
    color: '#ffffff',
    fontWeight: 'bold',
    fontSize: 16
  },
  button: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  buttonImage: {
    width: 30,
    height: 25
  },
  body: {
    paddingTop: 0
  },
  imageHidden: {
    width: 0,
    height: 0
  }
})

export default Panel
