$: << File.join(File.dirname(__FILE__), "/../lib")
require 'rubygems'
require 'spec'
require 'rack'
# $LOAD_PATH.unshift(File.dirname(__FILE__))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tokyo_store'
require 'rack/session/tokyo'
require 'rack/cache/tokyo_store'
#ENV["RAILS_ENV"] = "test"
require 'activesupport'
require 'active_support'
require 'actionpack'
require 'action_controller'
# require 'action_controller/test_process'
# require 'action_pack'

# ActionController::Base.session_store = :tokyo_store
# #ActionController::Base.ignore_missing_templates = true

# DispatcherApp = ActionController::Dispatcher.new
#     TokyoStoreStoreApp = ActionController::Session::TokyoStore.new(
#                          DispatcherApp, :key => '_s_id')

#Simple class to test marshal
class City
  attr_accessor :name, :pop
end
#require 'spec/rails'

Spec::Runner.configure do |config|

end
