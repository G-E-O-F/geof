import React from 'react'
import { Link } from 'react-router-dom'

export default fullRoute => props => (
  <Link {...props} to={fullRoute}>
    {props.children}
  </Link>
)
