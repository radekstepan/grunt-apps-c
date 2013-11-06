fs = require 'fs'
cs = require 'coffee-script'

module.exports = (filepath, cb) ->
    fs.readFile filepath, 'utf8', (err, src) ->
        try
            js = cs.compile src, 'bare': 'on'
            cb null, js
        catch err
            cb err