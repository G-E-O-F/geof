import debounce from 'lodash/debounce'
import get from 'lodash/get'
import domLoaded from 'dom-loaded'

import { getPlanetMesh } from './link'
import {
  play,
  onResize as resizeRenderer,
  setPlanet,
  setRenderer,
} from './scene'

function onResize() {
  const main = document.querySelector('main')
  const depth = window.devicePixelRatio

  const dims = main.getBoundingClientRect()

  const width = dims.width * depth
  const height = dims.height * depth

  resizeRenderer({ width, height })
}

function onReceivePlanetMesh(result) {
  const mesh = get(result, 'data.planet.mesh', null)
  if (mesh) setPlanet(mesh)
}

function __main__() {
  setRenderer({ canvas: document.querySelector('main canvas') })

  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  play()

  getPlanetMesh(17).then(onReceivePlanetMesh)
}

domLoaded.then(__main__)
