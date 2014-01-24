#grunt-apps-c [![Built with Grunt](https://cdn.gruntjs.com/builtwith.png)](http://gruntjs.com/)

CoffeeScript, JavaScript, JSON, Eco, Mustache as CommonJS/1.1 Modules. AMD/CommonJS/window external interface.

[ ![Codeship Status for radekstepan/grunt-apps-c](https://www.codeship.io/projects/7c42c200-2543-0131-75e4-3aa0f2c98596/status?branch=master)](https://www.codeship.io/projects/8915)

##Quick start

Example `Gruntfile.coffee`:

```coffeescript
module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        
        apps_c:
            commonjs:
                src: [ 'src/**/*.{coffee,litcoffee,js,json,eco,mustache}' ]
                dest: 'build/app.js'
                options:
                    main: 'src/index.js'
                    name: 'MyApp'

    grunt.loadNpmTasks('grunt-apps-c')

    grunt.registerTask('default', [ 'apps_c' ])
```

You can now include the `build/app.js` file and, depending on your surrounding environment, you will be able to load it using RequireJS/AMD, CommonJS or straight from `window` under the `MyApp` key.

##Config

###Main module

The `options.main` property specifies which file will be considered the "main" one for your package. Somehow, the external world needs to know what to get when they call `require(package_name)`. If you do not specify this property the following actions are taken:

1. We try make use of the property `main` as specified in your app's `package.json` file. Failing that, we...
1. try to find the `index.[js|coffee]` file that is closest to the root of your sources.

###Package name

The `options.name` overrides the name of the package in `package.json`. It specified the name of the exported package as in: `require(name)`. One can pass in an array of names, as alternatives, as well.

###Loader only

Sometimes the occasion calls for a loader to be separated out into its own file. One might want, for example, include a loader, then vendor dependencies and then the actual app build.

To create a build in `dest` without the loader included:

```coffeescript
module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        
        apps_c:
            commonjs:
                src: [ 'src/**/*.{coffee,js,eco,mustache}' ]
                dest: 'build/app.js'
                options:
                    main:   'src/index.js'
                    name:   'MyApp'
                    loader: no

    grunt.loadNpmTasks('grunt-apps-c')

    grunt.registerTask('default', [ 'apps_c' ])
```

Notice the boolean `loader` option.

By the same token, you might want to produce only a loader:

```coffeescript
module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON("package.json")
        
        apps_c:
            loader:
                dest: 'build/loader.js'

    grunt.loadNpmTasks('grunt-apps-c')

    grunt.registerTask('default', [ 'apps_c' ])
```

Notice that we are asking for a `loader` target and are providing only `dest`; file location where our loader will be created.

##Types

The filetypes you can use (handlers) are listed in `tasks/`. The base filename of a handler represents the extension we match against.

Languages that have an `*` after them support [linting](http://stackoverflow.com/questions/8503559/what-is-linting).

###Programming languages

####CoffeeScript*

[CoffeeScript](http://coffeescript.org/) is a programming language that transcompiles to JavaScript. The language adds syntactic sugar inspired by Ruby, Python and Haskell to enhance JavaScript's brevity and readability, adding additional features like list comprehension and pattern matching.

Besides being used as an ordinary programming language, CoffeeScript may also be written in "literate" mode. If you name your file with a `.litcoffee` extension, you can write it as a [Markdown](http://daringfireball.net/projects/markdown/syntax) document — a document that also happens to be executable CoffeeScript code. The compiler will treat any indented blocks (Markdown's way of indicating source code) as code, and ignore the rest as comments.

####JavaScript

Save your module with a `.js` extension and it will be copied into the build.

###Templating languages

####Eco

Eco templates come precompiled so when you require them, you get back a function that accepts a `context` and returns a string back that you inject into DOM.

An example:

```javascript
var template = require('./templates/layout');
$('body').html(template({ 'name': 'Radek' }));
```

####Mustache

Mustache templates are transpiled into an exported string, so you need to use a library to compile it into a template that can actually be rendered.

For example, to use them inside [canJS](http://canjs.com/guides/Mustache.html) you can do the following:

```javascript
var template = require('./templates/layout');
can.view.mustache('layout', template);
```

###Data Objects

####JSON*

Save your file as a [JSON](http://www.json.org/) and it will be exported to you as a JavaScript object.

##Modules

###CommonJS/1.1 Modules

The following template wraps your modules:

```javascript
// filename.coffee
require.register('package/path.js', function(exports, require, module) {
    // ...
});
```

You can debug all the registered modules in a browser like so:

```javascript
Object.keys(require.modules)
```

##Changelog

####0.1.14

- Transpile [JSON](http://www.json.org/) into JS functions exported as modules.

####0.1.13

- Detect duplicates as when say `.coffee` and `.eco` files are both transpiled into one and the same output module.

####0.1.12

- Allow having a build without a loader and one without any sources. This allows us to include our loader on the page, then vendor dependencies that could be using it and then our app build.
- Fix bug in resolving modules preventing us from throwing an informative error message when a module is not found.

####0.1.11-1

- Showing line number when error is thrown in a task (CoffeeScript atmo).

####0.1.10

- Support for [Mustache](http://mustache.github.io/) logic-less templates. Templates are transpiled into an exported string so you need to then feed it into your particular implementation like [canJS](http://canjs.com/guides/Mustache.html).

##Used by

1. [intermine-apps-c](https://github.com/intermine/intermine-apps-c) - collection of InterMine apps
1. [pomme.js](https://github.com/radekstepan/pomme.js) - JS frames communication
1. [deadmonton](https://github.com/radekstepan/deadmonton) - visualizing crime in Edmonton
1. [github-burndown-chart](https://github.com/radekstepan/github-burndown-chart)