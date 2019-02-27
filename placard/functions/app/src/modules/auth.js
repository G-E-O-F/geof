import Cookies from 'js-cookie'

export const COOKIE_KEY = '__session'

export const AUTHENTICATE = 'auth/AUTHENTICATE'
export const SET_CURRENT_USER = 'auth/SET_CURRENT_USER'

const cookiesConfig = {
  expires: 3,
}

const initialState = {
  isAuthenticated: false,
  currentUser: {},
}

export default (state = initialState, action) => {
  switch (action.type) {
    case AUTHENTICATE:
      return {
        ...state,
        isAuthenticated: action.authenticated,
      }

    case SET_CURRENT_USER:
      return {
        ...state,
        currentUser: action.user,
      }

    default:
      return state
  }
}

export const setCurrentUser = user => dispatch =>
  new Promise(resolve => {
    // console.log('[setCurrentUser]', user)

    dispatch({
      type: SET_CURRENT_USER,
      user,
    })

    dispatch({
      type: AUTHENTICATE,
      authenticated: true,
    })

    resolve(user)
  })

export const setCurrentUserFromCookie = user => dispatch =>
  new Promise(resolve => {
    // console.log('[setCurrentUserFromCookie]', user)

    dispatch({
      type: SET_CURRENT_USER,
      user,
    })

    dispatch({
      type: AUTHENTICATE,
      authenticated: true,
    })

    resolve(user)
  })

export const establishCurrentUser = (isAuthenticated, user) => dispatch => {
  if (isAuthenticated && user) {
    // console.log('[establishCurrentUser]', 'logged in')
    if (!Cookies.get(COOKIE_KEY)) Cookies.set(COOKIE_KEY, user, cookiesConfig)
    return dispatch(setCurrentUser(user))
  } else {
    return dispatch(logoutUser())
  }
}

export const logoutUser = () => dispatch =>
  new Promise(resolve => {
    // console.log('[logoutUser]')

    dispatch({
      type: AUTHENTICATE,
      authenticated: false,
    })

    dispatch({
      type: SET_CURRENT_USER,
      user: {},
    })

    Cookies.remove(COOKIE_KEY)
    resolve({})
  })
