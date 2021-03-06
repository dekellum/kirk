require 'thread'
require 'net/http'

module SpecHelpers
  class Proxy

    # A wrapper around the Net/HTTP response body
    # that allows rack to stream the result down
    class Body
      def initialize(queue)
        @queue = queue
      end

      def each
        while chunk = @queue.pop
          if Exception === chunk
            raise chunk
          else
            yield chunk
          end
        end
      end
    end

    def initialize(ctx)
      @ctx = ctx
    end

    def call(env)
      queue = run_request(env, @ctx.host, @ctx.port, env['PATH_INFO'])

      msg = queue.pop

      if Exception === msg
        raise msg
      else
        [ msg[0], msg[1], Body.new(queue) ]
      end
    end

  private

    KEEP = [ 'CONTENT_LENGTH', 'CONTENT_TYPE' ]

    def run_request(env, host, port, path)
      queue = Queue.new

      if env['CONTENT_LENGTH'] || env['HTTP_TRANSFER_ENCODING']
        body = env['rack.input']
      end

      if env['QUERY_STRING'] && !env['QUERY_STRING'].empty?
        path += "?#{env['QUERY_STRING']}"
      end

      http = Net::HTTP.new(host, port)
      http.read_timeout = 60
      http.open_timeout = 60

      req_hdrs = env_to_http_headers(env)
      # Will magically set the content type :(
      req_hdrs['Content-Type'] = "" unless req_hdrs.key?('Content-Type')

      request = Net::HTTPGenericRequest.new(
        env['REQUEST_METHOD'], !!body, true, path,
        req_hdrs)

      request.body_stream = body if body

      Thread.new do
        begin
          http.request(request) do |response|
            hdrs = {}
            response.each_header do |name, val|
              hdrs[name] = val
            end

            queue << [ response.code.to_i, hdrs ]

            response.read_body do |chunk|
              queue << chunk
            end

            queue << nil
          end
        rescue Exception => e
          queue << e
        end
      end

      queue
    end

    def env_to_http_headers(env)
      {}.tap do |hdrs|
        env.each do |name, val|
          next unless name.is_a?(String)
          next unless name =~ /^HTTP_/ || KEEP.include?(name)

          hdrs[ headerize(name) ] = val
        end
      end
    end

    def headerize(str)
      parts = str.gsub(/^HTTP_/, '').split('_')
      parts.map! { |p| p.capitalize }.join('-')
    end
  end

  def app
    @app ||= Proxy.new(self)
  end

  def host
    @host || '127.0.0.1'
  end

  def port
    @port || 9090
  end

  def host!(host, port = 9090)
    @host, @port = host, port
  end
end
