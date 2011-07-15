$:.unshift File.expand_path('../../build', __FILE__)

# Setup logging
require 'rjack-logback'
RJack::Logback.config_console( :stderr => true,
                               :level => ( ENV['DEBUG_LOG'] ? :debug : :warn ) )

require 'kirk'
require 'fileutils'
require 'openssl'
require 'socket'
require 'zlib'
require 'rack/test'
require 'net/http'

Dir[File.expand_path('../support/*.rb', __FILE__)].each { |f| require f }

IP_ADDRESS     = IPSocket.getaddress(Socket.gethostname)
ORIGINAL_UMASK = File.umask

RSpec.configure do |config|
  config.include SpecHelpers
  config.include Rack::Test::Methods

  config.before :each do
    reset!
  end

  config.after :each do
    File.umask(ORIGINAL_UMASK)
    Kirk::Client.stop
    @server.stop if @server
    @server = nil
  end
end
