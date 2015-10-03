#!/usr/bin/env ruby -w

require 'rubygems'
require 'nokogiri'
require 'optparse'
require 'net/http'
require 'highline/import'
require 'pp'

require './hash.rb'

ENDPOINT="http://apicontrol.lunacloud.com:4465/paci/v1.0/ve/"

$verbose = false

def get_password(prompt="Enter Password")
  ask(prompt) {|q| q.echo = false}
end

def parse_cmd(args)
  cmd = {}

  while args.length > 0  do
    opt = args.shift

    case opt
    when "list"
      cmd[:action] = opt
    when "status"
      cmd[:action] = opt
      cmd[:server] = args.shift
      if(cmd[:server] == nil)
        fail_options("Use lunacloud-cli -h for help", "status", "status command requires server argument")
      end
    when "start"
      cmd[:action] = opt
      cmd[:server] = args.shift
      if(cmd[:server] == nil)
        fail_options("Use lunacloud-cli -h for help", "start", "start command requires server argument")
      end
    when "stop"
      cmd[:action] = opt
      cmd[:server] = args.shift
      if(cmd[:server] == nil)
        fail_options("Use lunacloud-cli -h for help", "stop", "stop command requires server argument")
      end
    else
      puts "Unkown option: #{opt}"
    end
  end
  return cmd
end

def put_request(uri, username, password)
  req = Net::HTTP::Put.new(uri.request_uri)
  req.basic_auth username, password
  req.content_type = 'application/xml'

  puts "Put request at #{uri.to_s}" if $verbose

  res = Net::HTTP.start(uri.hostname, uri.port) { |http|
    http.request(req)
  }

  if($verbose)
    # Headers
    res['Set-Cookie']            # => String
    res.get_fields('set-cookie') # => Array
    res.to_hash['set-cookie']    # => Array
    puts "Headers: #{res.to_hash.inspect}"

    # Status
    puts res.code       # => '200'
    puts res.message    # => 'OK'
    puts res.class.name # => 'HTTPOK'

    # Body
    puts res.body
  end

  return res
end

def get_request(uri, username, password)
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth username, password
  req.content_type = 'application/xml'

  res = Net::HTTP.start(uri.hostname, uri.port) { |http|
    http.request(req)
  }

  if($verbose)
    # Headers
    res['Set-Cookie']            # => String
    res.get_fields('set-cookie') # => Array
    res.to_hash['set-cookie']    # => Array
    puts "Headers: #{res.to_hash.inspect}"

    # Status
    puts res.code       # => '200'
    puts res.message    # => 'OK'
    puts res.class.name # => 'HTTPOK'

    # Body
    puts res.body
  end

  return res
end

def lunacloud_ve_list(username, password)
  uri = URI(ENDPOINT)
  res = get_request(uri, username, password);
  if(res.code == '200')
    hash = Hash.from_xml(res.body)
    hash[:ve_list][:ve_info].each { |obj| puts "#{obj[:name]} is #{obj[:state]}" }
  end
end

def lunacloud_ve_status(username, password, name)
  uri = URI(ENDPOINT + name)
  res = get_request(uri, username, password);
  if(res.code == '200')
    hash = Hash.from_xml(res.body)
    pp hash if $verbose
    server = hash[:ve]
    puts "#{server[:name]}:#{server[:id]} => #{server[:state]} (#{server[:description]})"
    puts "IPv4: #{server[:network][:public_ip][:address]}"
    puts "IPv6: #{server[:network][:public_ipv6][:address]}"
    puts "Spec: CPU=>#{server[:cpu][:number]}@#{server[:cpu][:power]}Mhz, RAM=>#{server[:ram_size]}Mb, DISK=>#{server[:ve_disk][:"size"]}GiB"
  else
    pp res
  end
end

def lunacloud_ve_start(username, password, name)
  uri = URI(ENDPOINT + name + "/" + "start")
  res = put_request(uri, username, password);
  puts "FINIHSED PUT"
  if(res.code == '202')
    puts "Request succeeded."
    pp res
  elsif (res.code == '304')
    puts "Already stopped. State not modified."
    puts "Check current status with './lunacloud-cli.rb status #{name}'"
  elsif (res.code == '404')
    puts "Server #{name} not found. Plaese check if it exists."
  else
    puts "Invalid response code: #{res.code}"
    pp res
  end
end

def lunacloud_ve_stop(username, password, name)
  uri = URI(ENDPOINT + name + "/" + "stop")
  res = put_request(uri, username, password);
  if(res.code == '202')
    puts "Request succeeded."
    pp res
  elsif (res.code == '304')
    puts "Already stopped. State not modified."
    puts "Check current status with './lunacloud-cli.rb status #{name}'"
  elsif (res.code == '404')
    puts "Server #{name} not found. Plaese check if it exists."
  else
    puts "Invalid response code: #{res.code}"
    pp res
  end
end

def fail_options(banner, option, message, cmd = false)
  puts "#{option}: #{message}"
  puts ""
  puts banner
  if(cmd)
    command_documentation
  end
  exit
end

def command_documentation
  print <<-EOF
Get information about your account
   list      List all available servers

Manage an existing server
   start      Start a server
   stop       Stop a running server
EOF
end

options = {}

options[:username] = ENV['LUNACLOUD_USER']
options[:password] = ENV['LUNACLOUD_PASSWORD']

OptionParser.new do |opts|
  opts.banner = "Usage: lunacloud-cli.rb cmd [options]"

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    puts
    command_documentation
    exit
  end

  opts.on("-v", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-u", "--username USERNAME", "User name") do |u|
    options[:username] = u
  end

  opts.on("-p", "--password PASSWORD", "Password") do |p|
    options[:password] = p
  end

  opts.on("status SERVER", "show status for server SERVER") do |s|
    options[:status] = true
    options[:server] = s
  end
end.parse!

if(options[:username] == nil)
  fail_options("Use lunacloud-cli -h for help", "username", "Username required")
end

if(options[:password] == nil)
  options[:password] = get_password()
end

$verbose = true if options[:verbose]

cmd = parse_cmd(ARGV)

if(cmd[:action] == "list")
  puts "Retrieving VE list" if($verbose)
  lunacloud_ve_list(options[:username], options[:password])
  exit
end

if(cmd[:action] == "status")
  puts "Retrieving status => #{cmd[:server]}" if($verbose)
  lunacloud_ve_status(options[:username], options[:password], cmd[:server])
  exit
end

if(cmd[:action] == "start")
  puts "Starting server => #{cmd[:server]}" if($verbose)
  lunacloud_ve_start(options[:username], options[:password], cmd[:server])
  exit
end

if(cmd[:action] == "stop")
  puts "Stopping server => #{cmd[:server]}" if($verbose)
  lunacloud_ve_stop(options[:username], options[:password], cmd[:server])
  exit
end

fail_options("Use lunacloud-cli -h for help", "No action", "please pass in an action", true)