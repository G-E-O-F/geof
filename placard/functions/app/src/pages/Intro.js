import React from 'react'
import Page from '../components/Page'
import Loadable from 'react-loadable'

import { withStyles } from '@material-ui/core'

const styles = {}

const IntroSceneLoading = props => {
  if (props.error) {
    return <div>Error!</div>
  } else if (props.timedOut) {
    return <div>Taking a long time…</div>
  } else if (props.pastDelay) {
    return <div>Loading…</div>
  } else {
    return null
  }
}

const IntroScene = Loadable({
  loader: () =>
    import(/* webpackChunkName: "introscene" */ '../components/IntroScene'),
  loading: IntroSceneLoading,
})

const Intro = ({ classes }) => (
  <Page id="intro" description="Simulation engine for stories">
    <IntroScene />
  </Page>
)

export default withStyles(styles)(Intro)
