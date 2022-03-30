# frozen_string_literal: true

require 'securerandom'
require 'json'
require_relative 'lib/wireguard'
require_relative 'lib/client_generator'

NODE = JSON.parse(File.read('nenka.json'), symbolize_names: true)
RUN_COMMAND = "itamae ssh --host #{NODE[:host]} --port #{NODE[:ssh_port]} --node-json=nenka.json recipes/main.rb"

desc 'Apply all changes without asking'
task :apply do
  sh RUN_COMMAND
end

desc 'Dry run - list changes to apply, without applying them'
task :dry_run do
  sh "#{RUN_COMMAND} --dry-run"
end

desc 'Connect to the server using SSH'
task :ssh do
  sh "ssh root@#{NODE[:host]} -p #{NODE[:ssh_port]}"
end

desc 'Switch SSH to the non-standard port defined in the config. Run before any other commands.'
task :init_ssh do
  sh "itamae ssh --host #{NODE[:host]} --node-json=nenka.json recipes/ssh.rb"
end

desc 'Initialize configuration files for the rest of files'
task :init do
  keypair = Wireguard.generate_keypair
  File.open('nenka.new.json', 'w') do |f|
    f.puts JSON.pretty_generate(
      host: 'fill.this.in',
      ssh_port: '2222',
      wg_port: '443',
      network_interface: 'eth0',
      ipv4_network: "10.#{rand(256)}.#{rand(256)}.0/24",
      ipv6_network: "fd00:#{SecureRandom.hex(2)}:#{SecureRandom.hex(2)}:#{SecureRandom.hex(2)}::/64",
      wg_server_private_key: keypair[0],
      wg_server_public_key: keypair[1]
    )
  end
  puts "Config file initialized. Open nenka.json and fill in your server's address, check ssh port and network interface."
end

desc 'Generate keys; rake addkeys NAME=mom COUNT=3'
task :addkeys do
  group_name = ENV['NAME']
  group_count = ENV['COUNT'].to_i

  if !group_name || group_count < 1
    puts 'Need NAME and COUNT to generate keys: rake addkeys NAME=bob COUNT=3'
    exit
  end

  ClientGenerator.generate_keys(group_name, group_count)
end
