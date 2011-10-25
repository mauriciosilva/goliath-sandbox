require 'goliath'
require 'goliath/application'
require 'goliath/websocket'
require 'goliath/rack/templates'

require 'pp'

class WebsocketEndPoint < Goliath::WebSocket
  def on_open(env)
    env.logger.info("WS OPEN")
    env['subscription'] = env.channel.subscribe do  |m| 
      puts m.inspect 
      env.stream_send(m) 
    end
    env.channel << "thanks for coming"
  end

  def on_message(env, msg)
    env.logger.info("WS MESSAGE: #{msg}")
    puts env.channel.inspect
    env.channel << msg
  end

  def on_close(env)
    env.logger.info("WS CLOSED")
    env.channel.unsubscribe(env['subscription'])
  end

  def on_response(env)
    env['subscription'] = env.channel.subscribe { |m| env.stream_send(m) }
    env.channel << "thanks for responding"
  end

  def on_error(env, error)
    env.logger.error error
  end
end

class WSInfo < Goliath::API
  include Goliath::Rack::Templates

  def response(env)
    [200, {}, erb(:index, :views => Goliath::Application.root_path('ws'))]
  end
end

class Ws< Goliath::API

  use( Rack::Static,
    :root => Goliath::Application.app_path('public'),
    :urls => ['/javascripts'],
    :cache_control => 'public, max-age=3600'
  )

  get '/', WSInfo
  map '/ws', WebsocketEndPoint
end
