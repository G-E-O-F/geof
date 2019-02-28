export const BACK = '33,32,30'
export const FORE = '243,241,237'
export const PRIMARY = '134,171,165'

export default {
  back: `rgb(${BACK})`,
  backA: a => `rgba(${BACK},${a})`,
  darkShadow: `rgba(${BACK},`,
  fore: `rgb(${FORE})`,
  foreA: a => `rgba(${FORE},${a})`,
  primary: `rgb(${PRIMARY})`,
}
