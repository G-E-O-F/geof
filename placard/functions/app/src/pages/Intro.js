import React from 'react'
import Page from '../components/Page'

const THREE = require('three')
require('imports-loader?THREE=three!three/examples/js/controls/OrbitControls')

import { withStyles } from '@material-ui/core'

const styles = {}

class Intro extends React.Component {
  constructor(props) {
    super(props)
    this.animationRoot = React.createRef()
  }

  playIntroAnimation() {
    console.log('[Intro]')
  }

  componentDidMount() {
    this.playIntroAnimation()
  }

  render() {
    return <Page id="intro" description="Simulation engine for stories" />
  }
}

export default withStyles(styles)(Intro)
