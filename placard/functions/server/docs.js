import fs from 'fs'
import { parse as parseURL } from 'url'
import { parse as parsePath, join, resolve } from 'path'

export default (req, res, next) => {
  const { path } = parseURL(req.url)
  const { dir, base, ext } = parsePath(path)

  if (ext !== '.html') return next()

  fs.readFile(
    resolve(__dirname, join('../app/config/docs', path)),
    'utf8',
    (err, htmlData) => {
      if (err) return next()
      console.log('[HTML successfully retrieved]')
      return res.send(htmlData)
    }
  )
}
