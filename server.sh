	######## after vm provisioning there is possibility that ip address that was specified in vagrant file 
	######## won't be there after  provisioning is over, restart of network service fixes it 
	nmcli connection reload
	systemctl restart network.service
	grep client.m /etc/hosts
	[ $? -ne 0 ] && echo "192.0.0.105 client.m" >> /etc/hosts && echo "192.0.0.110 client1.m" >> /etc/hosts
	######## ям инсталл епта
	yum install -y https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
	yum install -y http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-redhat94-9.4-2.noarch.rpm
	yum install -y puppetserver
	systemctl enable puppetserver
	######## copying files from rsync'ed folder to their destination      
	/bin/cp /vagrant/hosts /etc/
	/bin/cp /vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests
	/bin/cp /vagrant/autosign.conf /etc/puppetlabs/puppet/
	/bin/cp /vagrant/server_puppet.conf /etc/puppetlabs/puppet/puppet.conf
	######## create folders for environments and copy manifest 
	mkdir -p /etc/puppetlabs/code/environments/prod/{manifests,modules}
	/bin/cp /vagrant/prod_site.pp /etc/puppetlabs/code/environments/prod/manifests/site.pp
	######## reload puppet
	systemctl restart puppetserver
	source ~/.bashrc
	######## install postgres 
	yum install postgresql94-server postgresql94-contrib -y
	######## create initial db and copy configs
	/usr/pgsql-9.4/bin/postgresql94-setup initdb
	yes | /bin/cp /vagrant/pg_hba.conf /var/lib/pgsql/9.4/data/
	######## enable and start postgres
	systemctl enable postgresql-9.4.service
	systemctl start postgresql-9.4.service
	######## change directory because of stupid error when executing as postgres
	cd /
	######## create user and db in postgres
	sudo -u postgres psql -c "create user puppetdb password 'puppetdb'"
	sudo -u postgres psql -c "create database puppetdb owner puppetdb"
	######## installing modules in puppet and specifying production env's for them
	puppet module install puppetlabs-puppetdb --version 5.1.2
	puppet module install puppetlabs-mysql --version 3.10.0 --environment prod
	puppet module install puppetlabs-apache --version 1.11.0
	puppet module install spotify-puppetexplorer --version 1.1.1
	puppet module install puppet-nginx --version 0.6.0 --environment prod
	######## lauch and test
	puppet agent -t
	######## stop iptables and add rule to selinux to passthrough httpd
	systemctl stop iptables
	puppet cert list --all
	setsebool -P httpd_can_network_connect on
	###yeah
	