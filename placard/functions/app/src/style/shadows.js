import colors from './colors'

const { darkA } = colors

export default {
  zero: `0 0 0 transparent, 0 0 0 transparent`,
  A: `0 1px 3px ${darkA(0.12)}, 0 1px 2px  ${darkA(0.24)}`,
  B: `0 3px 6px  ${darkA(0.13)}, 0 3px 6px  ${darkA(0.2)}`,
  C: `0 10px 20px  ${darkA(0.19)}, 0 6px 6px  ${darkA(0.23)}`,
  D: `0 14px 28px  ${darkA(0.25)}, 0 10px 10px  ${darkA(0.22)}`,
  E: `0 19px 38px  ${darkA(0.3)}, 0 15px 12px  ${darkA(0.22)}`,
}
