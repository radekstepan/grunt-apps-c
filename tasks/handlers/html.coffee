fs = require 'fs'

module.exports = (filepath, cb) ->
    fs.readFile filepath, 'utf8', (err, data) ->
        return cb err if err
        # Convert into JS strings.
        esc = (line) -> '"' + line.replace(/"/g, '\\"') + '"'
        lines = data.split("\n").map(esc).join(',')
        # Export it.
        cb null, """module.exports = [#{lines}].join("\\n");"""