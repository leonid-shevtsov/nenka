package 'unbound'
package 'unbound-host'

service 'systemd-resolved' do
  action [:stop, :disable]
end

remote_file '/var/lib/unbound/root.hints' do
  owner 'unbound'
  group 'unbound'
end

template '/etc/unbound/unbound.conf' do
  notifies :restart, 'service[unbound]'
end

service 'unbound' do
  action [:enable, :start]
end


remote_file '/etc/ufw/applications.d/unbound' do
  notifies :run, 'execute[unbound_ufw]'
end

execute 'unbound_ufw' do
  command 'ufw app update unbound && ufw allow Unbound'
  action :nothing
end

remote_file '/etc/resolv.conf'
