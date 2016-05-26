# == Define: bind::masters
#
# Manage files /etc/named/masters.d and corresponding include statements in
# /etc/named.conf
#
# entries - key is the ip and value is the bind key label
#
#  entries = {
#    '10.1.2.3'    => 'rndc-key',
#    '192.168.1.2' => 'internal-transfer',
#  }
#
define bind::masters (
  $entries,
) {

  validate_hash($entries)

  include ::bind

  file { "${::bind::masters_dir}/${name}":
    ensure  => 'file',
    content => template('bind/masters.erb'),
    owner   => $::bind::user,
    group   => $::bind::group,
    mode    => '0640',
    require => Package['bind'],
  }

  concat_fragment { "bind::masters::${name}":
    target  => $::bind::masters_list,
    content => "include \"${::bind::masters_dir}/${name}\";",
    tag     => 'bind_masters',
  }
}
