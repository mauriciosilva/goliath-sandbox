require 'goliath'

class Hello < Goliath::API
  use Goliath::Rack::Params
  puts env.somevalue
  def response(env)
    [200, {}, "hello #{params[:name]}"]
  end
end


class SimpleView < Goliath::API
  def response(env)
    [200, {}, "simple view"]
  end
end


class RackRoutes < Goliath::API
  get "/hello/:name" do 
    run Hello.new
  end

  get "/simple" do 
    run SimpleView.new
  end

  not_found('/') do
    run Proc.new {|env| [404, {"Content-Type" => "text/html"}, 
              ['Try /hello /simple']]}
  end

  def response(env)
     raise RuntimeException.new("#response is ignored when using maps, so this exception won't raise. See spec/integration/rack_routes_spec.")
  end
end

