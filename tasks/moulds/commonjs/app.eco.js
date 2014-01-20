// Concat modules and export them as an app.
(function(root) {

  // All our modules will use global require.
  (function() {
    <%- @modules.join('\n') %>
  })();

  // Return the main app.
  var main = root.require("<%- @packages[0] %>/<%- @main %>.js");

  // AMD/RequireJS.
  if (typeof define !== 'undefined' && define.amd) {
  <% for name in @packages: %>
    define("<%- name %>", [ /* load deps ahead of time */ ], function () {
      return main;
    });
  <% end %>
  }

  // CommonJS.
  else if (typeof module !== 'undefined' && module.exports) {
    module.exports = main;
  }

  // Globally exported.
  else {
  <% for name in @packages: %>
    root["<%- name %>"] = main;
  <% end %>
  }

  // Alias our app.
  <% for name in @packages: %>
  root.require.alias("<%- @packages[0] %>/<%- @main %>.js", "<%- name %>/index.js");
  <% end %>

})(this);