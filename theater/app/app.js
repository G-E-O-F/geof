import debounce from 'lodash/debounce'
import get from 'lodash/get'
import domLoaded from 'dom-loaded'

import {
  getPlanetMesh,
  getPlanetWireframe,
  requisitionPlanet,
} from './link/link'

import {
  play,
  onResize as resizeRenderer,
  setPlanetMesh,
  setPlanetWireframe,
  setRenderer,
} from './scene/scene'

const DIVISIONS = 25

function onResize() {
  const main = document.querySelector('main')
  const depth = window.devicePixelRatio

  const dims = main.getBoundingClientRect()

  const width = dims.width * depth
  const height = dims.height * depth

  resizeRenderer({ width, height })
}

let lastT = Date.now()

let sphere_id

function __main__() {
  setRenderer({ canvas: document.querySelector('main canvas') })

  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  play()

  console.info('[Requesting planet geometry]')
  lastT = Date.now()

  requisitionPlanet(DIVISIONS)
    .then(id => {
      sphere_id = id
      return Promise.all([
        getPlanetMesh(sphere_id),
        getPlanetWireframe(sphere_id),
      ])
    })
    .then(([mesh, wireframe]) => {
      setPlanetMesh(mesh)
      setPlanetWireframe(wireframe)
    })
    .then(() => {
      const currentT = Date.now()
      console.log('[Geometry]', `latency: ${currentT - lastT}ms`)
      lastT = currentT
    })
}

domLoaded.then(__main__)
