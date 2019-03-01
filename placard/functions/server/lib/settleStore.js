import createStore from '../../app/src/store'
import {
  logoutUser,
  setCurrentUserFromCookie,
} from '../../app/src/modules/auth'

export default req => {
  // Create a store (with a memory history) from our current url
  const { store } = createStore(req.url)

  // If the user is resolved, set them as the current user.
  // Otherwise, we want to set the current state to be logged out.
  if (req.user) {
    return store
      .dispatch(dispatch => {
        console.log('[SSR]', 'authenticated', req.user)
        return Promise.all([dispatch(setCurrentUserFromCookie(req.user))])
      })
      .then(() => store)
  } else {
    console.log('[SSR]', 'not authenticated')
    return store.dispatch(logoutUser()).then(() => store)
  }
}
