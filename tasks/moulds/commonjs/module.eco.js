<% clean = (input) => %><%- input.replace(/\.[^/.]+$/, '') %><% end %>
// <%= @path.split('/').pop() %>
root.require.register('<%- @package %>/<%- clean @path %>.js', function(exports, require, module) {
<%- @script %>
});