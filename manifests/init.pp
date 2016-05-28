# == Class: bind
#
class bind (
  $package                                   = 'bind-chroot',
  $package_ensure                            = 'present',
  $config_path                               = '/etc/named.conf',
  $config_dir                                = '/etc/named',
  $rndc_key                                  = '/etc/rndc.key',
  $rndc_key_secret                           = 'U803nlXs4b5x6t7UDw8hnw==',
  $service                                   = 'named',
  $user                                      = 'named',
  $group                                     = 'named',
  $named_checkconf                           = '/usr/sbin/named-checkconf',
  $version                                   = 'not so easy',
  $notify_option                             = 'no',
  $recursion                                 = 'no',
  $zone_statistics                           = 'yes',
  $allow_query                               = 'any',
  $allow_transfer                            = 'none',
  $cleaning_interval                         = 1440,
  $check_names                               = 'ignore',
  $port                                      = 53,
  $listen_from                               = 'any',
  $dnssec_enable                             = 'no',
  $dnssec_validation                         = 'no',
  $directory                                 = '/var/named',
  $dump_file                                 = '/var/named/data/cache_dump.db',
  $statistics_file                           = '/var/named/data/named_stats.txt',
  $memstatistics_file                        = '/var/named/data/named_mem_stats.txt',
  $type                                      = 'slave', # could be master
  $default_logging_channel                   = 'default_syslog', # could also be default_debug, default_stderr, and null
  $use_default_logging_channel               = true,
  $enable_logging_category_default           = false,
  $logging_category_default_channels         = ['default_syslog'],
  $enable_logging_category_general           = false,
  $logging_category_general_channels         = ['default_syslog'],
  $enable_logging_category_config            = false,
  $logging_category_config_channels          = ['default_syslog'],
  $enable_logging_category_client            = false,
  $logging_category_client_channels          = ['default_syslog'],
  $enable_logging_category_database          = false,
  $logging_category_database_channels        = ['default_syslog'],
  $enable_logging_category_network           = false,
  $logging_category_network_channels         = ['default_syslog'],
  $enable_logging_category_queries           = false,
  $logging_category_queries_channels         = ['default_syslog'],
  $enable_logging_category_security          = false,
  $logging_category_security_channels        = ['default_syslog'],
  $enable_logging_category_resolver          = false,
  $logging_category_resolver_channels        = ['default_syslog'],
  $enable_logging_category_update            = false,
  $logging_category_update_channels          = ['default_syslog'],
  $enable_logging_category_update_security   = false,
  $logging_category_update_security_channels = ['default_syslog'],
  $enable_logging_category_xfer_in           = false,
  $logging_category_xfer_in_channels         = ['default_syslog'],
  $enable_logging_category_xfer_out          = false,
  $logging_category_xfer_out_channels        = ['default_syslog'],
  $channels_dir                              = '/etc/named/channels.d',
  $channels_list                             = '/etc/named/channels',
  $channels                                  = undef,
  $channels_hiera_merge                      = true,
  $slave_dir                                 = '/var/named/slaves',
  $acls_dir                                  = '/etc/named/acls.d',
  $acls_list                                 = '/etc/named/acls',
  $acls                                      = undef,
  $acls_hiera_merge                          = true,
  $controls                                  = undef,
  $keys                                      = undef,
  $keys_hiera_merge                          = true,
  $keys_list                                 = '/etc/named/keys',
  $masters_dir                               = '/etc/named/masters.d',
  $masters_list                              = '/etc/named/masters',
  $masters                                   = undef,
  $masters_hiera_merge                       = true,
  $views_dir                                 = '/etc/named/views.d',
  $views_list                                = '/etc/named/views',
  $views                                     = undef,
  $views_hiera_merge                         = true,
  $zones_dir                                 = '/etc/named/zones.d',
  $zones_hiera_merge                         = true,
  $zones                                     = undef,
  $zone_lists_dir                            = '/etc/named/zone_lists',
) {

  validate_string($package)
  validate_string($package_ensure)
  validate_absolute_path($config_path)
  validate_absolute_path($config_dir)
  validate_absolute_path($rndc_key)
  validate_string($rndc_key_secret)
  validate_string($user)
  validate_string($group)
  validate_absolute_path($named_checkconf)
  validate_string($version)
  validate_string($notify_option)
  validate_string($recursion)
  validate_string($zone_statistics)
  validate_string($allow_query)
  validate_string($allow_transfer)
  validate_integer($cleaning_interval)
  validate_re($check_names, '^(fail|ignore|warn)$',
    "bind::check_names is <${check_names}>. Valid values are 'fail', 'ignore' and 'warn'.")

  validate_integer($port)
  validate_string($listen_from)
  validate_string($dnssec_enable)
  validate_string($dnssec_validation)
  validate_absolute_path($directory)
  validate_absolute_path($dump_file)
  validate_absolute_path($statistics_file)
  validate_absolute_path($memstatistics_file)
  validate_re($type, '^(master|slave)$',
    "bind::type is <${type}> and must be 'master' or 'slave'.")

  validate_re($default_logging_channel, '^(default_syslog|default_debug|default_stderr|null)$',
    "bind::default_logging_channel is <${default_logging_channel}> and valid values are 'default_syslog', 'default_debug', 'default_stderr' and 'null'.")

  validate_bool($use_default_logging_channel)

  validate_bool($enable_logging_category_default)
  validate_array($logging_category_default_channels)
  validate_bool($enable_logging_category_general)
  validate_array($logging_category_general_channels)
  validate_bool($enable_logging_category_config)
  validate_array($logging_category_config_channels)
  validate_bool($enable_logging_category_client)
  validate_array($logging_category_client_channels)
  validate_bool($enable_logging_category_database)
  validate_array($logging_category_database_channels)
  validate_bool($enable_logging_category_network)
  validate_array($logging_category_network_channels)
  validate_bool($enable_logging_category_queries)
  validate_array($logging_category_queries_channels)
  validate_bool($enable_logging_category_security)
  validate_array($logging_category_security_channels)
  validate_bool($enable_logging_category_resolver)
  validate_array($logging_category_resolver_channels)
  validate_bool($enable_logging_category_update)
  validate_array($logging_category_update_channels)
  validate_bool($enable_logging_category_update_security)
  validate_array($logging_category_update_security_channels)
  validate_bool($enable_logging_category_xfer_in)
  validate_array($logging_category_xfer_in_channels)
  validate_bool($enable_logging_category_xfer_out)
  validate_array($logging_category_xfer_out_channels)

  validate_absolute_path($channels_dir)
  validate_absolute_path($channels_list)
  validate_absolute_path($acls_dir)
  validate_absolute_path($acls_list)
  validate_absolute_path($keys_list)
  validate_absolute_path($masters_dir)
  validate_absolute_path($masters_list)
  validate_absolute_path($views_dir)
  validate_absolute_path($views_list)
  validate_absolute_path($zones_dir)
  validate_absolute_path($zone_lists_dir)

  if $controls != undef {
    validate_hash($controls)
  }


  if $channels != undef {
    validate_hash($channels)
  }

  if $acls != undef {
    validate_hash($acls)
  }

  if $keys != undef {
    validate_hash($keys)
  }

  if $masters != undef {
    validate_hash($masters)
  }

  if $views != undef {
    validate_hash($views)
  }

  if $zones != undef {
    validate_hash($zones)
  }

  package { 'bind':
    ensure => $package_ensure,
    name   => $package,
  }

  bind::key { 'rndc-key':
    secret => $rndc_key_secret,
    path   => $rndc_key,
  }

  if $use_default_logging_channel == true {
    bind::channel { $default_logging_channel:
      type     => 'file',
      file     => 'data/named.run',
      severity => 'dynamic',
    }
  }

  file { 'named_config_dir':
    ensure  => 'directory',
    path    => $config_dir,
    owner   => 'root',
    group   => $group,
    mode    => '0750',
    require => Package['bind'],
  }

  file { 'named_conf':
    ensure       => 'file',
    path         => $config_path,
    content      => template('bind/named.conf.erb'),
    owner        => 'root',
    group        => $group,
    mode         => '0640',
    validate_cmd => "${named_checkconf} %",
    require      => Package['bind'],
    notify       => Service['named'],
  }

  file { 'named.channels.d':
    ensure  => 'directory',
    path    => $channels_dir,
    purge   => true,
    recurse => true,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    require => Package['bind'],
    notify  => Service['named'],
  }

  file { 'named.acls.d':
    ensure  => 'directory',
    path    => $acls_dir,
    purge   => true,
    recurse => true,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    require => Package['bind'],
    notify  => Service['named'],
  }

  file { 'named.masters.d':
    ensure  => 'directory',
    path    => $masters_dir,
    purge   => true,
    recurse => true,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    require => Package['bind'],
    notify  => Service['named'],
  }

  file { 'named.zones.d':
    ensure  => 'directory',
    path    => $zones_dir,
    purge   => true,
    recurse => true,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    require => Package['bind'],
    notify  => Service['named'],
  }

  file { 'named.views.d':
    ensure  => 'directory',
    path    => $views_dir,
    purge   => true,
    recurse => true,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    require => Package['bind'],
    notify  => Service['named'],
  }

  file { 'named.zone_lists':
    ensure  => 'directory',
    path    => $zone_lists_dir,
    purge   => true,
    recurse => true,
    owner   => $user,
    group   => $group,
    mode    => '0700',
    require => Package['bind'],
    before  => File['named_conf'],
    notify  => Service['named'],
  }

  file { 'root_zone':
    ensure  => 'file',
    path    => "${config_dir}/root.zone",
    content => template('bind/root.zone.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Package['bind'],
    before  => File['named_conf'],
    notify  => Service['named'],
  }

  concat_file { $channels_list:
    tag            => 'bind_channel',
    ensure_newline => true,
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    require        => Package['bind'],
    before         => File['named_conf'],
    notify         => Service['named'],
  }

  concat_file { $acls_list:
    tag            => 'bind_acl',
    ensure_newline => true,
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    require        => Package['bind'],
    before         => File['named_conf'],
    notify         => Service['named'],
  }

  concat_file { $keys_list:
    tag            => 'bind_keys',
    ensure_newline => true,
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    require        => Package['bind'],
    before         => File['named_conf'],
    notify         => Service['named'],
  }

  concat_file { $masters_list:
    tag            => 'bind_masters',
    ensure_newline => true,
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    require        => Package['bind'],
    before         => File['named_conf'],
    notify         => Service['named'],
  }

  concat_file { $views_list:
    tag            => 'bind_view',
    ensure_newline => true,
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    require        => Package['bind'],
    before         => File['named_conf'],
    notify         => Service['named'],
  }

  service { 'named':
    ensure => 'running',
    name   => $service,
    enable => true,
  }

  if is_string($channels_hiera_merge) {
    $channels_hiera_merge_real = str2bool($channels_hiera_merge)
  } else {
    $channels_hiera_merge_real = $channels_hiera_merge
  }
  validate_bool($channels_hiera_merge_real)

  if $channels != undef {
    if $channels_hiera_merge_real == true {
      $channels_real = hiera_hash('bind::channels')
    } else {
      $channels_real = $channels
    }
    validate_hash($channels_real)
    create_resources('bind::channel', $channels_real)
  }

  if is_string($acls_hiera_merge) {
    $acls_hiera_merge_real = str2bool($acls_hiera_merge)
  } else {
    $acls_hiera_merge_real = $acls_hiera_merge
  }
  validate_bool($acls_hiera_merge_real)

  if $acls != undef {
    if $acls_hiera_merge_real == true {
      $acls_real = hiera_hash('bind::acls')
    } else {
      $acls_real = $acls
    }
    validate_hash($acls_real)
    create_resources('bind::acl', $acls_real)
  }

  if is_string($keys_hiera_merge) {
    $keys_hiera_merge_real = str2bool($keys_hiera_merge)
  } else {
    $keys_hiera_merge_real = $keys_hiera_merge
  }
  validate_bool($keys_hiera_merge_real)

  if $keys != undef {
    if $keys_hiera_merge_real == true {
      $keys_real = hiera_hash('bind::keys')
    } else {
      $keys_real = $keys
    }
    validate_hash($keys_real)
    create_resources('bind::key', $keys_real)
  }

  if is_string($masters_hiera_merge) {
    $masters_hiera_merge_real = str2bool($masters_hiera_merge)
  } else {
    $masters_hiera_merge_real = $masters_hiera_merge
  }
  validate_bool($masters_hiera_merge_real)

  if $masters != undef {
    if $masters_hiera_merge_real == true {
      $masters_real = hiera_hash('bind::masters')
    } else {
      $masters_real = $masters
    }
    validate_hash($masters_real)
    create_resources('bind::masters', $masters_real)
  }

  if is_string($views_hiera_merge) {
    $views_hiera_merge_real = str2bool($views_hiera_merge)
  } else {
    $views_hiera_merge_real = $views_hiera_merge
  }
  validate_bool($views_hiera_merge_real)

  if $views != undef {
    if $views_hiera_merge_real == true {
      $views_real = hiera_hash('bind::views')
    } else {
      $views_real = $views
    }
    validate_hash($views_real)
    create_resources('bind::view', $views_real)
  }

  if is_string($zones_hiera_merge) {
    $zones_hiera_merge_real = str2bool($zones_hiera_merge)
  } else {
    $zones_hiera_merge_real = $zones_hiera_merge
  }
  validate_bool($zones_hiera_merge_real)

  if $zones != undef {
    if $zones_hiera_merge_real == true {
      $zones_real = hiera_hash('bind::zones')
    } else {
      $zones_real = $zones
    }
    validate_hash($zones_real)
    create_resources('bind::zone', $zones_real)
  }
}
