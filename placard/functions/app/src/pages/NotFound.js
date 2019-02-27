import React from 'react'
import Page from '../components/Page'
import injectSheet from 'react-jss'
import cx from 'classnames'
import { typeScale } from '../style'

const styles = {
  img: {
    display: 'block',
    margin: '0 auto',
    maxWidth: '100%',
    marginTop: '2rem',
  },
  text: {
    display: 'block',
    textAlign: 'center',
    marginBottom: '0.6rem',
  },
  big: {
    ...typeScale(3),
  },
  med: {
    ...typeScale(1),
  },
  small: {
    ...typeScale(-1),
  },
}

export default injectSheet(styles)(({ classes }) => (
  <Page id="not-found" title="Not Found" description="Thing not found." noCrawl>
    <h1 className={cx(classes.text, classes.big)}>Oh no. Thing not found.</h1>
  </Page>
))
