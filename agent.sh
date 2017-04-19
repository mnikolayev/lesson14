 nmcli connection reload
 systemctl restart network.service
 grep server.m /etc/hosts
 [ $? -ne 0 ] && echo "192.0.0.100 server.m" >> /etc/hosts
 yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
 yum install -y puppet-agent
 /bin/cp /vagrant/client_puppet.conf /etc/puppetlabs/puppet/puppet.conf
 source ~/.bashrc
 puppet agent --test