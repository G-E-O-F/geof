const path = require('path')

const CWD = process.cwd()

const resolve = require('./resolve')

const node = {
  __dirname: true,
  __filename: true,
  fs: 'empty',
  module: 'empty',
}

module.exports = {
  mode: process.env.NODE_ENV || 'development',
  entry: './app/index.js',
  node,
  output: {
    filename: 'main.js',
    path: path.resolve(CWD, 'dist'),
  },
  resolve: resolve(),
}
