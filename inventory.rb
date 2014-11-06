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

  def list
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

        next if h[attribute].nil?

        _make_concat_ids(attribute, h[attribute]).each do |id|
          @inventory[id] ||= { 'hosts' => [] }
          @inventory[id]['hosts'] << hostname
        end
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

inv = StaticInventory.new( YAML.load(File.read(File.join(File.dirname(__FILE__), 'inventory.yaml'))) )
print inv.list.to_json if options[:list]

