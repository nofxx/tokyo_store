require 'rufus/tokyo/tyrant'
# require 'tokyocabinet'

module ActiveSupport
  module Cache

    # A cache store implementation which stores data in Tokyo Cabinet
    #
    # Special features:
    # - Clustering and load balancing. TODO
    # - Time-based expiry support. TODO (Lua)
    # - Per-request in memory cache for all communication with the Tokyo server(s).
    class TokyoStore < Store

      def self.build_tokyo(*store)
        store = store.flatten
        options = store.extract_options!
        #TODO: multiple instances
        store = store.empty? ? ["localhost", 45001]  : store[0].split(":")

        #TODO: Auto choice between tyrant ffi x tyrant pure ruby x cabinet C
        # Tyrant FFI
        Rufus::Tokyo::Tyrant.new(store[0], store[1].to_i)

        # Cabinet C
        #hdb = HDB.new
        # if !hdb.open(store[0], HDB::OWRITER | HDB::OCREAT)
        #   ecode = hdb.ecode
        #   STDERR.printf("open error: %s\n", hdb.errmsg(ecode))
        # end
        # hdb
      end

      # Creates a new TokyoStore object, with the given tyrant server
      # addresses. Each address is either a host name, or a host-with-port string
      # in the form of "host_name:port". For example:
      #
      #   ActiveSupport::Cache::TokyoStore.new("localhost", "server-downstairs.localnetwork:8229")
      #
      # If no addresses are specified, then TokyoStore will connect to
      # localhost port 45001 (the default memcached port).
      def initialize(*store)
        if store.first.respond_to?(:get)
          @data = store.first
        else
          @data = self.class.build_tokyo(*store)
        end

        extend Strategy::LocalCache
      end

      # Reads multiple keys from the cache.
      def read_multi(*keys)
        keys.map { |k| read(k) }
        #TODO native?
      end

      def read(key, options = nil) # :nodoc:
        super
        @data[key] ? Marshal.load(@data[key]).freeze : nil
        # if str = @data.get(key)
        #   Marshal.load str
        #   else
        #   STDERR.printf("get error: %s\n", @data.errmsg(@data.ecode))
        #   end
        # logger.error("TokyoError (#{e}): #{e.message}")
        # nil
      end

      # Writes a value to the cache.
      #
      # Possible options:
      # - +:unless_exist+ - set to true if you don't want to update the cache
      #   if the key is already set.
      # - +:expires_in+ - the number of seconds that this value may stay in
      #   the cache. See ActiveSupport::Cache::Store#write for an example.
      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :add : :set
        # memcache-client will break the connection if you send it an integer
        # in raw mode, so we convert it to a string to be sure it continues working.
        value = value.to_s if raw?(options)
        value = Marshal.dump value # if value.instance_of? Hash
        @data[key] = value
        ###response = @data.put(key, value) || STDERR.printf("get error: %s\n", @data.errmsg(@data.ecode))#, expires_in(options), raw?(options))
        # logger.error("TokyoError (#{e}): #{e.message}")
        # false
      end

      def delete(key, options = nil) # :nodoc:
        super
        @data.delete(key) #= nil #, expires_in(options))
      end

      def exist?(key, options = nil) # :nodoc:
        # Doesn't call super, cause exist? in memcache is in fact a read
        # But who cares? Reading is very fast anyway
        # Local cache is checked first, if it doesn't know then memcache itself is read from
        !read(key, options).nil?
      end

      def increment(key, amount = 1) # :nodoc:
        #NATIVE, JUST SEE ABOUT MARSHAL
        @data.incr(key, amount)
      end

      def decrement(key, amount = 1) # :nodoc:
        # WARNING! NATIVE, BUT UGLY
        @data.incr(key, -amount)
      end

      def delete_matched(matcher, options = nil) # :nodoc:
        #TODO
      end

      def clear
        @data.clear
      end

      def stats
        @data.stat
      end

      private
        #TODO
        def expires_in(options)
          (options && options[:expires_in]) || 0
        end

        def raw?(options)
          options && options[:raw]
        end


    end

  end
end
