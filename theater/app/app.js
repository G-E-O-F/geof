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
  setPlanetFrame,
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

  requisitionPlanet(DIVISIONS)
    .then(id => Promise.all([getPlanetMesh(id), getPlanetWireframe(id)]))
    .then(([mesh, wireframe]) => {
      setPlanetMesh(mesh)
      setPlanetWireframe(wireframe)
    })
    .then(() => {
      console.log('[Latency]', `${Date.now() - lastT}ms`)
    })
}

domLoaded.then(__main__)
