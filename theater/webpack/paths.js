const path = require('path')

const CWD = process.cwd()

module.exports = {
  app: path.resolve(CWD, 'app'),
  dist: path.resolve(CWD, 'dist'),
  modules: path.resolve(CWD, 'node_modules'),
}
