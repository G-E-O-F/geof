import express from 'express'

const router = express.Router()

// Extend `router` with auth endpoints as needed.

export const establishReqUser = (req, res, next) => {
  req.user = null
  return next()
}

export default router
