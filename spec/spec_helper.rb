$: << File.join(File.dirname(__FILE__), "/../lib")
%W{rubygems spec rack/cache activesupport }.each { |l| require l }
require 'tokyo_store'
require 'rack/session/tokyo'
require 'rack/session/tyrant'
require 'rack/session/cabinet'
require 'cache/tokyo_store'
#require 'rack/cache/tokyo'

#Simple class to test marshal
class City;  attr_accessor :name, :pop;end

Spec::Runner.configure do |config|;end
