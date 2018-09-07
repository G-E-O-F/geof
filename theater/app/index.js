import debounce from 'lodash/debounce'
import get from 'lodash/get'
import domLoaded from 'dom-loaded'

import { getPlanetMesh } from './link'

function onResize() {
  const main = document.querySelector('main')
  const canvas = main.querySelector('main canvas')
  const depth = window.devicePixelRatio

  const dims = main.getBoundingClientRect()

  canvas.setAttribute('width', dims.width * depth)
  canvas.setAttribute('height', dims.height * depth)
}

function onReceivePlanetMesh(result) {
  const mesh = get(result, 'data.planet.mesh', null)
  if (mesh)
    console.log(
      '[Successfully received mesh]',
      mesh.position.length,
      mesh.normal.length,
      mesh.index.length,
    )
}

function __main__() {
  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  getPlanetMesh(1).then(onReceivePlanetMesh)
}

domLoaded.then(__main__)
