# == Define: bind::view
#
# Manage files /etc/named/views.d and corresponding include statements in
# /etc/named.conf
#
define bind::view (
  $match_clients           = 'any',
  $recursion               = undef,
  $includes                = undef,
  $allow_update            = undef,
  $allow_update_forwarding = undef,
  $allow_transfer          = undef,
) {

  validate_string($match_clients)

  if $recursion != undef {
    validate_re($recursion, '^(yes|no)$',
      "bind::view::${name}::recursion is <${recursion}> and must be either 'yes' or 'no'.")
  }

  if $includes != undef {
    validate_array($includes)
  }

  if $allow_update != undef {
    validate_string($allow_update)
  }

  if $allow_update_forwarding != undef {
    validate_string($allow_update_forwarding)
  }

  if $allow_transfer != undef {
    validate_string($allow_transfer)
  }

  include ::bind

  file { "${::bind::views_dir}/${name}":
    ensure  => 'file',
    content => template('bind/view.erb'),
    owner   => $::bind::user,
    group   => $::bind::group,
    mode    => '0640',
    require => Package['bind'],
  }

  concat_fragment { "bind::view::${name}":
    target  => $::bind::views_list,
    content => "include \"${::bind::views_dir}/${name}\";",
    tag     => 'bind_view',
  }
}
