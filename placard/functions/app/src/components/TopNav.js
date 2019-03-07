import React from 'react'
import cx from 'classnames'
import { Link } from 'react-router-dom'

import { Simple } from '../assets/logos'
import { colors, layouts, fonts, typeScale } from '../style'

import { withStyles } from '@material-ui/core'

const styles = ({ breakpoints }) => ({
  nav: {
    background: colors.back,
    color: colors.fore,
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 99,
  },
  navStage: {
    display: 'flex',
    flexFlow: 'row nowrap',
    alignItems: 'stretch',
  },
  logoStage: {
    ...layouts.exDocSidebarWidth,
    flex: '0 0 auto',
  },
  linksStage: {
    flex: '1 0 auto',
  },
  links: {
    ...layouts.exDocFocusWidth,
    height: '100%',
    justifyContent: 'flex-end',
  },
  logoLink: {
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
      color: 'white',
    },
  },
  navLink: {
    flex: '0 0 auto',
    color: colors.fore,
    textDecoration: 'none',
    ...fonts.display.bold,
    ...typeScale(1),
    height: '100%',
    padding: '0 .6rem',
    display: 'flex',
    flexFlow: 'row nowrap',
    alignItems: 'center',
  },
  navLinkActive: {
    borderBottom: `.2rem solid ${colors.primary}`,
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
})

const TopNav = ({ classes, pathName }) => (
  <nav className={classes.nav}>
    <div className={classes.navStage}>
      <div className={classes.logoStage}>
        <Link to="/" className={classes.logoLink}>
          <Simple className={classes.logoDevice} />
          <span className={classes.logoType}>GEOF</span>
        </Link>
      </div>
      <div className={classes.linksStage}>
        <div className={cx(classes.navStage, classes.links)}>
          <Link
            to="/docs"
            className={cx(
              classes.navLink,
              pathName.startsWith('/docs') && classes.navLinkActive
            )}
          >
            <span>docs</span>
          </Link>
        </div>
      </div>
    </div>
  </nav>
)

export default withStyles(styles)(TopNav)
