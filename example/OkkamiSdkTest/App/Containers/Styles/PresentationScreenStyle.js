// @flow

import { StyleSheet } from 'react-native'
import { Metrics, ApplicationStyles } from '../../Themes/'

export default StyleSheet.create({
  ...ApplicationStyles.screen,
  logo: {
    height: Metrics.images.logo + 20,
    width: Metrics.images.logo + 20,
    resizeMode: 'contain'
  },
  centered: {
    alignItems: 'center'
  }
})
