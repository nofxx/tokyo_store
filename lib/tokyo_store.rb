require 'rufus/tokyo/tyrant'

# Rack Session
if defined?(Rack::Session)
  require "rack/session/abstract/id"
  require "rack/session/tokyo"
end

# # Cache store
# if defined?(Sinatra)
#   require "cache/sinatra/tokyo_store"
# elsif defined?(Rails)
#   require "cache/rails/tokyo_store"
# end

