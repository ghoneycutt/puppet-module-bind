# == Define: bind::acl
#
# Manage files /etc/named/acl.d and corresponding include statements in
# /etc/named.conf
#
define bind::acl (
  $entries     = undef,
  $not_entries = undef, # entries that are negated with '!'
  $keys        = undef,
) {

  if $entries != undef {
    validate_array($entries)
  }
  if $not_entries != undef {
    validate_array($not_entries)
  }
  if $keys != undef {
    validate_array($keys)
  }

  if $entries == undef and $not_entries == undef and $keys == undef{
    fail('There must be at least one parameter of \'entries\', \'not_entries\' and \'keys\' specified and all are undef.')
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
