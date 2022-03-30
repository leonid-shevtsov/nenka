# frozen_string_literal: true

require 'ipaddr'

module IpParser
  def self.parse_ips(node)
    node[:ipv4_addr]  = IPAddr.new(node[:ipv4_network], Socket::AF_INET)
    node[:ipv6_addr]  = IPAddr.new(node[:ipv6_network], Socket::AF_INET6)

    node[:ipv4_host] = (node[:ipv4_addr] | 1).to_s
    node[:ipv6_host] = (node[:ipv6_addr] | 1).to_s

    node[:ipv4_wg_address] = "#{node[:ipv4_host]}/#{node[:ipv4_addr].prefix}"
    node[:ipv6_wg_address] = "#{node[:ipv6_host]}/#{node[:ipv6_addr].prefix}"
  end
end
