begin
  require_library_or_gem 'rufus/tokyo/tyrant'

  module ActionController
    module Session
      class TokyoStore < AbstractStore
        def initialize(app, options = {})
          # Support old :expires option
          options[:expire_after] ||= options[:expires]

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

          def set_session(env, sid, session_data)
            options = env['rack.session.options']
            expiry  = options[:expire_after] || 0
            @pool[sid] = [session_data, expiry]
            return true
          rescue #Tokyo::TokyoError, Errno::ECONNREFUSED
            return false
          end
      end
    end
  end
rescue LoadError
  # Tokyo wasn't available so neither can the store be
end
