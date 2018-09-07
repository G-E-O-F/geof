const THREE = require('three')
require('imports-loader?THREE=three!three/examples/js/controls/OrbitControls')

const scene = new THREE.Scene({
  fog: new THREE.Fog(0x000000, 0.1, 1000),
})

const camera = new THREE.PerspectiveCamera(33, 1, 0.1, 100)
camera.position.set(0, 0, 4.5)
camera.lookAt(new THREE.Vector3(0, 0, 0))

let renderer
let controls

export function setRenderer({ canvas }) {
  renderer = new THREE.WebGLRenderer({
    alpha: true,
    antialias: true,
    canvas,
  })
  controls = new THREE.OrbitControls(camera, renderer.domElement)
}

export function onResize({ width, height }) {
  camera.aspect = width / height
  camera.updateProjectionMatrix()

  if (renderer) renderer.setSize(width, height)
}

let planet

export function setPlanet({ position, normal, index }) {
  if (planet) {
    scene.remove(planet)
    planet = null
  }

  const planetGeometry = new THREE.BufferGeometry()

  planetGeometry.setIndex(new THREE.BufferAttribute(new Uint32Array(index), 1))

  planetGeometry.addAttribute(
    'position',
    new THREE.BufferAttribute(new Float32Array(position), 3),
  )

  planetGeometry.addAttribute(
    'normal',
    new THREE.BufferAttribute(new Float32Array(normal), 3),
  )

  planet = new THREE.Mesh(
    planetGeometry,
    new THREE.MeshBasicMaterial({
      // vertexColors: THREE.VertexColors,
      color: 0xbd460b,
      wireframe: true,
      wireframeLinewidth: 121,
    }),
  )

  scene.add(planet)
}

let playing = false

function onRender() {
  if (renderer && scene && camera) renderer.render(scene, camera)
}

function render() {
  onRender()
  if (playing) requestAnimationFrame(render)
}

export function play() {
  playing = true
  render()
}

export function pause() {
  playing = false
}
