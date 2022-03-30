require_relative('../lib/ip_parser')
IpParser.parse_ips(node)

execute 'apt-get update'

package 'ufw'
package 'wireguard'
package 'net-tools'

remote_file '/etc/sysctl.d/20-enable-port-forwarding.conf' do
  notifies :run, 'execute[reload_sysctl]'
end

execute 'reload_sysctl' do
  command 'sysctl --system'
  action :nothing
end

template '/etc/ufw/applications.d/wireguard' do
  notifies :run, 'execute[wireguard_ufw]'
end

execute 'wireguard_ufw' do
  command 'ufw app update wireguard && ufw allow WireGuard'
  action :nothing
end

template '/etc/wireguard/wg0.conf' do
  notifies :restart, 'service[wg-quick@wg0]'
end

service 'wg-quick@wg0' do
  action [:enable, :start]
end

template '/etc/ufw/wg_append_before.rules' do
  notifies :run, 'execute[append_wg_ufw_rules]'
end

template '/etc/ufw/wg_append_before6.rules' do
  notifies :run, 'execute[append_wg_ufw_rules6]'
end

execute 'append_wg_ufw_rules' do
  command 'cat /etc/ufw/wg_append_before.rules >> /etc/ufw/before.rules'
  action :nothing
  notifies :run, 'execute[reload_ufw]'
end

execute 'append_wg_ufw_rules6' do
  command 'cat /etc/ufw/wg_append_before6.rules >> /etc/ufw/before6.rules'
  action :nothing
  notifies :run, 'execute[reload_ufw]'
end

execute 'reload_ufw' do
  #command 'ufw reload'
  command 'echo "do nothing"'
  action :nothing
end


execute 'allow_wg_vpn_traffic' do
  command 'ufw route allow in on wg0 out on wg0'
end

execute 'allow_wg_forwarding' do
  command "ufw route allow in on wg0 out on #{node[:network_interface]} from #{node[:ipv4_network]}"
end

execute 'allow_wg_forwarding_v6' do
  command "ufw route allow in on wg0 out on #{node[:network_interface]} from #{node[:ipv6_network]}"
end

include_recipe 'dns' if node[:use_dns]

# execute 'echo y  | ufw enable'
