import React from 'react'
import { Link } from 'react-router-dom'

import { Simple } from '../assets/logos'
import { colors, layouts, fonts, typeScale } from '../style'

import { withStyles } from '@material-ui/core'

const styles = {
  nav: {
    background: colors.back,
    color: colors.fore,
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
  },
  navStage: {
    ...layouts.pageWidth,
    display: 'flex',
    flexFlow: 'row nowrap',
  },
  navLink: {
    flex: '0 0 auto',
    display: 'flex',
    flexFlow: 'row nowrap',
    alignItems: 'center',
    padding: '.6rem .6rem',
    marginLeft: '-.8rem',
    color: colors.fore,
    textDecoration: 'none',
    transition: 'color .1s linear',
    '&:hover': {
      color: colors.primary,
    },
  },
  logoDevice: {
    display: 'block',
    height: '2rem',
    width: '2rem',
  },
  logoType: {
    display: 'block',
    ...typeScale(4),
    ...fonts.display.bold,
    lineHeight: 1,
    transform: 'translateY(-1px)',
    marginLeft: '.4rem',
  },
}

const TopNav = ({ classes }) => (
  <nav className={classes.nav}>
    <div className={classes.navStage}>
      <Link to="/" className={classes.navLink}>
        <Simple className={classes.logoDevice} />
        <span className={classes.logoType}>GEOF</span>
      </Link>
    </div>
  </nav>
)

export default withStyles(styles)(TopNav)
