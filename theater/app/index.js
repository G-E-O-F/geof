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

let lastT = Date.now()

function onReceivePlanetMesh(result) {
  const mesh = get(result, 'data.planet.mesh', null)
  if (mesh) {
    console.info(
      '[Received planet geometry]',
      mesh.position.length,
      'f',
      mesh.index.length,
      'i',
    )
    console.info('[Latency]', Date.now() - lastT, 'ms')
    setPlanet(mesh)
  } else console.info('[Received non-planet response]', result)
}

function __main__() {
  setRenderer({ canvas: document.querySelector('main canvas') })

  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  play()

  console.info('[Requesting planet geometry]')
  lastT = Date.now()
  getPlanetMesh(17).then(onReceivePlanetMesh)
}

domLoaded.then(__main__)
