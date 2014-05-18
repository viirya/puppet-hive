# /etc/puppet/modules/hive/manifests/master.pp

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

        exec { "create Hive principle":
            command => "kadmin.local -q 'addprinc -randkey hive/${hive::params::hive_master}@${hive::params::kerberos_realm}'",
            user => "root",
            group => "root",
            alias => "add-princ-hive",
            path    => ["/usr/sbin", "/usr/kerberos/sbin", "/usr/bin"],
            require => File["keytab-path"],
            onlyif => "test ! -e ${hive::params::keytab_path}/hive.service.keytab",  
        }
 
        exec { "create Hive keytab":
            command => "kadmin.local -q 'ktadd -k ${hive::params::keytab_path}/hive.service.keytab hive/${hive::params::hive_master}@${hive::params::kerberos_realm}'; kadmin.local -q 'ktadd -k ${hive::params::keytab_path}/hive.service.keytab host/${hive::params::hive_master}@${hive::params::kerberos_realm}'",
            user => "root",
            group => "root",
            alias => "create-keytab-hive",
            path    => ["/usr/sbin", "/usr/kerberos/sbin", "/usr/bin"],
            require => [ Exec["add-princ-hive"] ],
            onlyif => "test ! -e ${hive::params::keytab_path}/hive.service.keytab",
        }

    } 
}
