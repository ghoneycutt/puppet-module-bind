# == Define: bind::channel
#
# Manage files /etc/named/channels.d and corresponding include statements in
# /etc/named.conf
#
define bind::channel (
  $type,
  $file            = undef, # can be a relative path
  $severity        = undef,
  $syslog_facility = undef,
) {

  validate_re($type, '^(file|syslog|stderr|null)$',
    "bind::channel::${name}::type is <${type}>. Valid values are 'file', 'syslog', 'stderr', and 'null'.")

  if ($file != undef) and (is_string($file) == false) {
    fail('bind::channel::file is not a string')
  }

  if is_string($severity) == false {
    fail('bind::channel::severity is not a string')
  }

  if ($syslog_facility != undef) and (is_string($syslog_facility) == false) {
    fail('bind::channel::syslog_facility is not a string')
  }

  if $syslog_facility == undef and $file == undef {
    fail('bind::channel::syslog_facility and bind::channel::file cannot both be undef')
  }

  include ::bind

  file { "${::bind::channels_dir}/${name}":
    ensure  => 'file',
    content => template('bind/channel.erb'),
    owner   => $::bind::user,
    group   => $::bind::group,
    mode    => '0640',
    require => Package['bind'],
  }

  concat_fragment { "bind::channel::${name}":
    target  => $::bind::channels_list,
    content => "include \"${::bind::channels_dir}/${name}\";",
    tag     => 'bind_channel',
  }
}
