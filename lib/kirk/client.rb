module Kirk
  class Client
    import org.eclipse.jetty.client.HttpClient
    import org.eclipse.jetty.client.HttpExchange
    import java.net.InetSocketAddress
    import java.util.concurrent.LinkedBlockingQueue
    import org.eclipse.jetty.client.ContentExchange
    import java.util.concurrent.AbstractExecutorService
    import java.util.concurrent.TimeUnit
    import java.util.concurrent.ThreadPoolExecutor
    import java.util.concurrent.ExecutorCompletionService

    class << self
      def group(opts = {})
        client.set_thread_pool if opts.delete(:thread_pool)
        group = Group.new
        group.start(&Proc.new)
        group
      end

      def client
        @client ||= begin
          client = HttpClient.new
          client.set_connector_type(HttpClient::CONNECTOR_SELECT_CHANNEL)
          client.start
          client
        end
      end
    end

    def client
      self.class.client
    end

    def process(request)
      exchange = Exchange.from_request(request)
      client.send(exchange)
    end
  end
end

require 'kirk/client/group'
require 'kirk/client/response'
require 'kirk/client/request'
require 'kirk/client/exchange'
