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

const fieldMeshProps = ['position', 'index', 'normal', 'vertex_order']
const fieldMeshQuery = 'planetFieldMesh'
const fieldMeshType = 'mesh'

export function getPlanetFieldMesh(id) {
  return Promise.all(
    fieldMeshProps.map(prop =>
      client.query({
        query: gql`
      {
        ${fieldMeshQuery}(id: "${id}") {
          ${fieldMeshType} {
            ${prop}
          }
        }
      }`,
      }),
    ),
  ).then(
    results =>
      fieldMeshProps.reduce(
        (geometry, prop, mpi) =>
          Object.assign(geometry, {
            [prop]: get(
              results[mpi],
              `data.${fieldMeshQuery}.${fieldMeshType}.${prop}`,
            ),
          }),
        {},
      ),
    err => console.log('[Mesh query]', err),
  )
}

const fieldWireframeProps = ['position', 'index']
const fieldWireframeQuery = 'planetFieldWireframe'
const fieldWireframeType = 'wireframe'

export function getPlanetFieldWireframe(id) {
  return Promise.all(
    fieldWireframeProps.map(prop =>
      client.query({
        query: gql`
      {
        ${fieldWireframeQuery}(id: "${id}") {
          ${fieldWireframeType} {
            ${prop}
          }
        }
      }`,
      }),
    ),
  ).then(
    results =>
      fieldWireframeProps.reduce(
        (geometry, prop, mpi) =>
          Object.assign(geometry, {
            [prop]: get(
              results[mpi],
              `data.${fieldWireframeQuery}.${fieldWireframeType}.${prop}`,
            ),
          }),
        {},
      ),
    err => console.log('[Field wireframe query]', err),
  )
}

const interfieldWireframeProps = ['position', 'index']
const interfieldWireframeQuery = 'planetInterfieldWireframe'
const interfieldWireframeType = 'wireframe'

export function getPlanetInterfieldWireframe(id) {
  return Promise.all(
    interfieldWireframeProps.map(prop =>
      client.query({
        query: gql`
      {
        ${interfieldWireframeQuery}(id: "${id}") {
          ${interfieldWireframeType} {
            ${prop}
          }
        }
      }`,
      }),
    ),
  ).then(
    results =>
      interfieldWireframeProps.reduce(
        (geometry, prop, mpi) =>
          Object.assign(geometry, {
            [prop]: get(
              results[mpi],
              `data.${interfieldWireframeQuery}.${interfieldWireframeType}.${prop}`,
            ),
          }),
        {},
      ),
    err => console.log('[Interfield wireframe query]', err),
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
