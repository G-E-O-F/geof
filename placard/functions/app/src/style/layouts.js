import { breakpoints } from './themeProvider'

export const horizontalSpacing = {
  paddingLeft: '1rem',
  paddingRight: '1rem',
  overflowX: 'hidden',
  [breakpoints.up('sm')]: {
    paddingLeft: '2rem',
    paddingRight: '2rem',
  },
}

export const pageWidth = {
  ...horizontalSpacing,
  maxWidth: '56rem',
  marginLeft: 'auto',
  marginRight: 'auto',
}

export const exDocSidebarWidth = {
  width: 'auto',
  paddingLeft: 30,
  paddingRight: 30,
  boxSizing: 'border-box',
  [breakpoints.up('sm')]: {
    width: '300px',
  },
}

export const exDocFocusWidth = {
  maxWidth: 949,
  paddingLeft: 40,
  paddingRight: 20,
  marginLeft: 'auto',
  marginRight: 'auto',
  [breakpoints.up('sm')]: {
    paddingLeft: 60,
    paddingRight: 60,
  },
}

export default {
  pageWidth,
  horizontalSpacing,
  exDocSidebarWidth,
  exDocFocusWidth,
}
