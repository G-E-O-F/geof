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

const meshProps = ['position', 'index', 'normal', 'vertex_order']
const meshQuery = 'planetMesh'
const meshType = 'mesh'

export function getPlanetMesh(id) {
  return Promise.all(
    meshProps.map(prop =>
      client.query({
        query: gql`
      {
        ${meshQuery}(id: "${id}") {
          ${meshType} {
            ${prop}
          }
        }
      }`,
      }),
    ),
  ).then(
    results =>
      meshProps.reduce(
        (mesh, prop, mpi) =>
          Object.assign(mesh, {
            [prop]: get(results[mpi], `data.${meshQuery}.${meshType}.${prop}`),
          }),
        {},
      ),
    err => console.log('[Mesh query]', err),
  )
}

const wireframeProps = ['position', 'index']
const wireframeQuery = 'planetWireframe'
const wireframeType = 'wireframe'

export function getPlanetWireframe(id) {
  return Promise.all(
    wireframeProps.map(prop =>
      client.query({
        query: gql`
      {
        ${wireframeQuery}(id: "${id}") {
          ${wireframeType} {
            ${prop}
          }
        }
      }`,
      }),
    ),
  ).then(
    results =>
      wireframeProps.reduce(
        (mesh, prop, mpi) =>
          Object.assign(mesh, {
            [prop]: get(
              results[mpi],
              `data.${wireframeQuery}.${wireframeType}.${prop}`,
            ),
          }),
        {},
      ),
    err => console.log('[Wireframe query]', err),
  )
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

const per_field = 'add_one'

export function computeFrame(id) {
  return client
    .mutate({
      mutation: gql`
      mutation {
        computeFrame(id: "${id}", iterator: "${per_field}") {
          colors
        }
      }
    `,
    })
    .then(
      result => get(result, 'data.computeFrame.colors'),
      err => console.log('[Compute frame]', err),
    )
}
