#!/usr/bin/env ruby
# A quick and dirty implementation of an HTTP proxy server in Ruby
# because I did not want to install anything.
# 
# Copyright (C) 2009 Torsten Becker <torsten.becker@gmail.com>

require 'socket'
require 'uri'
require 'uri/http'

class Proxy  
  def get_host_without_www(uri)
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def run port
    puts "Proxy starting on port " + port.to_s

    begin
      # Start our server to handle connections (will raise things on errors)
      @socket = TCPServer.new port
      
      # Handle every request in another thread
      loop do
        s = @socket.accept
        Thread.new s, &method(:handle_request)
      end
      
    # CTRL-C
    rescue Interrupt
      puts 'Got Interrupt..'
    # Ensure that we release the socket on errors
    ensure
      if @socket
        @socket.close
        puts 'Socked closed..'
      end
      puts 'Quitting.'
    end
  end
  
  def handle_request to_client
    request_line = to_client.readline
    
    verb    = request_line[/^\w+/]
    url     = request_line[/^\w+\s+(\S+)/, 1]
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
    uri     = URI::parse url
    
    domain = get_host_without_www(uri).split(".").last(2).join(".")
    puts "Requested domain " + domain.to_s
    
    # close the socket and quit unless we're allowed to access this domain
    unless $tasks.has_value? domain
      to_client.close
      return
    end

    # Show what got requested
    #puts((" %4s "%verb) + url)
    
    to_server = TCPSocket.new(uri.host, (uri.port.nil? ? 80 : uri.port))
    to_server.write("#{verb} #{uri.path}?#{uri.query} HTTP/#{version}\r\n")
    
    content_len = 0
    
    loop do      
      line = to_client.readline
      
      if line =~ /^Content-Length:\s+(\d+)\s*$/
        content_len = $1.to_i
      end
      
      # Strip proxy headers
      if line =~ /^proxy/i
        next
      elsif line.strip.empty?
        to_server.write("Connection: close\r\n\r\n")
        
        if content_len >= 0
          to_server.write(to_client.read(content_len))
        end
        
        break
      else
        to_server.write(line)
      end
    end
    
    buff = ""
    loop do
      to_server.read(4048, buff)
      to_client.write(buff)
      break if buff.size < 4048
    end
    
    # Close the sockets
    to_client.close
    to_server.close
  end
  
end


