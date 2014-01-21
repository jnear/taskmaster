require 'fileutils'
require 'webrick'
require 'webrick/httpproxy'

$tasks = Hash.new

root = File.expand_path(File.dirname(__FILE__))
cb = lambda do |req, res| 
  # req.query[:dirs] = Dir["*/"]
  # #req.query[:graph_string] = graph.to_s
  # req.query[:rails_root] = req.path.to_s
  # req.query[:log] = []
end


class NewTask < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req,resp)
    puts req.query
    $tasks[req.query['id']] = req.query['domain']
    puts $tasks

    resp.body = 'Hello World'
    raise WEBrick::HTTPStatus::OK
  end
end

class DeleteTask < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req,resp)
    puts req.query
    $tasks.delete(req.query['id'])

    puts $tasks

    resp.body = 'Hello World'
    raise WEBrick::HTTPStatus::OK
  end
end

proxy_handler = lambda do |req, res|
  #puts "[REQUEST] " + req.request_line
  puts "unparsed uri is " + req.unparsed_uri.to_s
  uri = req.unparsed_uri.to_s
  no_http = uri.gsub('http://', '')
  only_domain = no_http.split('/').first

  host, port = only_domain.split(":", 2)
  domain = host.split(".").last(2).join(".").to_s

  puts "requesting domain " + domain.to_s

  unless $tasks.has_value? domain or domain == 'getbootstrap.com'
    puts "DENIED"
    res.header['content-type'] = 'text/html'
    res.header.delete('content-encoding')
    res.body = "Access is denied."
  end
end

WEBrick::HTTPUtils::DefaultMimeTypes['rhtml'] = 'text/html'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root, :RequestCallback => cb

server.mount("/new_task", NewTask)
server.mount("/delete_task", DeleteTask)

proxy = WEBrick::HTTPProxyServer.new :Port => 8080, :AccessLog => [], :ProxyContentHandler => proxy_handler


trap 'INT' do
  server.shutdown
  proxy.shutdown
end

puts "Starting server..."
Thread.new { server.start }

puts "Starting proxy..."
proxy.start

puts "All done!"
