require 'tokyocabinet'
module Rack
  module Session
    class Cabinet < Abstract::ID
      include TokyoCabinet
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :cabinet_file => "session_cabinet.tch"

      def initialize(app, options = {})
        super
        @mutex = Mutex.new
        @db = options[:cabinet_file] || @default_options[:cabinet_file]
        tokyo_connect
      end

      private
      def tokyo_connect
        @pool = HDB.new
        unless @pool.open(@db, HDB::OWRITER | HDB::OCREAT)
          warn "Can't open db file #{@db}"
        end
      end

      def get_session(env, sid)
        #  tokyo_connect
        session = Marshal.load(@pool.get(sid)) rescue session if sid && session = @pool.get(sid)
        @mutex.lock if env['rack.multithread']
        unless sid && session
          env['rack.errors'].puts("Session '#{sid.inspect}' not found, initializing...") if $VERBOSE and not sid.nil?
          session = {}
          sid = generate_sid
          ret = @pool.put(sid, Marshal.dump(session))
          raise "Session collision on '#{sid.inspect}'" unless ret
        end
        #session.instance_variable_put('@old', {}.merge(session))
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
        session = Marshal.load(session) rescue session if session = @pool.get(sid)
        if options[:renew] || options[:drop]
          @pool.out(sid)
          return false if options[:drop]
          sid = generate_sid
          @pool.put(sid, "")
        end
        #old_session = new_session.instance_variable_get('@old') || {}
        session = new_session
        @pool.put(sid, options && options[:raw] ? session : Marshal.dump(session))
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
          break sid unless @pool.get(sid)
        end
      end

    end

  end

end
