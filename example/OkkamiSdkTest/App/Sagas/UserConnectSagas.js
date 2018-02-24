import { put } from 'redux-saga/effects'
import UserConnectActions from '../Redux/UserConnectRedux'

// attempts to login
export function * userConnect ({ appToken }) {
  console.log(appToken)
  if (appToken === '') {
    // dispatch failure
    yield put(UserConnectActions.userConnectFailure('WRONG'))
  } else {
    // dispatch successful logins
    yield put(UserConnectActions.userConnectSuccess(appToken))
  }
}
