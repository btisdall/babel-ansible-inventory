#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'optparse'

class StaticInventory
  def initialize(config)
    @config = config
    @inventory = {}
  end

  def _add_host_by_attribute(key, value, host)
    if value.is_a?(Array)
      value.each { |x| _add_host_by_attribute(key, x, host) }
      return
    end
    identifier = "#{key}_#{value}"
    @inventory[ identifier ] ||= { 'hosts' => [] }
    @inventory[ identifier ]['hosts'] << host
  end

  def list
    @config['hosts'].each do |h|
      h.keys.each do |attribute|
    
        next unless address = h['address']

        if h[attribute].nil? && h['environment'] && h['role']
          default = 
            begin
              @config['defaults'][ h['environment'] ][ h['role'] ][attribute]
            rescue
              false
            end
          next unless h[attribute] = default
        end
    
        next if h[attribute].nil?

        _add_host_by_attribute(attribute, h[attribute], address)
      end
    end

  return @inventory
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options]"
  opts.on("--list", "List hosts") do |o|
    options[:list] = o
  end
end.parse!(ARGV)

inv = StaticInventory.new( YAML.load(File.read(File.join(File.dirname(__FILE__), 'p.yaml'))) )
print inv.list.to_json if options[:list]

