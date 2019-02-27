import React from 'react'
import injectSheet from 'react-jss'
import Page from '../components/Page'

import Typography from '@material-ui/core/Typography'

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
    return (
      <Page id="intro" description="Simulation engine for stories">
        <Typography variant="h1" paragraph>
          GEOF
        </Typography>
        <Typography variant="body1">More information coming soon.</Typography>
      </Page>
    )
  }
}

export default injectSheet(styles)(Intro)
