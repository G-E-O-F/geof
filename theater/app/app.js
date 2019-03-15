import debounce from 'lodash/debounce'
import get from 'lodash/get'
import domLoaded from 'dom-loaded'
import { createButton } from './lib/webvr'

import { getPlanetMesh, getPlanetFrame } from './link/link'
import {
  play,
  onResize as resizeRenderer,
  setPlanet,
  setPlanetFrame,
  setRenderer,
} from './scene/scene'

const DIVISIONS = 27

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

function onReceivePlanetFrame(result) {
  const frameColors = get(result, 'data.elapseFrame.colors', null)
  const divisions = get(result, 'data.elapseFrame.divisions', null)
  if (frameColors) {
    console.info('[Received planet color frame]')
    setPlanetFrame(divisions, frameColors)
  }
}

function __main__() {
  document.body.appendChild(
    createButton(
      setRenderer({ canvas: document.querySelector('main canvas') }),
    ),
  )

  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  play()

  console.info('[Requesting planet geometry]')
  lastT = Date.now()
  getPlanetMesh(DIVISIONS)
    .then(onReceivePlanetMesh)
    .then(() => getPlanetFrame(DIVISIONS, 'highlight_icosahedron'))
    .then(onReceivePlanetFrame)
}

domLoaded.then(__main__)
