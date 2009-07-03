require 'rubygems'
#require 'mocha'
#require 'action_controller'
ENV["RAILS_ENV"] = "test"



require 'spec'
#require 'spec/rails'
require 'spec'
require 'activesupport'
require 'active_support'
require 'actionpack'
require 'action_controller'
require 'action_view'
# require 'action_controller/test_process'
# require 'action_pack'

# Show backtraces for deprecated behavior for quicker cleanup.
ActiveSupport::Deprecation.debug = true
ActionController::Base.logger = Logger.new(STDOUT) #"log/debug.log")


$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tokyo_cache_store'
require 'tokyo_session_store'



#include TokyoCabinet
# Rails::Initializer.run do |c|
#   c.action_controller.session_store = :tokyo_store
# end
ActionController::Base.session_store = :tokyo_store
#ActionController::Base.ignore_missing_templates = true

DispatcherApp = ActionController::Dispatcher.new
    TokyoStoreStoreApp = ActionController::Session::TokyoStore.new(
                         DispatcherApp, :key => '_s_id')

#Simple class to test marshal
class City
  attr_accessor :name, :pop
end
#require 'spec/rails'

Spec::Runner.configure do |config|

end
