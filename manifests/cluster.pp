# /etc/puppet/modules/hive/manifests/master.pp

class hive::cluster {

    require hive::params
    require hive

}
