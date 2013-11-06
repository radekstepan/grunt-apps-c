async = require 'async'
fs    = require 'fs'
eco   = require 'eco'

module.exports = (filepath, cb) ->
    async.waterfall [ (cb) ->
        fs.readFile filepath, 'utf8', cb
    , (src, cb) ->
        try
            template = eco.precompile src
            return cb null, 'module.exports = ' + template
        catch err
            return cb err
    ], cb