const PATHS = require('./paths')

module.exports = ({ production = false, browser = false } = {}) => {
  const resolve = {
    modules: [PATHS.app, PATHS.modules],
    extensions: ['.js'],
    symlinks: false,
    alias: {},
  }
  return resolve
}
