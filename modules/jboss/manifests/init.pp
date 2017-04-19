class jboss{

  $wildfly_service = 'wildfly'
  $jboss_home = '/opt/wildfly-10.1.0.Final/'
  $java_version = '1.8.0'


  package { 'java':
    name => "java-$java_version-openjdk.x86_64",
    ensure => installed,
    }
  
  package { 'unzip':
    ensure => installed,
    }

    package { 'wget':
    ensure => installed,
    }

  exec { 'jboss  install':
      command => "wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz; tar xf wildfly-10.1.0.Final.tar -C /opt/wildfly-10.1.0.Final/ --strip-components=1 ",
      path => ['/usr/bin', '/usr/sbin',],
  }

  file { $jboss_home:
      ensure  => directory,
      path    => $jboss_home,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => 'remote',
      require => Package['java']
      notify  => Exec[jboss  install]
      }
      
  file { '/etc/init.d/wildfly':
  content => template('jboss/jboss-init.sh.erb'),
  owner   => root,
  group   => root,
  mode    => '0755',
  ensure => file,
  notify  => Service[$wildfly_service]
  }
  
  service { $wildfly_service:
      ensure => 'running',
      enable => true,
      require => Exec['Register_init']
    }

  exec { 'Register_init':
      command => "chkconfig --add /etc/init.d/wildfly",
      path => ['/usr/bin', '/usr/sbin',],
  }
      
}

class deploy{

  $from = "http://www.cumulogic.com/download/Apps/testweb.zip" 
  $what = "/opt/wildfly-10.1.0.Final/standalone/deployments/testweb.zip"
  $where = "/opt/jboss-as-7.1.1/standalone/deployments/"

  file { $to:
      ensure  => file,
      source  => $from,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      }

  exec {'unzip':
      command => "unzip -j ${what} -d ${where}",
      path => ['/usr/bin', '/usr/sbin',],
      creates => "${where}/testweb.war",
  }

}