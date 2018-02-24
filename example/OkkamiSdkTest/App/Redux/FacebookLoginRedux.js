// @flow

import { createReducer, createActions } from 'reduxsauce'
import Immutable from 'seamless-immutable'

/* ------------- Types and Action Creators ------------- */

const { Types, Creators } = createActions({
  facebookLoginRequest: ['username', 'password', 'facebookData'],
  facebookLoginSuccess: ['username', 'facebookData'],
  facebookLoginFailure: ['error'],
  logout: null
})

export const FacebookLoginTypes = Types
export default Creators

/* ------------- Initial State ------------- */

export const INITIAL_STATE = Immutable({
  username: null,
  error: null,
  fetching: false,
  facebookId: null,
  facebookData: null
})

/* ------------- Reducers ------------- */

// we're attempting to login
export const request = (state: Object) => state.merge({ fetching: true })

// we've successfully logged in
export const success = (state: Object, { username, facebookData }: Object) =>
  state.merge({ fetching: false, error: null, username, facebookData })

// we've had a problem logging in
export const failure = (state: Object, { error }: Object) =>
  state.merge({ fetching: false, error })

// we've logged out
export const logout = (state: Object) => INITIAL_STATE

/* ------------- Hookup Reducers To Types ------------- */

export const reducer = createReducer(INITIAL_STATE, {
  [Types.FACEBOOK_LOGIN_REQUEST]: request,
  [Types.FACEBOOK_LOGIN_SUCCESS]: success,
  [Types.FACEBOOK_LOGIN_FAILURE]: failure,
  [Types.LOGOUT]: logout
})

/* ------------- Selectors ------------- */

// Is the current user logged in?
export const isLoggedIn = (facebookLoginState: Object) => facebookLoginState.username !== null
