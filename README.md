#grunt-apps-c

CoffeeScript, JavaScript, Eco in CommonJS/1.1 Modules

##Quick start

Example `Gruntfile`:

```coffeescript
module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        
        apps_c:
            commonjs:
                src: [ 'src/**/*.{coffee,js,eco}' ]
                dest: 'build/app.commonjs.js'
                options:
                    main: 'src/index.js'

    grunt.loadNpmTasks('grunt-apps-c')

    grunt.registerTask('default', [ 'apps_c' ])

```