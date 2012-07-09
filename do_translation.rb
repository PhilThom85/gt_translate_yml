require 'rubygems'
require './google_translate'
require 'yaml'
require 'uri'

# explore the node and do the translation if case otherwise
# go deeper in the nodetree
def resolvenode(n)
  node = ""
  node = {} if n.is_a? Hash
  node = [] if n.is_a? Array
  rs = browse_hash n, node
  return rs if nil != rs
  node
end

# Browse the yaml tree and translate leaves
# returns translated leaf or the name of the node
# node
def browse_hash(h, curyaml)
  result = nil
  if h.is_a? Hash
    h.keys.each do |key|
      curyaml[key] = resolvenode h[key] 
    end
  elsif h.is_a? Array
    h.each_index do |i|
      curyaml[i] = resolvenode h[i] 
    end
  elsif h.is_a? String
    result = ""
    if not h.empty?
      result = @tr.translate :from => @lgstart, :to => @lgdest, :text =>h

      #in case of not translation
      if result == h
        result = 'NT - ' + result
      end
    end
  else
    result = h
  end
  result
end

# returns URI object to proxy if defined in environment variable
def get_defined_proxy
  prime_proxy = ENV.select { |k,v| v if k =~ /http_proxy/i }.first
  if prime_proxy.nil?
    prime_proxy = ENV.select { |k,v| v if k =~ /all_proxy/i }.first
  end
  return nil if prime_proxy.nil?

  URI(prime_proxy[1])
end
# Main entry point

# try to identify the proxy if present
uri = get_defined_proxy

@tr = Google::Translate.new do |agent|
  unless uri.nil?
    agent.set_proxy(uri.host, uri.port, uri.user, uri.password)
  end
end

if 2 != ARGV.length
  puts "Help: ruby runtrad.rb file language_target"
  exit
end

@lgdest = ARGV[1]
@file = ARGV[0]

trad = File.open( @file )
yp = YAML::load_documents( trad )

yp.each do |k|
  klg = k.keys.first
  if klg != @lgdest
    @lgstart = klg
    newyaml = {}
    browse_hash k[klg], newyaml

    allyaml = { @lgdest => newyaml }
    File.open("result_#{@lgstart}_#{@lgdest}.yaml", "w") do |f|
      f.puts allyaml.to_yaml
    end
  end
end
