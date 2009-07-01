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

      def self.build_tokyo(*dbs)
        dbs = dbs.flatten
        options = dbs.extract_options!
        dbs = ["localhost"] if dbs.empty?
        Rufus::Tokyo::Tyrant.new(dbs[0], 45001)
        #hdb = HDB.new
        # if !hdb.open(dbs[0], HDB::OWRITER | HDB::OCREAT)
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
      def initialize(*dbs)
        if dbs.first.respond_to?(:get)
          @data = dbs.first
        else
          @data = self.class.build_tokyo(*dbs)
        end

        extend Strategy::LocalCache
      end

      # Reads multiple keys from the cache.
      def read_multi(*keys)
        #TODO @data.get_multi keys
      end

      def read(key, options = nil) # :nodoc:
        super
        Marshal.load(@data[key])
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
        !@data[key] = nil #, expires_in(options))
      end

      def exist?(key, options = nil) # :nodoc:
        # Doesn't call super, cause exist? in memcache is in fact a read
        # But who cares? Reading is very fast anyway
        # Local cache is checked first, if it doesn't know then memcache itself is read from
        !read(key, options).nil?
      end

      def increment(key, amount = 1) # :nodoc:
        write(key, read(key) + amount)
        # TODO native?
      end

      def decrement(key, amount = 1) # :nodoc:
        write(key, read(key) - amount)
        # log("decrement", key, amount)
        #TODO native?
      end

      def delete_matched(matcher, options = nil) # :nodoc:
        #TODO
      end

      def clear
        @data.flush_all
      end

      def stats
        @data.stats
      end

      private
        def expires_in(options)
          (options && options[:expires_in]) || 0
        end

        def raw?(options)
          options && options[:raw]
        end


    end

  end
end
