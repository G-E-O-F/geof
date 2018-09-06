import join from 'lodash/join'

function component() {
  const element = document.createElement('div')

  // Lodash, currently included via a script, is required for this line to work
  element.innerHTML = join(['Hello', 'world'], ' ')

  return element
}

document.body.appendChild(component())
