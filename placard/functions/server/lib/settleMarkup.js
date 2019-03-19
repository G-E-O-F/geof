import React from 'react'
import { renderToString } from 'react-dom/server'
import { Provider } from 'react-redux'
import { StaticRouter } from 'react-router'
import { Frontload, frontloadServerRender } from 'react-frontload'
import Loadable from 'react-loadable'
import { JssProvider, SheetsRegistry } from 'react-jss'
import { createGenerateClassName } from '@material-ui/core/styles'
import { ThemeProvider } from '../../app/src/style'

export default ({ store, req, Component }) => {
  // Set up accumulators for SSR
  const context = {}
  const modules = []
  const sheets = new SheetsRegistry()
  const generateClassName = createGenerateClassName({
    productionPrefix: '✨',
    seed: 's',
  })
  console.log('[generateClassName]', process.env.NODE_ENV)
  const sheetsManager = new Map()

  /*
    Here's the core funtionality of this file. We do the following in specific order (inside-out):
      1. Load the <App /> component
      2. Inside of the Frontload HOC
      3. Inside of a Redux <StaticRouter /> (since we're on the server), given a location and
        context to write to
      4. Inside of the store provider
      5. Inside of the React Loadable HOC to make sure we have the right scripts depending
      6. Inside of the JSS provider to capture all the styles used on the page
      7. Render all of this sexiness
      8. Make sure that when rendering Frontload knows to get all the appropriate preloaded
       requests
    In English, we basically need to know what page we're dealing with, and then load all the appropriate scripts and
    data for that page. We take all that information and compute the appropriate state to send to the user. This is
    then loaded into the correct components and sent as a Promise to be handled below.
  */

  return frontloadServerRender(() =>
    renderToString(
      <JssProvider registry={sheets} generateClassName={generateClassName}>
        <ThemeProvider sheetsManager={sheetsManager}>
          <Loadable.Capture report={m => modules.push(m)}>
            <Provider store={store}>
              <StaticRouter location={req.url} context={context}>
                <Frontload isServer={true}>
                  <Component />
                </Frontload>
              </StaticRouter>
            </Provider>
          </Loadable.Capture>
        </ThemeProvider>
      </JssProvider>
    )
  ).then(routeMarkup => ({ store, routeMarkup, sheets, context, modules }))
}
