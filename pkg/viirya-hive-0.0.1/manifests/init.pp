# /etc/puppet/modules/hive/manafests/init.pp

class hive {

	require hive::params
	
# group { "${hive::params::hadoop_group}":
# 	ensure => present,
# 	gid => "800"
# }
# 
# user { "${hive::params::hive_user}":
# 	ensure => present,
# 	comment => "Hadoop",
# 	password => "!!",
# 	uid => "800",
# 	gid => "800",
# 	shell => "/bin/bash",
# 	home => "${hive::params::hive_user_path}",
# 	require => Group["hadoop"],
# }
# 
# file { "${hive::params::hive_user_path}":
# 	ensure => "directory",
# 	owner => "${hive::params::hive_user}",
# 	group => "${hive::params::hadoop_group}",
# 	alias => "${hive::params::hive_user}-home",
# 	require => [ User["${hive::params::hive_user}"], Group["hadoop"] ]
# }
 
	file {"${hive::params::hive_base}":
		ensure => "directory",
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		alias => "hive-base",
	}

 	file {"${hive::params::hive_conf}":
		ensure => "directory",
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		alias => "hive-conf",
        require => [File["hive-base"], Exec["untar-hive"]],
        before => [File["hive-site-xml"], File["hive-init-sh"]]
	}
 
	file { "${hive::params::hive_base}/hive-${hive::params::version}.tar.gz":
		mode => 0644,
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		source => "puppet:///modules/hive/hive-${hive::params::version}.tar.gz",
		alias => "hive-source-tgz",
		before => Exec["untar-hive"],
		require => File["hive-base"]
	}
	
	exec { "untar hive-${hive::params::version}.tar.gz":
		command => "tar xfvz hive-${hive::params::version}.tar.gz",
		cwd => "${hive::params::hive_base}",
		creates => "${hive::params::hive_base}/hive-${hive::params::version}",
		alias => "untar-hive",
		refreshonly => true,
		subscribe => File["hive-source-tgz"],
		user => "${hive::params::hive_user}",
		before => [ File["hive-symlink"], File["hive-app-dir"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
	}

	file { "${hive::params::hive_base}/hive-${hive::params::version}":
		ensure => "directory",
		mode => 0644,
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		alias => "hive-app-dir",
        require => Exec["untar-hive"],
	}
		
	file { "${hive::params::hive_base}/hive":
		force => true,
		ensure => "${hive::params::hive_base}/hive-${hive::params::version}",
		alias => "hive-symlink",
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		require => File["hive-source-tgz"],
		before => [ File["hive-site-xml"], File["hive-init-sh"] ]
	}
	
	file { "${hive::params::hive_base}/hive-${hive::params::version}/conf/hive-site.xml":
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		mode => "644",
		alias => "hive-site-xml",
        require => File["hive-app-dir"],
		content => template("hive/hive-site.xml.erb"),
	}
 
	file { "${hive::params::hive_base}/hive-${hive::params::version}/conf/init.sh":
		owner => "${hive::params::hive_user}",
		group => "${hive::params::hadoop_group}",
		mode => "744",
		alias => "hive-init-sh",
        require => File["hive-app-dir"],
		content => template("hive/init.sh.erb"),
	}

 	exec { "initiate hive":
		command => "./init.sh",
		cwd => "${hive::params::hive_base}/hive-${hive::params::version}/conf",
		alias => "init-hive",
		user => "${hive::params::hive_user}",
		require => [File["hive-init-sh"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin", "${hive::params::hive_base}/hive-${hive::params::version}/conf", "${hadoop_base}/hadoop/bin"],
	}
 
 	exec { "set hive_home":
		command => "echo 'export HIVE_HOME=${hive::params::hive_base}/hive-${hive::params::version}' >> ${hive::params::hive_user_path}/.bashrc",
		alias => "set-hivehome",
        creates => "${hive::params::hive_base}/hive/lib/libmysql-java.jar",
		user => "${hive::params::hive_user}",
		require => [File["hive-app-dir"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
	}
 
 	exec { "set hive path":
		command => "echo 'export PATH=\$PATH:${hive::params::hive_base}/hive-${hive::params::version}/bin' >> ${hive::params::hive_user_path}/.bashrc",
		alias => "set-hivepath",
        creates => "${hive::params::hive_base}/hive/lib/libmysql-java.jar",
		user => "${hive::params::hive_user}",
		before => Exec["set-hivehome"],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
	}
 
    package { "${hive::params::mysql_connector_java}":
        ensure  => installed,
        alias   => "mysql-connector-java",
        require => [File["hive-app-dir"]],
    }

    file { "${hive::params::hive_base}/hive/lib/libmysql-java.jar":
        force => true,
        ensure => "${hive::params::mysql_connector_java_jar}",
        alias => "libmysql-symlink",
        owner => "${hive::params::hive_user}",
        group => "${hive::params::hadoop_group}",
        require => Package["${hive::params::mysql_connector_java}"],
    }

}
