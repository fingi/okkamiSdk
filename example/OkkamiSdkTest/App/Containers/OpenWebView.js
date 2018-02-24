import React, {PropTypes} from 'react'
import {
  StyleSheet,
  View,
  ScrollView,
  Text,
  WebView,
  TouchableOpacity
} from 'react-native'
import {connect} from 'react-redux'
import {Images, Metrics, Colors} from '../Themes'
import {Actions as NavigationActions} from 'react-native-router-flux'
import Dimensions from 'Dimensions'

const WEBVIEW_REF = 'webview'

class OpenWebView extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      url: props.url,
      backButtonEnabled: false,
      status: 'No Page Loaded',
      loading: true
    }
  }

  render () {
    return (

      <View style={styles.container}>

        <View>
          <TouchableOpacity
            onPress={this.goBack}
            style={this.state.backButtonEnabled ? styles.navButton : styles.disabledButton}>
            <Text> {'<'} </Text>
          </TouchableOpacity>
        </View>

        <WebView
          ref={WEBVIEW_REF}
          source={{uri: this.state.url}}
          // style={{width: Metrics.screenWidth, height: Metrics.screenHeight}}
          style={{width: Metrics.screenWidth}}
          javaScriptEnabled
          onNavigationStateChange={this.onNavigationStateChange}
          onShouldStartLoadWithRequest={this.onShouldStartLoadWithRequest}
          startInLoadingState
        />

        <View style={styles.statusBar}>
          <Text style={styles.statusBarText}>{this.state.status}</Text>
        </View>

      </View>
    )
  }

  goBack = () => {
    this.refs[WEBVIEW_REF].goBack()
  };

  onShouldStartLoadWithRequest = (event) => {
    // Implement any custom loading logic here, don't forget to return!
    return true
  };

  onNavigationStateChange = (navState) => {
    this.setState({
      backButtonEnabled: navState.canGoBack,
      forwardButtonEnabled: navState.canGoForward,
      url: navState.url,
      status: navState.title,
      // loading: navState.loading,
      scalesPageToFit: true
    })
  };

}

var styles = StyleSheet.create({
  container: {
    paddingTop: 50,
    backgroundColor: Colors.background,
    flex: 1
  },
  navButton: {
    width: 20,
    padding: 3,
    marginRight: 3,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#111111',
    borderColor: 'transparent',
    borderRadius: 3
  },
  disabledButton: {
    width: 20,
    padding: 3,
    marginRight: 3,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#555555',
    borderColor: 'transparent',
    borderRadius: 3
  },
  statusBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: 5,
    height: 22,
    backgroundColor: '#000000'
  },
  statusBarText: {
    color: 'white',
    fontSize: 13
  }
})

OpenWebView.propTypes = {

}

OpenWebView.defaultProps = {

}

const mapStateToProps = state => {
  return {

  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(OpenWebView)
