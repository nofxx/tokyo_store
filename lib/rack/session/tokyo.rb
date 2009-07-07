module Rack
  module Session
    class Tokyo < Abstract::ID
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :tyrant_server => "localhost:1978"

      def initialize(app, options = {})
        super
        @mutex = Mutex.new
        @host, @port = *(options[:tyrant_server] || @default_options[:tyrant_server]).split(":") # @default_options)        #options[:cache] ||
        tokyo_connect
      end

      private
      def tokyo_connect
        begin
          @pool = Rufus::Tokyo::Tyrant.new(@host, @port.to_i)
        rescue Rufus::Tokyo::TokyoError => e
          warn "Can't connect to Tyrant #{e}"
        end
      end

      def get_session(env, sid)
        @mutex.lock if env['rack.multithread']
        session = Marshal.load(@pool[sid]) rescue session if sid && session = @pool[sid]
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
        session = {}
      ensure
        @mutex.unlock if env['rack.multithread']
      end

      def set_session(env, sid, new_session, options)
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
