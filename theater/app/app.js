import debounce from 'lodash/debounce'
import domLoaded from 'dom-loaded'

import {
  getPlanetMesh,
  getPlanetWireframe,
  requisitionPlanet,
  computeFrame,
} from './link/link'

import {
  play,
  onResize as resizeRenderer,
  setPlanetMesh,
  setPlanetWireframe,
  setRenderer,
  displayFrame,
  setRequestFrame,
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

let running = false
let stepping = false
let $stepButton
let $runButton

function requestSimulationFrame() {
  return computeFrame(sphere_id).then(displayFrame)
}

function onStepClick() {
  if (!stepping) {
    stepping = true
    requestSimulationFrame().then(() => {
      stepping = false
    })
  }
}

function onRunPauseClick() {
  if (running) {
    setRequestFrame(null)
    running = false
    $stepButton.disabled = false
    $runButton.innerHTML = 'Run'
  } else {
    $stepButton.disabled = true
    $runButton.innerHTML = 'Pause'
    setRequestFrame(requestSimulationFrame)
    running = true
  }
}

function __main__() {
  setRenderer({ canvas: document.querySelector('main canvas') })

  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()

  $stepButton = document.querySelector('button[data-action="step"]')
  $stepButton.addEventListener('click', onStepClick)

  $runButton = document.querySelector('button[data-action="run-pause"]')
  $runButton.addEventListener('click', onRunPauseClick)

  console.info('[Requesting planet geometry]')
  lastT = Date.now()

  play()

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
      $stepButton.disabled = false
      $runButton.disabled = false
    })
}

domLoaded.then(__main__)
