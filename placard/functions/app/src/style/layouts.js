import { breakpoints } from './themeProvider'

export const pageWidth = {
  maxWidth: '56rem',
  paddingLeft: '1rem',
  paddingRight: '1rem',
  marginLeft: 'auto',
  marginRight: 'auto',
  overflowX: 'hidden',
  [breakpoints.up('sm')]: {
    paddingLeft: '2rem',
    paddingRight: '2rem',
  },
}

export default {
  pageWidth,
}
