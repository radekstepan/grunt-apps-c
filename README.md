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

##Config

Say you specify a `dest` output file called `build/app.commonjs.js`, you will actually be building two files:

1. `build/app.commonjs.vanilla.js` which contains only your source files translated into JavaScript and wrapped into CommonJS/1.1 Module wrappers.
2. `build/app.commonjs.require.js` which in additions contains an internal module loader. You probably want to make use of this file. In addition, this loader will be exported globally if an existing `require` loader does not exist.

The `options.main` property specifies which file will be considered the "main" one for your package. Somehow, the external world needs to know what to get when they call `require(package_name)`. If you do not specify this property the following actions are taken:

1. We try make use of the property `main` as specified in your app's `package.json` file. Failing that, we...
1. try to find the `index.[js|coffee]` file that is closest to the root of your sources.

##CommonJS/1.1 Modules

The following mould is being used to wrap your modules:

```javascript
// filename
require.register('package/path.js', function(exports, require, module) {
  // ...
});
```