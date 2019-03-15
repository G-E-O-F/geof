import React from 'react'
import { Route, Switch } from 'react-router-dom'
import Loadable from 'react-loadable'
import Intro from './Intro'

const AllDocs = Loadable({
  loader: () => import(/* webpackChunkName: "alldocs" */ './AllDocs'),
  loading: () => null,
})

const Docs = Loadable({
  loader: () => import(/* webpackChunkName: "docs" */ './Docs'),
  loading: () => null,
})

const NotFound = Loadable({
  loader: () => import(/* webpackChunkName: "notfound" */ './NotFound'),
  loading: () => null,
})

export default () => (
  <Switch>
    <Route exact path="/" component={Intro} />
    <Route exact path="/docs" component={AllDocs} />
    <Route path="/docs/*" component={Docs} />
    <Route component={NotFound} />
  </Switch>
)
