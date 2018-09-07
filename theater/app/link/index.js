import ApolloClient from 'apollo-client'
import { InMemoryCache } from 'apollo-cache-inmemory'
import gql from 'graphql-tag'

// see example 1
import absintheSocketLink from './absinthe-ws-link'

const client = new ApolloClient({
  link: absintheSocketLink,
  cache: new InMemoryCache(),
})

export function getPlanetMesh(divisions) {
  return client.query({
    query: gql`
      {
        planet(divisions: ${divisions}) {
          divisions
          mesh {
            position
            normal
            index
          }
        }
      }
    `,
  })
}
