// <%= @path.source.split('/').pop() %>
root.require.register('<%- @package %>/<%- @path.output %>', function(exports, require, module) {
<%- @script %>
});