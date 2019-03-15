const THREE = require('three')

const matrix = new THREE.Matrix4()
const group = new THREE.Group()
const raycaster = new THREE.Raycaster()
const intersected = []

const scene = new THREE.Scene()

scene.add(new THREE.HemisphereLight(0x808080, 0x606060))
const light = new THREE.DirectionalLight(0xffffff)
light.position.set(0, 6, 0)
light.castShadow = true
light.shadow.camera.top = 12
light.shadow.camera.bottom = -12
light.shadow.camera.right = 12
light.shadow.camera.left = -12
light.shadow.mapSize.set(4096, 4096)
scene.add(light)

const camera = new THREE.PerspectiveCamera(33, 1, 0.1, 100)
camera.position.set(0, 0, 9)
camera.lookAt(new THREE.Vector3(0, 0, 0))

let renderer

let controller1
let controller2

const onSelectStart = function(event) {
  const controller = event.target
  const intersections = getIntersections(controller)

  if (intersections.length > 0) {
    const intersection = intersections[0]
    matrix.getInverse(controller.matrixWorld)

    const object = intersection.object
    object.matrix.premultiply(matrix)
    object.matrix.decompose(object.position, object.quaternion, object.scale)
    object.material.emissive.b = 0.1

    controller.add(object)
    controller.userData.selected = object
  }
}

const onSelectEnd = function(event) {
  const controller = event.target

  if (controller.userData.selected !== undefined) {
    const object = controller.userData.selected
    object.matrix.premultiply(controller.matrixWorld)
    object.matrix.decompose(object.position, object.quaternion, object.scale)
    object.material.emissive.b = 0

    group.add(object)
    controller.userData.selected = undefined
  }
}

const getIntersections = function(controller) {
  matrix.identity().extractRotation(controller.matrixWorld)

  raycaster.ray.origin.setFromMatrixPosition(controller.matrixWorld)
  raycaster.ray.direction.set(0, 0, -1).applyMatrix4(matrix)

  return raycaster.intersectObjects(group.children)
}

const intersectObjects = function(controller) {
  // Do not highlight when already selected
  if (controller.userData.selected !== undefined) return
  const line = controller.getObjectByName('line')
  const intersections = getIntersections(controller)
  if (intersections.length > 0) {
    const intersection = intersections[0]
    const object = intersection.object
    object.material.emissive.r = 0.1
    intersected.push(object)
    line.scale.z = intersection.distance
  } else line.scale.z = 5
}

function cleanIntersected() {
  while (intersected.length) {
    const object = intersected.pop()
    object.material.emissive.r = 0
  }
}

const initVR = function() {
  renderer.vr.enabled = true

  controller1 = renderer.vr.getController(0)
  controller1.addEventListener('selectstart', onSelectStart)
  controller1.addEventListener('selectend', onSelectEnd)
  scene.add(controller1)

  controller2 = renderer.vr.getController(1)
  controller2.addEventListener('selectstart', onSelectStart)
  controller2.addEventListener('selectend', onSelectEnd)
  scene.add(controller2)

  const line = new THREE.Line(
    new THREE.BufferGeometry().setFromPoints([
      new THREE.Vector3(0, 0, 0),
      new THREE.Vector3(0, 0, -1),
    ]),
  )

  line.name = 'line'
  line.scale.z = 5

  controller1.add(line.clone())
  controller2.add(line.clone())

  scene.add(group)
}

export function setRenderer({ canvas }) {
  renderer = new THREE.WebGLRenderer({
    alpha: true,
    antialias: true,
    canvas,
  })
  initVR()
  return renderer
}

export function onResize({ width, height }) {
  camera.aspect = width / height
  camera.updateProjectionMatrix()

  if (renderer) renderer.setSize(width, height)
}

let planet

export function setPlanet({ position, normal, index, vertex_order }) {
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

  planetGeometry.addAttribute(
    'color',
    new THREE.BufferAttribute(new Float32Array(position.length), 3),
  )

  planet = new THREE.Mesh(
    planetGeometry,
    new THREE.MeshStandardMaterial({
      vertexColors: THREE.VertexColors,
      color: 0xffffff,
      roughness: 0.86,
      metalness: 0,
    }),
  )

  planet.userData.vertex_order = vertex_order

  group.add(planet)
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

export function setPlanetFrame(divisions, frame) {
  if (planet) {
    for (let fi = 0; fi < 10 * divisions * divisions + 2; fi += 1) {
      const sides = (isPentagon(fi, divisions) && 5) || 6
      const offset = planet.userData.vertex_order[fi]
      for (let si = 0; si < sides; si += 1) {
        const cc = offset + si * 3
        planet.geometry.attributes.color.array[cc + 0] = frame[fi][0] / 255
        planet.geometry.attributes.color.array[cc + 1] = frame[fi][1] / 255
        planet.geometry.attributes.color.array[cc + 2] = frame[fi][2] / 255
      }
    }
    planet.geometry.attributes.color.needsUpdate = true
  }
}

let playing = false

function onRender() {
  if (renderer && scene && camera && controller1 && controller2) {
    cleanIntersected()
    intersectObjects(controller1)
    intersectObjects(controller2)
    renderer.render(scene, camera)
  }
}

export function play() {
  if (!playing) renderer.setAnimationLoop(onRender)
  playing = true
}
