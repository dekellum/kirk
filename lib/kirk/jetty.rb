# Only require jars if in the "master" process
unless Kirk.sub_process?
  require 'rjack-slf4j'
  require 'rjack-jetty'
  require 'rjack-jetty/client'
end

module Kirk
  module Jetty
    # Gimme Jetty
    java_import "org.eclipse.jetty.client.HttpClient"
    java_import "org.eclipse.jetty.client.HttpExchange"
    java_import "org.eclipse.jetty.client.ContentExchange"

    java_import "org.eclipse.jetty.io.ByteArrayBuffer"

    java_import "org.eclipse.jetty.server.nio.SelectChannelConnector"
    java_import "org.eclipse.jetty.server.handler.AbstractHandler"
    java_import "org.eclipse.jetty.server.handler.ContextHandler"
    java_import "org.eclipse.jetty.server.handler.ContextHandlerCollection"
    java_import "org.eclipse.jetty.server.Server"

    java_import "org.eclipse.jetty.util.component.LifeCycle"
  end
end
