# /etc/puppet/modules/hive/manafests/params.pp

class hive::params {

	include java::params

	$version = $::hostname ? {
		default			=> "0.12.0",
	}

 	$file = $::hostname ? {
		default			=> "${version}-bin",
	}
 
 	$hive_user = $::hostname ? {
		default			=> "hduser",
	}
 
 	$hadoop_group = $::hostname ? {
		default			=> "hadoop",
	}
        
	$java_home = $::hostname ? {
		default			=> "${java::params::java_base}/jdk${java::params::java_version}",
	}

	$hadoop_base = $::hostname ? {
		default			=> "/opt/hadoop",
	}
 
	$hadoop_conf = $::hostname ? {
		default			=> "${hadoop_base}/hadoop/conf",
	}
 
	$hive_base = $::hostname ? {
		default			=> "/opt/hive",
	}
 
	$hive_conf = $::hostname ? {
		default			=> "${hive_base}/hive/conf",
	}
 
    $hive_user_path = $::hostname ? {
		default			=> "/home/${hive_user}",
	}             

    $mysql_connector_java = $operatingsystem ? {
        ubuntu => libmysql-java,
        redhat => mysql-connector-java,
        centos => mysql-connector-java,
    }
 
    $mysql_connector_java_jar = $operatingsystem ? {
        ubuntu => "/usr/share/java/mysql-connector-java.jar",
        redhat => "/usr/share/java/mysql-connector-java.jar",
        centos => "/usr/share/java/mysql-connector-java.jar",
    }

    $metastore_server = $::hostname ? {
        default         => "localhost",
    }

    $metastore_host = $::hostname ? {
        default         => "metastore.database",
    }

    $metastore_password = $::hostname ? {
        default         => "",
    }

    $embeded = $::hostname ? {
        default         => "yes",
    }
 
}
