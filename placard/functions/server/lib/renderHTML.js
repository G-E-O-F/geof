import Helmet from 'react-helmet'
import manifest from '../../app/build/asset-manifest.json'
import injectHTML from './injectHTML'

export default (baseHTML, { store, routeMarkup, sheets, context, modules }) => {
  // Let's give ourself a function to load all our page-specific JS assets for code splitting
  const extractAssets = (assets, chunks) =>
    Object.keys(assets)
      .filter(asset => chunks.indexOf(asset.replace('.js', '')) > -1)
      .map(k => assets[k])

  // Let's format those assets into pretty <script> tags
  const extraChunks = extractAssets(manifest, modules).map(
    c =>
      `<script type="text/javascript" src="/${c.replace(/^\//, '')}"></script>`
  )

  // We need to tell Helmet to compute the right meta tags, title, and such
  const helmet = Helmet.renderStatic()

  // Pass all this nonsense into our HTML formatting function above
  return injectHTML(baseHTML, {
    html: helmet.htmlAttributes.toString(),
    title: helmet.title.toString(),
    meta: helmet.meta.toString(),
    ssrStyles: sheets.toString(),
    body: routeMarkup,
    scripts: extraChunks,
    state: JSON.stringify(store.getState()).replace(/</g, '\\u003c'),
  })
}
