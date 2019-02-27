import React from 'react'
import cx from 'classnames'

import { withStyles } from '@material-ui/core'
import { colors } from '../style'

const styles = {
  loading: {
    animation: 'loading infinite linear 4s',
    backgroundImage: `linear-gradient(90deg, ${colors.dark} 0%, ${colors.lightA(
      0.5
    )} 25%, ${colors.dark} 50%)`,
    backgroundSize: '1400px',
    opacity: 1,
    zIndex: 1,
    transition: 'opacity .5s linear, z-index 0s linear .5s',
  },
  loadingReady: {
    opacity: 0,
    zIndex: -1,
  },
}

export default withStyles(styles)(({ ready, classes, className }) => (
  <div
    className={cx(classes.loading, ready && classes.loadingReady, className)}
  />
))
