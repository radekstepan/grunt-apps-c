#!/usr/bin/env coffee
proxy  = do require('proxyquire').noCallThru
assert = require 'assert'
async  = require 'async'
fs     = require 'fs'
_      = require 'lodash'
stripC = require 'strip-ansi'

# Track errors here.
errors = []

log =
    'subhead': -> log
    'error': (err) ->
        errors.push stripC do err.toString
        log
    'or':
        'error': -> log
    'write': -> log
    'writeln': -> log
    'writeflags': -> log
    'ok': -> log
    'header': -> log
    'initColors': -> log
    'header': -> log
    'debug': -> log
    'wordlist': -> log

log.verbose = log

# Abuse these deps.
deps =
    './grunt/fail':
        'code':
            'TASK_FAILURE': null
        'report': ->
        'fatal': ->
        'warn': (err) -> errors.push stripC do err.toString
    # The actual error message is logged, not thrown...
    './grunt/log': log

# Proxy require grunt.
grunt = proxy 'grunt', deps

# Do not use a Gruntfile.
grunt.task.init = ->

# Load our builder.
grunt.loadTasks('tasks')

# Here we are.
dir = __dirname

# Some defaults true to all tests.
defaults = (test) ->
    src: [ "test/fixtures/#{test}/src/**/*.{coffee,litcoffee,js,json,eco,mustache}" ]
    dest: "test/fixtures/#{test}/build/app.actual.js"

# The individual Grunt task options extending the defaults.
tests =
    apps_c:
        commonjs_test_pass: (test) ->
            [
                options:
                    main: "test/fixtures/#{test}/src/index.js"
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

        commonjs_test_noname: (test) ->
            [
                options:
                    main: "test/fixtures/#{test}/src/index.js"
            , ([ a, b ], cb) ->
                assert.deepEqual errors, [
                    'Package name is not defined'
                    "Error: Task \"apps_c:#{test}\" failed."
                ]
                do cb
            ]

        commonjs_test_nomain: (test) ->
            [
                options:
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

        commonjs_test_noindex: (test) ->
            [
                options:
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                assert.deepEqual errors, [
                    'Main index file not defined'
                    "Error: Task \"apps_c:#{test}\" failed."
                ]
                do cb
            ]

        commonjs_test_names: (test) ->
            [
                options:
                    name: [ 'TestApp', 'MyApp' ]
            , ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

        commonjs_test_litcoffee: (test) ->
            [
                options:
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

        commonjs_test_mustache: (test) ->
            [
                options:
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

        commonjs_test_lineno: (test) ->
            [
                options:
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                assert.deepEqual errors, [
                    "test/fixtures/#{test}/src/app.coffee:2:21: error: unexpected TERMINATOR"
                    "Error: Task \"apps_c:#{test}\" failed."
                ]
                do cb
            ]

        commonjs_test_dupes: (test) ->
            [
                options:
                    main: "test/fixtures/#{test}/src/index.js"
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                assert.deepEqual errors, [
                    "Duplicate file test/fixtures/#{test}/src/index.js"
                    "Error: Task \"apps_c:#{test}\" failed."
                ]
                do cb
            ]

        commonjs_test_json_fail: (test) ->
            [
                options:
                    main: "test/fixtures/#{test}/src/app.coffee"
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                assert.deepEqual errors, [
                    """
                    test/fixtures/#{test}/src/data.json: error: Parse error on line 4:
                    ...     "name": "Webb "Webster" Lucas",   
                    -----------------------^
                    Expecting 'EOF', '}', ':', ',', ']', got 'undefined'
                    """
                    "Error: Task \"apps_c:#{test}\" failed."
                ]
                do cb
            ]

        commonjs_test_json_pass: (test) ->
            [
                options:
                    main: "test/fixtures/#{test}/src/app.coffee"
                    name: 'TestApp'
            , ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

        loader_test_only: (test) ->
            [ {}, ([ a, b ], cb) ->
                _.each errors, assert.ifError
                assert.equal a, b
                do cb
            ]

# Export Mocha tests.
for test, options of tests.apps_c then do (test, options) ->
    # Create the config proper.
    [ opts, handler ] = options test
    tests.apps_c[test] = _.extend defaults(test), opts

    exports[test] = (done) ->
        # Run the task.
        async.waterfall [
            _.partial(grunt.tasks, [ "apps_c:#{test}" ], {})

        # Load actual & expected.
        , (cb) ->
            async.map [
                'app.actual.js'
                'app.expected.js'
            ], (name, cb) ->
                fs.readFile "#{dir}/fixtures/#{test}/build/#{name}", 'utf-8', (err, file) ->
                    # Silence!
                    cb null, file
            , cb

        # Compare sending it to a handler.
        , handler

        # Cleanup.
        , (cb) ->
            errors = []
            fs.unlink "#{dir}/fixtures/#{test}/build/app.actual.js", (err) ->
                # Silence!
                do cb

        ], (err) ->
            assert.ifError err
            do done

# Init the config inside Grunt.
grunt.initConfig tests