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
  $extra_path      = undef, # optional extra dir structure - must be absolute, ie '/internal'
  $masters         = undef, # if type is slave, this must be specified, else ignored
  $type            = undef, # master or slave
  $update_policies = undef, # mutually exclusive with allow_update
  $allow_update    = undef,
  $forwarders      = undef,
) {

  include ::bind

  validate_absolute_path($target)

  if is_string($name) == false {
    fail('bind::zone::name is not a string')
  }

  if $name =~ /:/ {
    $zone = inline_template("<%= @name.split(':')[0] %>")
    $ztag  = inline_template("<%= @name.split(':')[1] %>")
  } else {
    $zone = $name
    $ztag  = $name
  }

  if $extra_path != undef {
    validate_absolute_path($extra_path)
    $zones_dir = "${::bind::zones_dir}${extra_path}"
  } else {
    $zones_dir = $::bind::zones_dir
  }
  $path = "${zones_dir}/${zone}"

  if ! defined(Common::Mkdir_p[$zones_dir]) {
    common::mkdir_p { $zones_dir: }
  }

  validate_re($type, '^(master|slave)$',
    "bind::zone::${zone}::type is <${type}> and must be 'master' or 'slave'.")

  if $type == 'slave' and $masters == undef {
    fail("If type is slave, then masters must be specified. Value for type is <${type}> and masters is <${masters}>.")
  }

  if ($masters != undef) and (is_string($masters) == false) {
    fail('bind::zone::masters is not a string')
  }

  if $update_policies != undef {
    validate_hash($update_policies)
  }

  if $allow_update != undef {
    validate_array($allow_update)
  }

  # Same behavior as allow_update, Array of Strings.
  if $forwarders != undef {
    validate_array($forwarders)
  }

  if $allow_update != undef and $update_policies != undef {
    fail('allow_update and update_policies are mutually exclusive and values for both parameters have been specified.')
  }

  $dir = $type ? {
    'slave'  => 'slaves',
    'master' => 'master',
  }

  file { $path:
    ensure  => 'file',
    content => template('bind/zone.erb'),
    owner   => $::bind::user,
    group   => $::bind::group,
    mode    => '0640',
    before  => File['named_conf'],
    require => [
      Package['bind'],
      Common::Mkdir_p[$zones_dir],
    ],
    notify  => Service['named'],
  }

  @concat_fragment { "bind::zone::${name}":
    target  => $target,
    content => "include \"${path}\";",
    tag     => $ztag,
  }
}
