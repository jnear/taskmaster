require 'fileutils'
require 'webrick'

require_relative 'proxy'

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


WEBrick::HTTPUtils::DefaultMimeTypes['rhtml'] = 'text/html'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root, :RequestCallback => cb

server.mount("/new_task", NewTask)
server.mount("/delete_task", DeleteTask)

proxy = Proxy.new
trap 'INT' do
  server.shutdown
  raise Interrupt
end


Thread.new {
  server.start
}

proxy.run 8080

