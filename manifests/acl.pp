# == Define: bind::acl
#
# Manage files /etc/named/acls.d and corresponding include statements in
# /etc/named.conf
#
define bind::acl (
  $entries     = undef,
  $keys        = undef,
) {

  if $entries != undef {
    validate_array($entries)
  }
  if $keys != undef {
    validate_array($keys)
  }

  if $entries == undef and $keys == undef{
    fail('There must be at least one parameter of \'entries\' and \'keys\' specified and both are undef.')
  }

  include ::bind

  file { "${::bind::acls_dir}/${name}":
    ensure  => 'file',
    content => template('bind/acl.erb'),
    owner   => $::bind::user,
    group   => $::bind::group,
    mode    => '0640',
    require => Package['bind'],
  }

  concat_fragment { "bind::acl::${name}":
    target  => $::bind::acls_list,
    content => "include \"${::bind::acls_dir}/${name}\";",
    tag     => 'bind_acl',
  }
}
