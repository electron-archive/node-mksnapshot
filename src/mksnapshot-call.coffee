fs      = require 'fs-extra'
path    = require 'path'
{spawn} = require 'child_process'

callMksnapshot = (mksnapshot, content, target, builddir, callback) ->
  fs.writeFile path.join(builddir, 'out.js'), content, (error) ->
    return callback error if error

    child = spawn mksnapshot, ['out.cc', '--startup_blob', 'out.bin', 'out.js'],
      cwd: builddir
    child.on 'error', callback
    child.on 'close', (code) ->
      return callback new Error("mksnapshot returned #{code}") if code isnt 0

      try
        fs.copySync path.join(builddir, 'out.bin'), target
      catch error
        return callback error
      callback null

module.exports = callMksnapshot
