require 'rack'
require 'byebug'


basic_server = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  path = env['PATH_INFO']
  res['Content-Type'] = 'text/html'
  res.write(path)
  res.finish
end

Rack::Server.start(
  app: basic_server,
  port: 8080

)
