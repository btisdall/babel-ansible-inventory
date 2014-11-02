#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'pp'

class StaticInventory
  def initialize(config)
    @config = config
    @hosts = Hash.new { |k,v| k[v] = {} }
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
    
        if h[attribute].is_a?(Array)
          h[attribute].each do |value|
            @hosts[attribute][ value ] ||= []
            @hosts[attribute][ value ] << address
          end
          next
        end

        @hosts[ attribute ][ h[attribute] ] ||= []
        @hosts[ attribute ][ h[attribute] ] << address
      end
    end

  return @hosts
  end
end

inv = StaticInventory.new( YAML.load(File.read(File.join(File.dirname(__FILE__), 'p.yaml'))) )
print inv.list.to_json if ARGV.shift == '--list'

