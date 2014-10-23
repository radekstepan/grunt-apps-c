// <%= @path.split('/').pop() %>
root.require.register('<%- @package %>/<%- @path %>', function(exports, require, module) {
<%- @script %>
});