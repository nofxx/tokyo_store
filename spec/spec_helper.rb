require 'rubygems'
#require 'mocha'
require 'active_support'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'tokyo_store'
include TokyoCabinet
Spec::Runner.configure do |config|

end
