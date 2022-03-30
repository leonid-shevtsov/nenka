template '/etc/ssh/sshd_config.d/change_port.conf' do
  notifies :run, 'execute[reload_ssh]'
end

execute 'reload_ssh' do
  command 'systemctl restart sshd'
  action :nothing
end

template 'ufw_openssh_config' do
  path '/etc/ufw/applications.d/openssh-custom'
  notifies :run, 'execute[ufw_enable_ssh]'
end

execute 'ufw_enable_ssh' do
  command 'ufw app update openssh-custom && ufw allow OpenSSH-Custom && ufw deny OpenSSH'
  action :nothing
end
