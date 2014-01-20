fs = require 'fs'
cs = require 'coffee-script'

module.exports = (filepath, cb) ->
    fs.readFile filepath, 'utf8', (err, src) ->
        try
            js = cs.compile src, { 'bare': 'on', 'literate': yes }
            cb null, js
        catch err
            # Adjust location?
            if err.location
                err.line = err.location.first_line + 1
                err.column = err.location.first_column + 1
            cb err