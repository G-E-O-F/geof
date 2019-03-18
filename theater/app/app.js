import debounce from 'lodash/debounce'
import get from 'lodash/get'
import domLoaded from 'dom-loaded'

import { getPlanetMesh, getPlanetFrame } from './link/link'

import {
  play,
  onResize as resizeRenderer,
  setPlanet,
  setPlanetFrame,
  setRenderer,
} from './scene/scene'

const DIVISIONS = 2

function onResize() {
  const main = document.querySelector('main')
  const depth = window.devicePixelRatio

  const dims = main.getBoundingClientRect()

  const width = dims.width * depth
  const height = dims.height * depth

  resizeRenderer({ width, height })
}

let lastT = Date.now()

function onReceivePlanetMesh(mesh) {
  if (mesh) {
    console.info(
      '[Receive mesh]',
      'success',
      mesh.position.length,
      'f',
      mesh.index.length,
      'i',
    )
    console.info('[Latency]', Date.now() - lastT, 'ms')
    setPlanet(mesh)
  } else console.warn('[Receive mesh]', 'unexpected payload')
}

function onReceivePlanetFrame(result) {
  const frameColors = get(result, 'data.elapseFrame.colors', null)
  const divisions = get(result, 'data.elapseFrame.divisions', null)
  if (frameColors) {
    console.info('[Receive frame]', 'success')
    setPlanetFrame(divisions, frameColors)
  } else console.warn('[Receive frame]', 'unexpected payload')
}

function __main__() {
  setRenderer({ canvas: document.querySelector('main canvas') })

  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  play()

  console.info('[Requesting planet geometry]')
  lastT = Date.now()
  getPlanetMesh(DIVISIONS).then(onReceivePlanetMesh)
}

domLoaded.then(__main__)
