// The basics
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { withRouter } from 'react-router'

// Action creators and helpers
import { establishCurrentUser } from './modules/auth'
import { isServer } from './store'

// Components
import Pages from './pages'
import ScrollToTop from './components/ScrollToTop'
import TopNav from './components/TopNav'

// Global styles
import './index.css'

class App extends Component {
  componentWillMount() {
    const { isAuthenticated, currentUser, establishCurrentUser } = this.props
    if (!isServer) establishCurrentUser(isAuthenticated, currentUser)
  }

  render() {
    return (
      <ScrollToTop>
        <div id="app">
          <TopNav pathName={this.props.location.pathname} />
          <div id="content">
            <Pages />
          </div>
        </div>
      </ScrollToTop>
    )
  }
}

const mapStateToProps = state => ({
  isAuthenticated: state.auth.isAuthenticated,
  currentUser: state.auth.currentUser,
})

const mapDispatchToProps = dispatch =>
  bindActionCreators({ establishCurrentUser }, dispatch)

export default withRouter(
  connect(
    mapStateToProps,
    mapDispatchToProps
  )(App)
)
