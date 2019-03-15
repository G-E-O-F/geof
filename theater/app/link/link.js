import ApolloClient from 'apollo-client'
import { InMemoryCache } from 'apollo-cache-inmemory'
import gql from 'graphql-tag'
import get from 'lodash/get'

// see example 1
import absintheSocketLink from './absinthe-ws-link'

const client = new ApolloClient({
  link: absintheSocketLink,
  cache: new InMemoryCache(),
})

const meshProps = ['position', 'normal', 'index', 'vertex_order']

export function getPlanetMesh(divisions) {
  return Promise.all(
    meshProps.map(meshProp =>
      client.query({
        query: gql`
      {
        planet(divisions: ${divisions}) {
          mesh {
            ${meshProp}
          }
        }
      }`,
      }),
    ),
  ).then(
    results =>
      meshProps.reduce(
        (mesh, meshProp, mpi) =>
          Object.assign(mesh, {
            [meshProp]: get(results[mpi], `data.planet.mesh.${meshProp}`),
          }),
        {},
      ),
    err => console.log('[Frame query]', err),
  )
}

export function getPlanetFrame(divisions, pattern) {
  return client
    .mutate({
      mutation: gql`
      mutation {
        elapseFrame(divisions: ${divisions}, pattern: "${pattern}") {
          divisions
          pattern
          colors
        }
      }
    `,
    })
    .then(result => result, err => console.log('[Frame query]', err))
}
