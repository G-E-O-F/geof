import { parse as parseURL } from 'url'
import { parse as parsePath, resolve, join } from 'path'
import Storage from '@google-cloud/storage'
import serviceConfig from '../../config/gcp-key.json'

const storageClient = new Storage({
  projectId: serviceConfig.project_id,
  credentials: {
    client_email: serviceConfig.client_email,
    private_key: serviceConfig.private_key,
  },
})

const bucket = storageClient.bucket('gs://geof-io.appspot.com')

export const getDocsHTML = pathname => {
  return bucket
    .file(`/docs${pathname}`)
    .download()
    .then(data => data[0].toString())
}

export default (req, res, next) => {
  const { pathname } = parseURL(req.url)
  const { dir, base, ext } = parsePath(pathname)

  console.log('〘Docs〙', 'invoked', pathname, dir, base, ext)

  if (dir === '/' && base.length > 0) {
    console.log('〘Docs〙', 'redirecting to index.html', base)
    return res.redirect(join('/docs', base, 'index.html'))
  }

  if (ext !== '.html') {
    console.log('〘Docs〙', 'HTML resource not requested')
    return next()
  }

  getDocsHTML(pathname)
    .then(basePageHTML => {
      req.basePage = basePageHTML
      req.titleTransform = 'docs'
      return next()
    })
    .catch(err => {
      console.log('〘Docs〙', 'error', err)
      return res.redirect('/404')
    })
}
