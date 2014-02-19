_      = require 'lodash'
async  = require 'async'
glob   = require 'glob'
path   = require 'path'
fs     = require 'fs'
fsx    = require 'node-fs-extra'
eco    = require 'eco'
colors = require 'colors' # used by Grunt, require if we are running tests

dir = __dirname

# Place all moulds/templates here.
moulds = {}

# Place all source file handlers here.
handlers = {}

# We start not initialized yet.
ready = no

# Call these functions when we are ready.
callbacks = []

# Initialize the builder.
async.parallel

    # The moulds.
    'moulds': (cb) ->
        async.waterfall [ (cb) ->
            glob dir + '/moulds/**/*.eco.js', cb

        , (files, cb) ->
            # Process in parallel.
            async.each files, (file, cb) ->
                # Is it a file?
                fs.stat file, (err, stats) ->
                    return cb err if err

                    # Skip directories.
                    return cb null unless do stats.isFile

                    # Read the mould.
                    fs.readFile file, 'utf8', (err, mould) ->
                        return cb err if err

                        # Get a relative from the file.
                        pointer = moulds
                        for i, part of parts = file.match(/moulds\/(.*)\.eco\.js$/)[1].split('/')
                            if parts.length is +i + 1
                                # Make into an Eco function.
                                pointer[part] = (context) ->
                                    eco.render mould, context
                            else
                                pointer = pointer[part] ?= {}

                        cb null
            , cb

        ], cb

    # The handlers.
    'handlers': (cb) ->
        async.waterfall [ (cb) ->
            glob dir + '/handlers/**/*.coffee', cb

        , (files, cb) ->
            # Require them.
            for file in files
                name = path.basename file, '.coffee'
                handlers[name] = require file

            do cb

        ], cb


, (err) ->
    # Trouble?
    process.exit(1) if err

    # Dequeue.
    ready = yes
    ( do cb for cb in callbacks )

# CommonJS app build, by default with a loader.
commonjs = (grunt, cb) ->
    pkg = grunt.config.data.pkg

    # For each in/out config.
    async.each @files, (file, cb) =>
        sources     = file.src
        destination = path.normalize file.dest

        # Any opts?
        opts = @options
            # Main index file.
            'main': do ->
                # A) Use the main file in `package.json`.
                return pkg.main if pkg?.main

                # B) Find the index file closest to the root.
                _(sources)
                .filter((source) ->
                    # Coffee and JS files supported.
                    source.match /index\.(coffee|js)$/
                ).sort((a, b) ->
                    score = (input) -> input.split('/').length
                    score(a) - score(b)
                ).value()[0]

            # Package name.
            'name': pkg.name if pkg?.name

        # Make package name into names.
        return cb 'Package name is not defined' unless opts.name

        opts.name = [ opts.name ] unless _.isArray opts.name

        # Not null?
        return cb 'Main index file not defined' unless opts.main

        # Does the index file actually exist?
        return cb "Main index file #{opts.main.bold} does not exist" unless opts.main in sources

        # Say we use this index file.
        grunt.log.writeln "Using index file #{opts.main.bold}".yellow

        # Remove the extension. It will be a `.js` one.
        opts.main = opts.main.split('.')[0...-1].join('.')

        # Keep track of outputs to detect dupes.
        outputs = []

        # For each source.
        async.map sources, (source, cb) ->
            # Find the handler.
            unless handler = handlers[ext = path.extname(source)[1...]] # sans dot
                return cb "Unrecognized file extension #{ext.bold}"

            # Run the handler.
            handler source, (err, result) ->
                return cb(do ->
                    # The whole error text line.
                    text = source
                    text += ":#{err.line}" if err.line
                    text += ":#{err.column}" if err.column
                    text += ': error'
                    text += ": #{err.message}" if err.message
                ) if err

                # Form the output path, always JS.
                output = source.replace /\.[^/.]+$/, '.js'

                # Do we have a dupe?
                return cb "Duplicate file #{output.bold}" if output in outputs

                # I guess not...
                outputs.push output

                # Wrap it in the module registry.
                cb null, moulds.commonjs.module
                    'package': opts.name[0]
                    'path': { source, output }
                    'script': moulds.lines
                        'spaces': 2
                        'lines': result

        # Merge it into a destination file.
        , (err, modules) ->
            return cb err if err

            # Nicely format the modules.
            modules = _.map modules, (module) ->
                moulds.lines 'spaces': 4, 'lines': module

            out = []

            # By default we are including loader with the build.
            opts.loader ?= yes

            # Loader comes first?
            out.push do moulds.commonjs.loader if opts.loader

            # Write a vanilla version and one packing a requirerer.
            out.push moulds.commonjs.app
                'modules': modules
                'packages': opts.name
                'main': opts.main

            # Write it.            
            try fsx.mkdirsSync path.dirname destination
            fs.writeFile destination, out.join("\n"), cb
    
    , cb

# CommonJS loader only.
loader = (grunt, cb) ->
    # For each in/out config.
    async.each @files, (file, cb) =>
        # Where to?
        destination = path.normalize file.dest
        # What?
        out = do moulds.commonjs.loader
        # Do it.
        try fsx.mkdirsSync path.dirname destination
        fs.writeFile destination, out, cb
    , cb

module.exports = (grunt) ->
    grunt.registerMultiTask 'apps_c', 'CoffeeScript, JavaScript, Eco, Mustache as CommonJS/1.1 Modules', ->
        # Run in async.
        done = do @async

        # Wrapper for error logging, done callback expects a boolean.
        cb = (err) ->
            return do done unless err
            grunt.log.error (do err.toString).red
            done no

        # Once our builder is ready...
        onReady = =>
            # The targets we support.
            switch
                # CommonJS app build.
                when @target.match /^commonjs/
                    commonjs.apply @, [ grunt, cb ]
                # CommonJS loader only.
                when @target.match /^loader/
                    loader.apply @, [ grunt, cb ]
                else
                    cb "Unsupported target `#{@target}`"

        # Hold your horses?
        return do onReady if ready
        callbacks.push onReady