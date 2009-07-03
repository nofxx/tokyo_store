require 'rufus/tokyo/tyrant'

# Rack Session
if defined?(Rack::Session)
  require "rack/session/abstract/id"
  require "rack/session/tokyo"
end





# # Cache store
# if defined?(Sinatra)
#   require "cache/sinatra/redis_store"
# elsif defined?(Merb)
#   # HACK for cyclic dependency: redis-store is required before merb-cache
#   module Merb; module Cache; class AbstractStore; end end end
#   require "cache/merb/redis_store"
# elsif defined?(Rails)
#   require "cache/rails/redis_store"
# end

