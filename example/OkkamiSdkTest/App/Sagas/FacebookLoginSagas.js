import { put } from 'redux-saga/effects'
import FacebookLoginActions from '../Redux/FacebookLoginRedux'

// attempts to login
export function * facebookLogin ({ username, password, facebookData }) {
  if (password === '') {
    // dispatch failure
    yield put(FacebookLoginActions.facebookLoginFailure('WRONG'))
  } else {
    // dispatch successful logins
    yield put(FacebookLoginActions.facebookLoginSuccess(username, facebookData))
  }
}
