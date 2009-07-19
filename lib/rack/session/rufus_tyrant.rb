require 'rufus/tokyo/tyrant'

module Rack
  module Session
    class RufusTyrant < Abstract::ID
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :tyrant_server => "localhost:1978"

      def initialize(app, options = {})
        super
        @mutex = Mutex.new
        @host, @port = *(options[:tyrant_server] || @default_options[:tyrant_server]).split(":") # @default_options)        #options[:cache] ||
        # connecting & closing on each get and put
        # not sure if this is the best option, but otherwise it'll keep
        # opening connections until tyrant freezes... =/
        # tokyo_connect
      #  tokyo_connect
        p @pool
         @pool ||= Rufus::Tokyo::Tyrant.new(@host, @port.to_i)
      end

      private
      # def tokyo_connect
      #   begin

      #   rescue Rufus::Tokyo::TokyoError => e
      #     warn "Can't connect to Tyrant #{e}"
      #   end
      # end

      def get_session(env, sid)
      #  tokyo_connect
        session = Marshal.load(@pool[sid]) rescue session if sid && session = @pool[sid]
        @mutex.lock if env['rack.multithread']
        unless sid && session
          env['rack.errors'].puts("Session '#{sid.inspect}' not found, initializing...") if $VERBOSE and not sid.nil?
          session = {}
          sid = generate_sid
          ret = @pool[sid] = Marshal.dump(session)
          raise "Session collision on '#{sid.inspect}'" unless ret
        end
        session.instance_variable_set('@old', {}.merge(session))
        return [sid, session]
      rescue Rufus::Tokyo::TokyoError => e
        return [nil,  {}]
      ensure
        @mutex.unlock if env['rack.multithread']
      #  @pool.close
      end

      def set_session(env, sid, new_session, options)
      #  tokyo_connect
        @mutex.lock if env['rack.multithread']
        session = Marshal.load(session) rescue session if session = @pool[sid]
        if options[:renew] || options[:drop]
          @pool.delete sid
          return false if options[:drop]
          sid = generate_sid
          @pool[sid] = ""
        end
        old_session = new_session.instance_variable_get('@old') || {}
        session = new_session
        @pool[sid] = options && options[:raw] ? session : Marshal.dump(session)
        return sid
      rescue Rufus::Tokyo::TokyoError => e
        warn "#{self} is unable to find server, error: #{e}"
        warn $!.inspect
      ensure
        @mutex.unlock if env['rack.multithread']
     #   @pool.close
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool[sid]
        end
      end

    end

  end

end
