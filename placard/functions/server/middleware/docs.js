import fs from 'fs'
import { parse as parseURL } from 'url'
import { parse as parsePath, resolve } from 'path'

// Libs
import settleMarkup from '../lib/settleMarkup'
import settleStore from '../lib/settleStore'
import renderHTML from '../lib/renderHTML'

const topNavHeight = '3.2rem'

// Component
import TopNav from '../../app/src/components/TopNav'

export default (req, res, next) => {
  const { pathname } = parseURL(req.url)
  const { dir, base, ext } = parsePath(pathname)

  console.log('[Docs]', 'invoked', pathname, dir, base, ext)

  if (ext !== '.html') {
    console.log('[Docs]', 'HTML resource not requested')
    return next()
  }

  fs.readFile(
    resolve(__dirname, `../../app/config/docs${pathname}`),
    'utf8',
    (err, htmlData) => {
      if (err) {
        console.log('[Docs]', 'error', err)
        return next()
      }

      htmlData = htmlData.replace(
        '</body>',
        `
<div id="root"></div>
<link href="https://fonts.googleapis.com/css?family=Dosis:600|Maven+Pro" rel="stylesheet">
<style type="text/css">
  .main, .sidebar { padding-top: ${topNavHeight} }
  .sidebar-toggle { top: ${topNavHeight} }
  .night-mode-toggle { top: calc(${topNavHeight} + 1.6em) }
  .sidebar-closed .sidebar-button { left: 1rem }
  @media(min-width: 600px){
    .sidebar-closed .sidebar-button { left: 2rem }
  }
</style>
</body>`
      )

      settleStore(req)
        .then(store => settleMarkup({ store, req, Component: TopNav }))
        .then(settledMarkupProps => {
          return res.send(renderHTML(htmlData, settledMarkupProps))
        })
        .catch(err => {
          console.log('[Docs]', 'error', err)
          return res.sendStatus(500)
        })
    }
  )
}
