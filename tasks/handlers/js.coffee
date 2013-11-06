fs = require 'fs'

module.exports = (filepath, cb) ->
    fs.readFile filepath, 'utf8', cb