#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'optparse'

class StaticInventory
  def initialize(config)
    @config = config
    @inventory = {}
  end

  def _make_concat_ids(key, val)
    return [ "#{key}_#{val}" ] if val.is_a?(String)
    if val.is_a?(Array)
      return val.map { |x| _make_concat_ids(key, x) }.flatten
    end
    if val.is_a?(Hash)
      return val.map { |x,y| _make_concat_ids("#{key}_#{x}", y) }.flatten
    end
  end

  def config_by_host
    by_host = []
    @config['hosts'].each do |h|
      next unless hostname = h['hostname']

      h.keys.each do |attribute|
        if h[attribute].nil? && h['environment'] && h['role']
          h[attribute] =
            begin
              @config['defaults'][ h['environment'] ][ h['role'] ][attribute]
            rescue
              next
            end
        end
      end
      by_host << h
    end
    return by_host
  end

  def generate
    self.config_by_host.each do |h|
      next unless hostname = h['hostname']
      h.keys.each do |attribute|

        next if h[attribute].nil?

        _make_concat_ids(attribute, h[attribute]).each do |id|
          @inventory[id] ||= { 'hosts' => [] }
          @inventory[id]['hosts'] << hostname
        end

      end
    end

  return @inventory
  end

  def host(hostname)
    hostvars = self.config_by_host.select { |x| x['hostname'] == hostname }.first || {}
    hostvars.delete('hostname')
    return hostvars
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options]"
  opts.on("--list", "List hosts") do |o|
    options[:list] = o
  end
  opts.on("--host HOSTNAME", "Return data for host") do |o|
    options[:host] = o
  end
end.parse!(ARGV)

data_in = YAML.load(File.read(File.join(File.dirname(__FILE__), 'inventory.yaml')))
inv = StaticInventory.new(data_in)

if options[:list]
  print inv.generate.to_json
  exit
end

if options[:host]
  print inv.host(options[:host]).to_json
  exit
end

