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

const meshProps = ['position', 'index']

export function getPlanetMesh(id) {
  return Promise.all(
    meshProps.map(meshProp =>
      client.query({
        query: gql`
      {
        planetWireframe(id: "${id}") {
          wireframe {
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
            [meshProp]: get(
              results[mpi],
              `data.planetWireframe.wireframe.${meshProp}`,
            ),
          }),
        {},
      ),
    err => console.log('[Mesh query]', err),
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
    .then(result => result, err => console.log('[Frame mutation]', err))
}

export function requisitionPlanet(divisions) {
  return client
    .mutate({
      mutation: gql`
      mutation {
        createPlanet(divisions: ${divisions}) {
          id
          divisions
        }
      }
    `,
    })
    .then(
      result => get(result, 'data.createPlanet.id'),
      err => console.log('[Create mutation]', err),
    )
}
