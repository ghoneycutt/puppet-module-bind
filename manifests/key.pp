# == Define: bind::key
#
define bind::key (
  $secret,
  $algorithm = 'hmac-md5',
  $path      = "/etc/named/${name}.key",
) {

  validate_string($secret)
  validate_string($algorithm)
  validate_absolute_path($path)

  include ::bind

  file { "bind::key::${name}":
    ensure  => file,
    path    => $path,
    content => template('bind/key.erb'),
    owner   => 'root',
    group   => $::bind::group,
    mode    => '0640',
    require => Package['bind'],
    notify  => Service['named'],
  }

  concat_fragment { "bind::keys::${name}":
    target  => $::bind::keys_list,
    content => "include \"${path}\";",
    tag     => 'bind_keys',
  }
}
