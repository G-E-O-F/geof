import express from 'express'

const router = express.Router()

export const establishReqUser = (req, res, next) => {
  req.user = null
  return next()
}

export default router
