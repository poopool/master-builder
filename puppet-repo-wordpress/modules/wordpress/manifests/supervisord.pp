class wordpress::supervisord {

    # Generate the supervisord.conf file using the template
    file { '/etc/supervisor/conf.d/supervisord.conf':
        ensure => present,
	require => Exec['copy'],
        content => template("wordpress/supervisord.conf.erb")
    }
    
    # Extract the Wordpress bundle
    package { 'supervisor':
        ensure => installed,
    }

}
