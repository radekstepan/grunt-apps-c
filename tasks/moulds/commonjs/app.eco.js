// Concat modules and export them as an app.
(function(root) {

  // All our modules will use global require.
  (function() {
    <%- @modules.join('\n') %>
  })();

  // Return the main app.
  var main = root.require("<%- @packages[0] %>/<%- @main %>");

  // CommonJS/Modules with all its aliases.
  <% for name in @packages: %>
  root.require.register("<%- name %>", function(exports, require, module) {
    module.exports = main;
  });
  <% end %>

  // AMD/RequireJS.
  if (typeof define === 'function' && define.amd) {
    define("<%- @packages[0] %>", [ /* load deps ahead of time */ ], function () {
      return main;
    });
  }

  // Browser globals.
  root["<%- @packages[0] %>"] = main;

})(this);