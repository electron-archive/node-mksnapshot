fs      = require 'fs'
mkdirp  = require 'mkdirp'
path    = require 'path'
request = require 'request'

REPO_URL = 'https://github.com/atom/electron'

downloadFileToLocation = (url, filename, callback) ->
  stream = fs.createWriteStream filename
  stream.on 'close', callback
  stream.on 'error', callback
  requestStream = request.get(url)
  requestStream.on 'error', callback
  requestStream.on 'response', (response) ->
    if response.statusCode is 200
      requestStream.pipe stream
    else
      callback new Error("Server responded #{response.statusCode}")

unzipFile = (zipPath, callback) ->
  DecompressZip = require 'decompress-zip'
  unzipper = new DecompressZip(zipPath)
  unzipper.on 'error', callback
  unzipper.on 'extract', -> callback(null)
  unzipper.extract path: path.dirname(zipPath)

getPathOfMksnapshot = (version, arch, builddir, callback) ->
  mksnapshot = path.join builddir, 'mksnapshot'
  mksnapshot+= '.exe' if process.platform is 'win32'

  versionFile = path.join builddir, '.mksnapshot_version'
  fs.readFile versionFile, (error, currentVersion) ->
    if not error and String(currentVersion).trim() is version
      return callback null, mksnapshot

    mkdirp builddir, (error) ->
      return callback error if error

      filename = "mksnapshot-v#{version}-#{process.platform}-#{arch}.zip"
      url = "#{REPO_URL}/releases/download/v#{version}/#{filename}"
      target = path.join builddir, filename
      downloadFileToLocation url, target, (error) ->
        return callback error if error

        unzipFile target, (error) ->
          return callback error if error

          try
            if process.platform isnt 'win32'
              fs.chmodSync mksnapshot, '755'
            fs.writeFileSync versionFile, version
          catch error
            return callback error
          callback null, mksnapshot

module.exports = getPathOfMksnapshot
