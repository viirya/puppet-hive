# /etc/puppet/modules/hive/manifests/master.pp

define hiveprinciple {

    exec { "create Hive principle ${name}":
        command => "kadmin.local -q 'addprinc -randkey hive/$name@${hive::params::kerberos_realm}'",
        user => "root",
        group => "root",
        alias => "add-princ-hive-${name}",
        path    => ["/usr/sbin", "/usr/kerberos/sbin", "/usr/bin"],
        require => File["keytab-path"],
        onlyif => "test ! -e ${hive::params::keytab_path}/${name}.hive.service.keytab",  
    }
}
 
define hivekeytab {
    exec { "create Hive keytab ${name}":
        command => "kadmin.local -q 'ktadd -k ${hive::params::keytab_path}/${name}.hive.service.keytab hive/$name@${hive::params::kerberos_realm}'; kadmin.local -q 'ktadd -k ${hive::params::keytab_path}/${name}.hive.service.keytab host/$name@${hive::params::kerberos_realm}'",
        user => "root",
        group => "root",
        alias => "create-keytab-hive-${name}",
        path    => ["/usr/sbin", "/usr/kerberos/sbin", "/usr/bin"],
        require => [ Exec["add-princ-hive-${name}"] ],
        onlyif => "test ! -e ${hive::params::keytab_path}/${name}.hive.service.keytab",
    }
}
 
class hive::cluster::kerberos {

    require hive::params
    require hive
 
    if $hive::params::kerberos_mode == "yes" {

        file { "${hive::params::keytab_path}":
            ensure => "directory",
            owner => "root",
            group => "${hive::params::hadoop_group}",
            mode => "750",
            alias => "keytab-path",
        }
 
        hiveprinciple { $hive::params::hive_masters: 
            require => File["keytab-path"],
        }
 
        hivekeytab { $hive::params::hive_masters: 
            require => File["keytab-path"],
        }

    } 
}

class hive::cluster {

    require hive::params
    require hive
 
    if $hive::params::kerberos_mode == "yes" {

        file { "${hive::params::keytab_path}":
            ensure => "directory",
            owner => "root",
            group => "${hive::params::hadoop_group}",
            mode => "750",
            alias => "keytab-path",
        }
 
        file { "${hive::params::keytab_path}/hive.service.keytab":
            ensure => present,
            owner => "root",
            group => "${hive::params::hadoop_group}",
            mode => "440",
            source => "puppet:///modules/hive/keytab/${fqdn}.hive.service.keytab",
            require => File["keytab-path"],
        }
 
    } 
}
