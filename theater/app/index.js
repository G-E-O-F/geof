import debounce from 'lodash/debounce'
import domLoaded from 'dom-loaded'

function onResize() {
  const main = document.querySelector('main')
  const canvas = main.querySelector('main canvas')
  const depth = window.devicePixelRatio

  const dims = main.getBoundingClientRect()

  canvas.setAttribute('width', dims.width * depth)
  canvas.setAttribute('height', dims.height * depth)
}

function __main__() {
  window.addEventListener('resize', debounce(onResize, 1e3))
  onResize()
}

domLoaded.then(__main__)
