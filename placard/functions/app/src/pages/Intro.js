import React from 'react'
import Page from '../components/Page'
import debounce from 'lodash/debounce'
import { withStyles } from '@material-ui/core'

import {
  play,
  onResize as resizeRenderer,
  setRenderer,
} from '../components/IntroScene'

const styles = {
  animationRoot: {
    position: 'fixed',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    zIndex: 0,
    height: [['100%'], '!important'],
    width: [['100%'], '!important'],
  },
}

class Intro extends React.Component {
  constructor(props) {
    super(props)
    this.animationRoot = React.createRef()
    this.onResize = debounce(this._onResize, 500).bind(this)
  }

  playIntroAnimation() {
    play()
  }

  _onResize() {
    const depth = window.devicePixelRatio
    const dims = this.animationRoot.current.getBoundingClientRect()
    const width = dims.width * depth
    const height = dims.height * depth
    resizeRenderer({ width, height })
  }

  componentDidMount() {
    setRenderer({ canvas: this.animationRoot.current })
    window.addEventListener('resize', this.onResize)
    this._onResize()
    this.playIntroAnimation()
  }

  render() {
    const { classes } = this.props
    return (
      <Page id="intro" description="Simulation engine for stories">
        <canvas ref={this.animationRoot} className={classes.animationRoot} />
      </Page>
    )
  }
}

export default withStyles(styles)(Intro)
