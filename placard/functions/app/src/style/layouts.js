import { breakpoints } from './themeProvider'

export const navWidth = {
  paddingLeft: '1rem',
  paddingRight: '1rem',
  overflowX: 'hidden',
  [breakpoints.up('sm')]: {
    paddingLeft: '2rem',
    paddingRight: '2rem',
  },
}

export const pageWidth = {
  ...navWidth,
  maxWidth: '56rem',
  marginLeft: 'auto',
  marginRight: 'auto',
}

export default {
  pageWidth,
  navWidth,
}
