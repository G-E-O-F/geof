const THREE = require('three')
require('imports-loader?THREE=three!three/examples/js/controls/OrbitControls')

const divisions = 25

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

const planet = new THREE.Group()
scene.add(planet)

let planetMesh
let planetWireframe

export function setPlanetMesh({ position, normal, index, vertex_order }) {
  if (planetMesh) {
    planet.remove(planetMesh)
    planetMesh = null
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

  planetGeometry.addAttribute(
    'color',
    new THREE.BufferAttribute(new Float32Array(position.length), 3),
  )

  planetMesh = new THREE.Mesh(
    planetGeometry,
    new THREE.MeshBasicMaterial({
      vertexColors: THREE.VertexColors,
    }),
  )

  planetMesh.userData.vertex_order = vertex_order

  planet.add(planetMesh)
}

export function setPlanetWireframe({ position, index }) {
  if (planetWireframe) {
    planet.remove(planetWireframe)
    planetWireframe = null
  }

  const planetGeometry = new THREE.BufferGeometry()

  planetGeometry.setIndex(new THREE.BufferAttribute(new Uint32Array(index), 1))

  planetGeometry.addAttribute(
    'position',
    new THREE.BufferAttribute(new Float32Array(position), 3),
  )

  planetWireframe = new THREE.LineSegments(
    planetGeometry,
    new THREE.LineBasicMaterial({
      color: 0xffffff,
      transparent: true,
      opacity: 0.5,
      linewidth: 8,
    }),
  )

  planetWireframe.scale.set(1.0001, 1.0001, 1.0001)

  planet.add(planetWireframe)
}

function isPentagon(fi, div) {
  if (fi < 2) return true
  else {
    const ll = fi - 2

    const x_lim = div * 2
    const y_lim = div

    const fs = Math.floor(ll / (x_lim * y_lim))
    const fx = Math.floor((ll - fs * x_lim * y_lim) / y_lim)
    const fy = ll - fs * x_lim * y_lim - fx * y_lim

    return fy === 0 && (fx + 1) % div === 0
  }
}

export function displayFrame(frame) {
  if (planet) {
    for (let fi = 0; fi < 10 * divisions * divisions + 2; fi += 1) {
      const sides = (isPentagon(fi, divisions) && 5) || 6
      const offset = planetMesh.userData.vertex_order[fi]
      const colorInt = frame[fi]
      for (let si = 0; si < sides; si += 1) {
        const cc = offset + si * 3
        planetMesh.geometry.attributes.color.array[cc + 0] =
          (colorInt >> 0) & 255
        planetMesh.geometry.attributes.color.array[cc + 1] =
          (colorInt >> 8) & 255
        planetMesh.geometry.attributes.color.array[cc + 2] =
          (colorInt >> 16) & 255
      }
    }
    planetMesh.geometry.attributes.color.needsUpdate = true
  }
}

let rendering = false

function onRender() {
  if (renderer && scene && camera) renderer.render(scene, camera)
}

function render() {
  onRender()
  if (rendering) requestAnimationFrame(render)
}

export function play() {
  rendering = true
  render()
}

export function pause() {
  rendering = false
}
