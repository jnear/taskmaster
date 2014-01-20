taskmaster
==========

A task-oriented http proxy.

Requires Ruby and probably some other stuff.

Just run "ruby taskmaster.rb" and a web server will start on port
8000, as well as an HTTP proxy on port 8080. Set your browser to have
an HTTP proxy of localhost:8080 (but leave HTTPS alone -- the proxy
doesn't support it). Browse to localhost:8000 for the user interface.

By default, you can't visit any web pages. When you need to use the
web, you go to the Taskmaster interface and type a description for the
task you intend to perform and the domain of the site you're going to
use. A task will be added to the list and as long as it's in the list,
you can browse to the domain you specified. When you're done with the
task, remove it from the list by clicking the X.

The goal of this is to prevent me from wasting time on the web by
forcing myself to specify exactly what I'm going to do before using my
browser.

