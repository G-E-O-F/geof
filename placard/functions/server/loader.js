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

const defaultBasePage = fs.readFileSync(
  path.resolve(__dirname, '../app/build/basepage.html'),
  'utf8'
)

// LOADER
export default (req, res) => {
  const htmlData = req.basePage || defaultBasePage

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
        const html = renderHTML(htmlData, {
          ...settledMarkupProps,
          titleTransform: req.titleTransform,
        })

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
