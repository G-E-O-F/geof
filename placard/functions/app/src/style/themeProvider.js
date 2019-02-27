import React from 'react'
import { createMuiTheme } from '@material-ui/core/styles'
import createBreakpoints from '@material-ui/core/styles/createBreakpoints'
import shadows from '@material-ui/core/styles/shadows'
import MuiThemeProvider from '@material-ui/core/styles/MuiThemeProvider'
import fonts from './fonts'
import colors from './colors'
import typeScale from './typeScale'
import borderRadii from './borderRadii'

const breakpoints = createBreakpoints({})

const themedShadows = shadows.map(shadow =>
  shadow.replace(/rgba\(0,0,0,/g, colors.darkShadow)
)

export const theme = createMuiTheme({
  palette: {
    type: 'light',
    primary: {
      main: colors.back,
      contrastText: colors.fore,
    },
    secondary: {
      main: colors.back,
      contrastText: colors.fore,
    },
    text: {
      primary: colors.fore,
    },
  },
  shadows: themedShadows,
  typography: Object.assign({
    // global values
    useNextVariants: true,
    fontSize: 16,
    // specific type styles
    h1: {
      ...fonts.display.bold,
      ...typeScale(7),
      [breakpoints.up('sm')]: {
        ...typeScale(10),
        lineHeight: 1,
      },
      lineHeight: 1,
    },
    h3: {
      ...fonts.display.bold,
      ...typeScale(5),
    },
    h4: {
      ...fonts.display.bold,
      ...typeScale(3),
    },
    h5: {
      ...fonts.display.bold,
      ...typeScale(3),
    },
    h6: {
      ...fonts.display.bold,
      ...typeScale(2),
    },
    body1: {
      ...fonts.text.regular,
      ...typeScale(0),
    },
    body2: {
      ...fonts.text.regular,
      ...typeScale(-1),
    },
    button: {
      ...fonts.text.regular,
      ...typeScale(-2),
    },
    caption: {
      ...fonts.text.regular,
      ...typeScale(-2),
      [breakpoints.up('sm')]: {
        ...typeScale(-1),
      },
    },
  }),
  shape: {
    borderRadius: borderRadii.A,
  },
})

export default ({ children, ...props }) => (
  <MuiThemeProvider {...props} theme={theme}>
    {children}
  </MuiThemeProvider>
)
