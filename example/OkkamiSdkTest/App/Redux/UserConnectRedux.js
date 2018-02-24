// @flow

import { createReducer, createActions } from 'reduxsauce'
import Immutable from 'seamless-immutable'

/* ------------- Types and Action Creators ------------- */

const { Types, Creators } = createActions({
  userConnectRequest: ['appToken'],
  userConnectSuccess: ['appToken'],
  userConnectFailure: ['error'],
  userConnectUserData: ['userData'],
  userConnectUserToken: ['userToken'],
  logout: null
})

export const UserConnectTypes = Types
export default Creators

/* ------------- Initial State ------------- */

export const INITIAL_STATE = Immutable({
  appToken: null,
  userToken: null,
  userData: null,
  error: null,
  fetching: false
})

/* ------------- Reducers ------------- */

// we're attempting to login
export const request = (state: Object) => state.merge({ fetching: true })
export const user_request = (state: Object) => state.merge({ fetching: true })

// we've successfully logged in
export const success = (state: Object, { appToken }: Object) =>
  state.merge({ fetching: false, error: null, appToken })

// we've had a problem logging in
export const failure = (state: Object, { error }: Object) =>
  state.merge({ fetching: false, error })

export const userConnectUserData = (state: Object, { userData }: Object) =>
  state.merge({ fetching: false, error: null, userData })

export const userConnectUserToken = (state: Object, { userToken }: Object) =>
    state.merge({ fetching: false, error: null, userData: 'get from core', userToken })

// we've logged out
export const logout = (state: Object) => INITIAL_STATE

/* ------------- Hookup Reducers To Types ------------- */

export const reducer = createReducer(INITIAL_STATE, {
  [Types.USER_CONNECT_REQUEST]: request,
  [Types.USER_CONNECT_SUCCESS]: success,
  [Types.USER_CONNECT_FAILURE]: failure,
  [Types.LOGOUT]: logout,
  [Types.USER_CONNECT_USER_DATA]: userConnectUserData,
  [Types.USER_CONNECT_USER_TOKEN]: userConnectUserToken
})

/* ------------- Selectors ------------- */

// Is the current user logged in?
export const isAppToken = (userConnectState: Object) => userConnectState.appToken !== null

export const isLoggedIn = (userData: Object) => userData !== null
