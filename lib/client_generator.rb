# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'ip_parser'

module ClientGenerator
  def self.generate_keys(group_name, group_count)
    node = JSON.parse(File.read('nenka.json'), symbolize_names: true)
    IpParser.parse_ips(node)

    existing_peer_count = File.read('wireguard/wg0-peers.conf').scan('[Peer]').size

    FileUtils.mkdir_p("wireguard/#{group_name}")

    File.open('wireguard/wg0-peers.conf', 'a') do |serverfile|
      1.upto(group_count) do |index|
        ip = existing_peer_count + index + 1
        ipv4_addr = "#{node[:ipv4_addr] | ip}/32"
        ipv6_addr = "#{node[:ipv6_addr] | ip}/128"
        conf_basename = "wireguard/#{group_name}/familyvpn-#{index}"
        privatekey = `wg genkey`.strip
        pubkey = `echo '#{privatekey}' | wg pubkey`.strip
        File.open("#{conf_basename}.conf", 'w') do |clientfile|
          clientfile.puts <<~EOWG
            [Interface]
            Address = #{ipv4_addr}, #{ipv6_addr}
            PrivateKey = #{privatekey}
            DNS = #{node[:ipv6_host]}

            [Peer]
            PublicKey = #{node[:wg_server_public_key]}
            Endpoint = #{node[:host]}:#{node[:wg_port]}
            AllowedIPs = #{node[:allowed_ips]}
            PersistentKeepalive = 21
          EOWG
        end
        serverfile.puts <<~EOWG
          # #{group_name} #{index}
          [Peer]
          PublicKey = #{pubkey}
          AllowedIPs = #{ipv4_addr}, #{ipv6_addr}

        EOWG
        `qrencode -r #{conf_basename}.conf -o #{conf_basename}.png`
      end
    end

    `zip -j -r wireguard/#{group_name}.zip wireguard/#{group_name}`

    FileUtils.rm_rf("wireguard/#{group_name}")
  end
end
