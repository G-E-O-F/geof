export default (
  data,
  { html, title, meta, ssrStyles, body, scripts, state }
) => {
  data = data.replace('<html>', `<html ${html}>`)
  data = data.replace(
    /<title>.*?<\/title>/g,
    `<title>${title}</title>` +
      `<meta property="og:title" content="${title}">` +
      `<meta name="twitter:title" content="${title}">`
  )
  data = data.replace(
    '</head>',
    `${meta}<style type="text/css" id="server-side-styles">${ssrStyles}</style></head>`
  )
  data = data.replace(
    '<div id="root"></div>',
    `<div id="root">${body}</div><script>window.__PRELOADED_STATE__ = ${state}</script>`
  )
  data = data.replace('</body>', scripts.join('') + '</body>')

  return data
}
