require "bundler/setup"
require "jets"
require 'ruby-prof'

RubyProf.start
Jets.once

result = RubyProf.stop

# print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
io = StringIO.new

printer.print(STDOUT)

<% @vars.functions.each do |function_name|
  handler = @vars.handler_for(function_name)
  meth = handler.split('.').last
-%>
def <%= meth -%>(event:, context:)
  Jets.process(event, context, "<%= handler -%>")
end
<% end %>
