// Express requirements
import path from 'path'
import fs from 'fs'
import url from 'url'

// React requirements
import React from 'react'

// Our store, entrypoint, and manifest
import App from '../app/src/App'

// Libs
import settleMarkup from './lib/settleMarkup'
import settleStore from './lib/settleStore'
import renderHTML from './lib/renderHTML'

// LOADER
export default (req, res) => {
  // Load in our HTML file from our build
  fs.readFile(
    path.resolve(__dirname, '../app/build/basepage.html'),
    'utf8',
    (err, htmlData) => {
      // If there's an error... serve up something nasty
      if (err) {
        console.error('[Basepage]', 'read error', err)
        return res.status(500).end()
      }

      settleStore(req)
        .then(store => settleMarkup({ store, req, Component: App }))
        .then(settledMarkupProps => {
          if (settledMarkupProps.context.url) {
            // If context has a url property, then we need to handle a redirection in Redux Router
            res.writeHead(302, {
              Location: context.url,
            })

            return res.end()
          } else {
            const html = renderHTML(htmlData, settledMarkupProps)

            // Log to confirm SSR (vs client-side render)
            console.log(
              '[Render]',
              'rendered page',
              settledMarkupProps.routeMarkup.length
            )

            // We have all the final HTML, let's send it to the user already!
            return res.send(html)
          }
        })
        .catch(err => {
          console.log('[Loader]', 'error', err)
          return res.sendStatus(500)
        })
    }
  )
}
