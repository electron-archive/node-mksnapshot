# mksnapshot

Generates snapshot file for [Electron][Electron].

## Installing

```sh
npm install mksnapshot
```

## Docs

```javascript
var mksnapshot = require('mksnapshot');
```

### mksnapshot(content, target, version, builddir, callback)

Generates snapshot file for `content` and copies to it `target`, `callback` will
be called with `error` when failed, and with `null` when succeeded.

You also need to specify [Electron][Electron]'s `version`, and the `builddir`
where temp files and downloaded binaries will be put.

[Electron]: https://github.com/atom/electron
