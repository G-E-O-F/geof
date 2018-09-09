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
  entry: './app/app.js',
  node,
  output: {
    filename: 'main.js',
    path: path.resolve(CWD, 'dist'),
  },
  devtool: 'inline-source-map',
  devServer: {
    contentBase: path.join(CWD, 'dist'),
    compress: true,
    port: 3331,
  },
  resolve: resolve(),
}
