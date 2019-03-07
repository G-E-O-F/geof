import { parse as parseURL } from 'url'
import { parse as parsePath, resolve, join } from 'path'

const topNavHeight = '3.2rem'

export default (req, res, next) => {
  const { pathname } = parseURL(req.url)
  const { dir, base, ext } = parsePath(pathname)

  console.log('[Docs]', 'invoked', pathname, dir, base, ext)

  if (dir === '/' && base.length > 0) {
    console.log('[Docs]', 'redirecting to index.html', base)
    return res.redirect(join('/docs', base, 'index.html'))
  }

  if (ext !== '.html') {
    console.log('[Docs]', 'HTML resource not requested')
    return next()
  }

  req.basePage = resolve(__dirname, `../../app/config/docs${pathname}`)

  req.appendToBasePage = `
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
  `

  req.titleTransform = 'docs'

  return next()
}
