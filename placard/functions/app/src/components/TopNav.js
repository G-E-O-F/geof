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
    display: 'inline-flex',
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
    cursor: 'pointer',
    height: '100%',
    padding: '0 .6rem',
    display: 'flex',
    flexFlow: 'row nowrap',
    alignItems: 'center',
    [breakpoints.up('sm')]: {
      padding: '0 1.2rem',
    },
  },
  link: {
    position: 'relative',
    '&:before': {
      content: '""',
      display: 'block',
      position: 'absolute',
      left: 0,
      right: 0,
      bottom: 0,
      height: 0,
      transition: 'height .1s ease-in-out',
      background: colors.primary,
    },
    '&:hover,&:focus': {
      '&:before': {
        height: '.2rem',
      },
    },
  },
  navLinkActive: {
    '&:before': {
      height: '.2rem',
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
})

const TopNav = ({ classes, pathName }) => (
  <nav className={classes.nav}>
    <div className={classes.navStage}>
      <div className={classes.logoStage}>
        <Link to="/" className={cx(classes.link, classes.logoLink)}>
          <Simple className={classes.logoDevice} />
          <span className={classes.logoType}>GEOF</span>
        </Link>
      </div>
      <div className={classes.linksStage}>
        <div className={cx(classes.navStage, classes.links)}>
          <a
            href="https://gitlab.com/thure/geof"
            className={cx(classes.link, classes.navLink)}
          >
            gitlab
          </a>
          <Link
            to="/docs"
            className={cx(
              classes.link,
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
