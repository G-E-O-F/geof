import React from 'react'
import Page from '../components/Page'

import { colors } from '../style'

import { withStyles } from '@material-ui/core'
import Typography from '@material-ui/core/Typography'

const styles = {
  link: {
    display: 'block',
    color: colors.primary,
    marginBottom: '.6em',
  },
}

export default withStyles(styles)(({ classes }) => (
  <Page id="docs" title="Docs" description="GEOF component documentation">
    <Typography variant="h3" paragraph>
      Components
    </Typography>
    <a href="/docs/planet" className={classes.link}>
      Planet
    </a>
    <a href="/docs/shapes" className={classes.link}>
      Shapes
    </a>
  </Page>
))
