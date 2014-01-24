async     = require 'async'
fs        = require 'fs'
{ parse } = require 'jsonlint'

module.exports = (filepath, cb) ->
    fs.readFile filepath, 'utf8', (err, json) ->
        try
            parse json
            cb null, "module.exports = #{json};"
        catch err
            cb err