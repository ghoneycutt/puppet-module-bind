# == Define: bind::zone
#
# bind::zone is different from the other defines because there are multiple
# collects of zones as opposed to say acls where there is one acl_list. Because
# of this, a virtual resource is used for the concat_fragment. These can be
# collected in a profile, such as below.
#
#   Concat_fragment <| tag == 'internal' |>
#
#   concat_file { '/etc/named/zone_lists/internal.zones':
#     tag            => 'internal',
#     ensure_newline => true,
#     owner          => 'root',
#     group          => $::bind::group,
#     mode           => '0640',
#     require        => Package['bind'],
#     before         => File['named_conf'],
#     notify         => Service['named'],
#   }
#
#   # yaml data
#   'example.com':
#     type: 'slave'
#     masters: 'master-internal'
#     target: '/etc/named/zone_lists/internal.zones'
#     tag: 'internal'
#     extra_path: '/internal'
#
define bind::zone (
  $target,
  $tag        = $name, # tag each zone with its name unless a tag is provided
  $extra_path = undef, # optional extra dir structure - must be absolute, ie '/internal'
  $masters    = undef, # if type is slave, this must be specified, else ignored
  $type       = undef, # master or slave
) {

  include ::bind

  validate_absolute_path($target)

  if $extra_path != undef {
    validate_absolute_path($extra_path)
  }

  validate_re($type, '^(master|slave)$',
    "bind::zone::${name}::type is <${type}> and must be 'master' or 'slave'.")

  if is_string($name) == false {
    fail('bind::zone::name is not a string')
  }

  if is_string($tag) == false {
    fail('bind::zone::tag is not a string')
  }

  if $type == 'slave' and $masters == undef {
    fail("If type is slave, then masters must be specified. Value for type is <${type}> and masters is <${masters}>.")
  }

  if ($masters != undef) and (is_string($masters) == false) {
    fail('bind::zone::masters is not a string')
  }

  $dir = $type ? {
    'slave'  => 'slaves',
    'master' => 'master',
  }

  file { "${::bind::zones_dir}/${name}":
    ensure  => 'file',
    content => template('bind/zone.erb'),
    owner   => $::bind::user,
    group   => $::bind::group,
    mode    => '0640',
    require => Package['bind'],
  }

  @concat_fragment { "bind::zone::${name}":
    target  => $target,
    content => "include \"${::bind::zones_dir}/${name}\";",
    tag     => $tag,
  }
}
