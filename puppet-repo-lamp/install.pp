node default {

  class { 'apache':                # use the "apache" module
    default_vhost => false,        # don't use the default vhost
    default_mods => false,         # don't load default mods
    mpm_module => 'prefork',        # use the "prefork" mpm_module
  }
   include apache::mod::php        # include mod php
   apache::vhost { 'example.com':  # create a vhost called "example.com"
    port    => '80',               # use port 80
    docroot => '/var/www/html',     # set the docroot to the /var/www/html
  }
  class { 'mysql::server':
    root_password => 'password',
  }
  class { '::mysql::client':
        require => Class['::mysql::server'],
        bindings_enable => true
  }
  file { 'info.php':                                # file resource name
    path => '/var/www/html/info.php',               # destination path
    ensure => file,
    require => Class['apache'],                     # require apache class be used
    source => 'puppet:///modules/apache/info.php',  # specify location of file to be copied
  }
  file { 'db-connect.php':                                # file resource name
    path => '/var/www/html/db-connect.php',               # destination path
    ensure => file,
    require => Class['apache'],                     # require apache class be used
    source => 'puppet:///modules/apache/db-connect.php',  # specify location of file to be copied
  }
  file { 'supervisord.conf':
      path => '/etc/supervisor/conf.d/supervisord.conf',
      ensure => file,
      require => Class['apache'],
      source => 'puppet:///modules/apache/supervisord.conf',
  }
  # Extract the Wordpress bundle
  package { 'supervisor':
      ensure => installed,
  }

}
