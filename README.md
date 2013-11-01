#grunt-apps-c

CoffeeScript, JavaScript, Eco in CommonJS/1.1 Modules. AMD/CommonJS/window external interface.

[ ![Codeship Status for radekstepan/grunt-apps-c](https://www.codeship.io/projects/7c42c200-2543-0131-75e4-3aa0f2c98596/status?branch=master)](https://www.codeship.io/projects/8915)

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
                    name: 'MyApp'

    grunt.loadNpmTasks('grunt-apps-c')

    grunt.registerTask('default', [ 'apps_c' ])

```

##Config

The `options.main` property specifies which file will be considered the "main" one for your package. Somehow, the external world needs to know what to get when they call `require(package_name)`. If you do not specify this property the following actions are taken:

1. We try make use of the property `main` as specified in your app's `package.json` file. Failing that, we...
1. try to find the `index.[js|coffee]` file that is closest to the root of your sources.

The `options.name` overrides the name of the package in `package.json`. It specified the name of the exported package as in: `require(name)`.

##CommonJS/1.1 Modules

The following template wraps your modules:

```javascript
// filename
require.register('package/path.js', function(exports, require, module) {
  // ...
});
```