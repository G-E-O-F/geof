import React from 'react'
import { Route, Switch } from 'react-router-dom'
import Loadable from 'react-loadable'

// Example loading thing:
// const Loading = props => {
//   if (props.error) {
//     return (
//       <div>
//         Error! <button onClick={props.retry}>Retry</button>
//       </div>
//     )
//   } else if (props.timedOut) {
//     return (
//       <div>
//         Taking a long time… <button onClick={props.retry}>Retry</button>
//       </div>
//     )
//   } else if (props.pastDelay) {
//     return <div>Loading…</div>
//   } else {
//     return null
//   }
// }

const Intro = Loadable({
  loader: () => import(/* webpackChunkName: "intro" */ './Intro'),
  loading: () => null,
})

const Docs = Loadable({
  loader: () => import(/* webpackChunkName: "intro" */ './Docs'),
  loading: () => null,
})

const NotFound = Loadable({
  loader: () => import(/* webpackChunkName: "notfound" */ './NotFound'),
  loading: () => null,
})

export default () => (
  <Switch>
    <Route exact path="/" component={Intro} />
    <Route path="/docs/*" component={Docs} />
    <Route component={NotFound} />
  </Switch>
)
