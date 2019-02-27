import React from 'react'
import { render, hydrate } from 'react-dom'
import { Provider } from 'react-redux'
import { JssProvider } from 'react-jss'
import { ThemeProvider } from './style'
import Loadable from 'react-loadable'
import { Frontload } from 'react-frontload'
import { ConnectedRouter } from 'connected-react-router'
import createStore from './store'
import { createGenerateClassName } from '@material-ui/core/styles'

import App from './App'

// Create a store and get back itself and its history object
const { store, history } = createStore()

const generateClassName = createGenerateClassName()

// Running locally, we should run on a <ConnectedRouter /> rather than on a <StaticRouter /> like on the server
// Let's also let React Frontload explicitly know we're not rendering on the server here
const Application = (
  <Provider store={store}>
    <JssProvider generateClassName={generateClassName}>
      <ThemeProvider>
        <ConnectedRouter history={history}>
          <Frontload noServerRender={true}>
            <App />
          </Frontload>
        </ConnectedRouter>
      </ThemeProvider>
    </JssProvider>
  </Provider>
)

const root = document.querySelector('#root')

const clearSsrStyles = () => {
  const ssrStyles = document.getElementById('server-side-styles')
  if (ssrStyles) ssrStyles.parentNode.removeChild(ssrStyles)
}

if (root.hasChildNodes() === true) {
  // If it's an SSR, we use hydrate to get fast page loads by just
  // attaching event listeners after the initial render
  Loadable.preloadReady().then(() => {
    hydrate(Application, root, clearSsrStyles)
  })
} else {
  // If we're not running on the server, just render like normal
  render(Application, root, clearSsrStyles)
}
