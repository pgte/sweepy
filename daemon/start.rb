#!/usr/bin/env ruby
require 'rubygems'

$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

begin
  require 'choice'  
rescue LoadError => loaderror
  $stderr.puts "\"choice\" gem not detected. Please install it using\n\tsudo gem install choice"
  exit
end

Choice.options do
  
  header ''
  header 'Specific options:'
  
  option :verbose do
    short '-v'
    long '--verbose'
    desc 'Turn on verbose output messages'
  end

  option :daemon do
    short '-d'
    long '--daemon'
    desc 'Run as a daemon'
  end

  option :pidfile do
    short '-p'
    long '--pidfile'
    desc 'Set the pid file path (valid only when in daemon mode)'
  end

  option :admin do
    long '--admin'
    default true
    desc 'Turn on admin interface'
  end

  option :help do
    long '--help'
    desc 'Show this message'
  end
  
end


if Choice.choices.daemon
  pid = fork do
    Signal.trap('HUP', 'IGNORE') # Don't die upon logout
    require File.join(File.expand_path(File.dirname(__FILE__)), 'daemon')
  end
  Process.detach(pid)
  if Choice.choices.pidfile
    File.open(Choice.choices.pidfile, 'w') {|pidfile| pidfile.write(pid.to_s)}
  end
else
  require File.join(File.expand_path(File.dirname(__FILE__)), 'daemon')
end