import React from 'react'
import injectSheet from 'react-jss'
import Page from '../components/Page'

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

export default injectSheet(styles)(Intro)
