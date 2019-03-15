import * as AbsintheSocket from '@absinthe/socket'
import { createAbsintheSocketLink } from '@absinthe/socket-apollo-link'
import { Socket as PhoenixSocket } from 'phoenix'

export default createAbsintheSocketLink(
  AbsintheSocket.create(new PhoenixSocket('ws://35.193.117.169/planet')),
)
