module Rack
  module Session
    class Tokyo < Abstract::ID
      attr_reader :mutex, :pool
      #DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :redis_server => "localhost:6379"


      def initialize(app, options = {})
        # Support old :expires option
        #options[:expire_after] ||= options[:expires]

        super

        @default_options = {
          :namespace => 'rack:session',
          :tyrant_server => 'localhost'
        }.merge(@default_options)

        @pool = options[:cache] || Rufus::Tokyo::Tyrant.new(@default_options[:tyrant_server], 1978) # @default_options)
        # unless @pool.servers.any? { |s| s.alive? }
        #   raise "#{self} unable to find server during initialization."
        # end
        @mutex = Mutex.new

        super
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool.get(sid)
        end
      end


      private
      def get_session(env, sid)
        sid ||= generate_sid
        begin
          session = @pool[sid] || {}
        rescue #Tokyo::TokyoError, Errno::ECONNREFUSED
          session = {}
        end
        [sid, session]
      end

      def set_session(env, sid, session_data, options)
        options = env['rack.session.options']
        #expiry  = options[:expire_after] || 0
        @pool[sid] = session_data
        return sid
      rescue #Tokyo::TokyoError, Errno::ECONNREFUSED
        return false
      end
    end
  end
end
