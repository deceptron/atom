Package = require 'package'
fs = require 'fs'

module.exports =
class AtomPackage extends Package
  metadata: null
  keymapsDirPath: null
  autoloadStylesheets: true

  constructor: ->
    super
    @keymapsDirPath = fs.join(@path, 'keymaps')

  load: ->
    try
      @loadMetadata()
      @loadKeymaps()
      @loadStylesheets() if @autoloadStylesheets
      rootView?.activatePackage(@name, this) if require.resolve(@path)
    catch e
      console.warn "Failed to load package named '#{@name}'", e.stack
    this

  loadMetadata: ->
    if metadataPath = fs.resolveExtension(fs.join(@path, "package"), ['cson', 'json'])
      @metadata = fs.readObject(metadataPath)

  loadKeymaps: ->
    if keymaps = @metadata?.keymaps
      keymaps = keymaps.map (relativePath) =>
        fs.resolve(@keymapsDirPath, relativePath, ['cson', 'json', ''])
      keymap.load(keymapPath) for keymapPath in keymaps
    else
      keymap.loadDirectory(@keymapsDirPath)

  loadStylesheets: ->
    for stylesheetPath in @getStylesheetPaths()
      requireStylesheet(stylesheetPath)

  getStylesheetPaths: ->
    stylesheetDirPath = fs.join(@path, 'stylesheets')
    fs.list(stylesheetDirPath)
