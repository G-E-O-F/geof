const textFamily = { fontFamily: `'Maven Pro', sans-serif` }
const displayFamily = { fontFamily: `'Dosis', sans-serif` }

export default {
  text: {
    regular: {
      ...textFamily,
      fontWeight: 400,
      fontStyle: 'normal',
    },
  },
  display: {
    light: {
      ...displayFamily,
      fontWeight: 200,
      fontStyle: 'normal',
    },
    bold: {
      ...displayFamily,
      fontWeight: 600,
      fontStyle: 'normal',
    },
  },
}
