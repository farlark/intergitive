'use strict'

const exec = require('child_process').exec
const os = require('os')
const path = require('path')

function puts (error, stdout, stderr) {
  console.error(error)
  console.log(stdout)
  console.error(stderr)
}

// Run command depending on the OS
if (os.type() === 'Windows_NT') {
  let arc = ''

  switch (os.arch()) {
    case 'x64':
      arc = 'x64'
      break

    case 'x86':
      arc = 'ia32'
      break

    default:
      throw new Error(`Unsupported CPU architecture for Windows: ${arc}`)
  }

  exec(`powershell.exe "${path.join(__dirname, '../post-npm-install-win.ps1')} ${arc}"`, puts)
} else if (os.type() === 'Darwin') {
  let arc = ''

  switch (os.arch()) {
    case 'x64':
      arc = 'x64'
      break

    case 'arm64':
      arc = 'arm64'
      break

    default:
      throw new Error(`Unsupported CPU architecture for macOS: ${os.arch()}`)
  }

  const script = path.join(__dirname, '../post-npm-install-mac.sh')
  exec(`bash "${script}" ${arc}`, puts)
} else { throw new Error('Unsupported OS found: ' + os.type()) }
