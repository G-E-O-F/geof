import React from 'react'
import Page from '../components/Page'
import Loadable from 'react-loadable'

import Card from '@material-ui/core/Card'
import CardContent from '@material-ui/core/CardContent'
import List from '@material-ui/core/List'
import ListItem from '@material-ui/core/ListItem'
import Typography from '@material-ui/core/Typography'

import { withStyles } from '@material-ui/core'

const styles = ({ breakpoints }) => ({
  hero: {
    textAlign: 'center',
    minHeight: 'calc(90vh - 4rem)',
    boxSizing: 'border-box',
    display: 'flex',
    flexFlow: 'row nowrap',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '2rem',
    [breakpoints.up('sm')]: {
      padding: '4rem',
    },
  },
})

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
    <Typography variant="h1" className={classes.hero}>
      <div>the simulation engine for{'\xa0'}stories</div>
    </Typography>
    <Card>
      <CardContent>
        <Typography variant="h3" paragraph>
          Roadmap
        </Typography>
        <List>
          <ListItem>
            <Typography variant="body1">Surface topology</Typography>
          </ListItem>
          <ListItem>
            <Typography variant="body1">Oceanography & weather</Typography>
          </ListItem>
          <ListItem>
            <Typography variant="body1">
              Generative city & architectural AI
            </Typography>
          </ListItem>
          <ListItem>
            <Typography variant="body1">Multi-agent simulation</Typography>
          </ListItem>
        </List>
      </CardContent>
    </Card>
  </Page>
)

export default withStyles(styles)(Intro)
