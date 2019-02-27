import React from 'react'
import ReactMarkdownWithHTML from 'react-markdown/with-html'
import ReactMarkdown from 'react-markdown'
import { preventOrphans } from '../style'
import { Link } from 'react-router-dom'

const renderLink = ({ href, children }) => {
  if (href[0] === '/') return <Link to={href}>{children}</Link>
  else return <a href={href}>{children}</a>
}

export default ({ source, withHTML }) => {
  const Markdown = withHTML ? ReactMarkdownWithHTML : ReactMarkdown
  return (
    <Markdown
      source={preventOrphans(source)}
      escapeHtml={!withHTML}
      renderers={{
        link: renderLink,
      }}
    />
  )
}
