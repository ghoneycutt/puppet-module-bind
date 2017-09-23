# puppet-module-bind

#### Table of Contents

1. [Module Description](#module-description)
2. [Compatibility](#compatibility)
3. [Class Descriptions](#class-descriptions)
    * [bind](#class-bind)
4. [Define Descriptions](#define-descriptions)
    * [bind::acl](#defined-type-bindacl)
    * [bind::channel](#defined-type-bindchannel)
    * [bind::key](#defined-type-bindkey)
    * [bind::masters](#defined-type-bindmasters)
    * [bind::view](#defined-type-bindview)
    * [bind::zone](#defined-type-bindzone)

# Module description

Manage ISC Bind 9. This module's approach is to manage the configuration of
bind9 while not managing the data in the actual zones, which is up to you.
Recommend keeping zone data in another repo and having a process sync that data
to your bind masters.

Since the bind configuration language is so rich, the approach taken has
been to turn clauses such as zone and view into defined types and make
heavy use of concat fragments.

# Compatibility

This module is built for use with Puppet v3 (with and without the future
parser) and Puppet v4 on the following platforms and supports Ruby versions
1.8.7, 1.9.3, 2.0.0 and 2.1.9.

 * EL 6

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-bind.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-bind)

# Class Descriptions
## Class `bind`

### Description

The bind class manages the software, its configuration and service. All
defined types can be called directly through the bind class by passing
their options as hashes, which is explained for each type. To use,
simply `include ::bind`.

### Parameters

---
#### package (type: String)
Package to be installed for ISC Bind 9.

- *Default*: 'bind-chroot'

---
#### package_ensure (type: String)
Value of ensure attribute for bind package.

- *Default*: 'present'

---
#### config_path (type: String)
Absolute path to named.conf.

- *Default*: '/etc/named.conf'

---
#### config_dir (type: String)
Absolute path to configuration directory.

- *Default*: '/etc/named'

---
#### rndc_key (type: String)
Absolute path to RNDC key.

- *Default*: '/etc/rndc.key'

---
#### rndc_key_secret (type: String)
Secret for rndc_key.

- *Default*: 'U803nlXs4b5x6t7UDw8hnw

---
#### service (type: String)
Name of bind service.

- *Default*: 'named'

---
#### user (type: String)
Bind user.

- *Default*: 'named'

---
#### group (type: String)
Bind group.

- *Default*: 'named'

---
#### named_checkconf (type: String)
Absolute path to named-checkconf.

- *Default*: '/usr/sbin/named-checkconf'

---
#### version (type: String)
Version to be announced. This is queryable, so recommend not using the actual
version.

- *Default*: 'notsoeasy'

---
#### notify_option (type: String)
Value of `notify` option in named.conf.

- *Default*: 'no'

---
#### recursion (type: String)
Value of `recursion` option in named.conf.

- *Default*: 'no'

---
#### forwarders (type: Array)
Value of `forwarders` option in named.conf.

- *Default*: undef

---
#### zone_statistics (type: String)
Value of `zone-statistics` option in named.conf.

- *Default*: 'yes'

---
#### allow_query (type: String)
Value of `allow-query` option in named.conf.

- *Default*: 'any'

---
#### allow_transfer (type: String)
Value of `allow-transfer` option in named.conf.

- *Default*: 'none'

---
#### cleaning_interval (type: Integer)
Value of `cleaning-interval` option in named.conf.

- *Default*: 1440

---
#### check_names (type: String)
Value used in `check-names` option in named.conf. The template will add the
type (master or slave) based on the `type` parameter. Valid values are 'fail',
'ignore' and 'warn'.

- *Default*: 'ignore'

---
#### port (type: Integer)
Value used in `listen-on` option in named.conf.

- *Default*: 53

---
#### listen_from (type: String)
Value used in `listen-on` option in named.conf.

- *Default*: 'any'

---
#### dnssec_enable (type: String)
Value of `dnssec-enable` option in named.conf.

- *Default*: 'no'

---
#### dnssec_validation (type: String)
Value of `dnssec-validation` option in named.conf.

- *Default*: 'no'

---
#### directory (type: String)
Value of `directory` option in named.conf.

- *Default*: '/var/named'

---
#### dump_file (type: String)
Value of `dump-file` option in named.conf.

- *Default*: '/var/named/data/cache_dump.db'

---
#### statistics_file (type: String)
Value of `statistics-file` option in named.conf.

- *Default*: '/var/named/data/named_stats.txt'

---
#### memstatistics_file (type: String)
Value of `memstatistics-file` option in named.conf.

- *Default*: '/var/named/data/named_mem_stats.txt'

---
#### type (type: String)
Type of bind system. Valid values are 'master' and 'slave'.

- *Default*: 'master'

---
#### default_logging_channel (type: String)
Name of default logging channel to use. Valid values are 'default_syslog',
'default_debug', 'default_stderr' and 'null'.

- *Default*: 'default_syslog'

---
#### use_default_logging_channel (type: Boolean)
Determines if bind::channel should be called for the `default_logging_channel`.

- *Default*: true

---
#### enable_logging_category_default (type: Boolean)
Determine if the logging category `default` should be enabled.

- *Default*: false

---
#### logging_category_default_channels (type: Array)
List of channels for logging category `default`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_general (type: Boolean)
Determine if the logging category `general` should be enabled.

- *Default*: false

---
#### logging_category_general_channels (type: Array)
List of channels for logging category `general`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_config (type: Boolean)
Determine if the logging category `config` should be enabled.

- *Default*: false

---
#### logging_category_config_channels (type: Array)
List of channels for logging category `config`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_client (type: Boolean)
Determine if the logging category `client` should be enabled.

- *Default*: false

---
#### logging_category_client_channels (type: Array)
List of channels for logging category `client`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_database (type: Boolean)
Determine if the logging category `database` should be enabled.

- *Default*: false

---
#### logging_category_database_channels (type: Array)
List of channels for logging category `database`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_network (type: Boolean)
Determine if the logging category `network` should be enabled.

- *Default*: false

---
#### logging_category_network_channels (type: Array)
List of channels for logging category `network`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_notify (type: Boolean)
Determine if the logging category `notify` should be enabled.

- *Default*: false

---
#### logging_category_notify_channels (type: Array)
List of channels for logging category `notify`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_queries (type: Boolean)
Determine if the logging category `queries` should be enabled.

- *Default*: false

---
#### logging_category_queries_channels (type: Array)
List of channels for logging category `queries`.

- *Default*: ['default_syslog']

---
####enable_logging_category_security (type: Boolean)
Determine if the logging category `security` should be enabled.

- *Default*: false

---
#### logging_category_security_channels (type: Array)
List of channels for logging category `security`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_resolver (type: Boolean)
Determine if the logging category `resolver` should be enabled.

- *Default*: false

---
#### logging_category_resolver_channels (type: Array)
List of channels for logging category `resolver`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_update (type: Boolean)
Determine if the logging category `update` should be enabled.

- *Default*: false

---
#### logging_category_update_channels (type: Array)
List of channels for logging category `update`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_update_security (type: Boolean)
Determine if the logging category `update-security` should be enabled.

- *Default*: false

---
#### logging_category_update_security_channels (type: Array)
List of channels for logging category `update-security`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_xfer_in (type: Boolean)
Determine if the logging category `xfer-in` should be enabled.

- *Default*: false

---
#### logging_category_xfer_in_channels (type: Array)
List of channels for logging category `xfer-in`.

- *Default*: ['default_syslog']

---
#### enable_logging_category_xfer_out (type: Boolean)
Determine if the logging category `xfer-out` should be enabled.

- *Default*: false

---
#### logging_category_xfer_out_channels (type: Array)
List of channels for logging category `xfer-out`.

- *Default*: ['default_syslog']

---
#### channels_dir (type: String)
Absolute path to directory which will contain the channel snippets.

- *Default*: '/etc/named/channels.d'

---
#### channels_list (type: String)
Absolute path to file which will contain the list of channel snippets.

- *Default*: '/etc/named/channels'

---
#### channels (type: Hash or undef)
Hash of bind::channel resources.

- *Default*: undef

---
#### channels_hiera_merge (type: Boolean)
Determine if the `channels` parameter should be populated using Hiera's merge
lookup.

- *Default*: true

---
#### acls_dir (type: String)
Absolute path to directory which will contain the acl snippets.

- *Default*: '/etc/named/acls.d'

---
#### acls_list (type: String)
Absolute path to file which will contain the list of acl snippets.

- *Default*: '/etc/named/acls'

---
#### acls (type: Hash or undef)
Hash of `bind::acl` resources.

- *Default*: undef

---
#### acls_hiera_merge (type: Boolean)
Determine if the `acls` parameter should be populated using Hiera's merge
lookup.

- *Default*: true

---
#### controls (type: Hash or undef)
Specifies information for controls lines in the named.conf. The key is the IP
address or `'*'`. The hash has subkeys that must include 'port' (string),
'allows' (array) and optionally 'keys' (array).

- *Default*: undef

##### Example:
```yaml
bind::controls:
  '*':
    port: '953'
    allows:
      - '127.0.0.1'
    keys:
      - 'rndc-key'
```
---
#### keys (type: Hash or undef)
Hash of `bind::key` resources.

- *Default*: undef

---
#### keys_hiera_merge (type: Boolean)
Determine if the `keys` parameter should be populated using Hiera's merge
lookup.

- *Default*: true

---
#### keys_list (type: String)
Absolute path to file which will contain the list of key snippets.

- *Default*: '/etc/named/keys'

---
#### masters_dir (type: String)
Absolute path to directory which will contain the master snippets.

- *Default*: '/etc/named/masters.d'

---
#### masters_list (type: String)
Absolute path to file which will contain the list of master snippets.

- *Default*: '/etc/named/masters'

---
#### masters (type: Hash or undef)
Hash of `bind::master` resources.

- *Default*: undef

---
#### masters_hiera_merge (type: Boolean)
Determine if the `masters` parameter should be populated using Hiera's merge
lookup.

- *Default*: true

---
#### views_dir (type: String)
Absolute path to directory which will contain the view snippets.

- *Default*: '/etc/named/views.d'

---
#### views_list (type: String)
Absolute path to file which will contain the list of view snippets.

- *Default*: '/etc/named/views'

---
#### views (type: Hash or undef)
Hash of `bind::view` resources.

- *Default*: undef

---
#### views_hiera_merge (type: Boolean)
Determine if the `views` parameter should be populated using Hiera's merge
lookup.

- *Default*: true

---
#### zones_dir (type: String)
Absolute path to directory which will contain the zone snippets.

- *Default*: '/etc/named/zones.d'

---
#### zones_hiera_merge (type: Boolean)
Determine if the `zones` parameter should be populated using Hiera's merge
lookup.

- *Default*: true

---
#### zones (type: Hash or undef)
Hash of `bind::zone` resources.

- *Default*: undef

---
#### zone_lists_dir (type: String)
Absolute path to directory which will contain the zone lists.

- *Default*: '/etc/named/zone_lists'

---
#### sysconfig_options (type: String)
Options string to be used in OPTIONS line of sysconfig file at
`/etc/sysconfig/named`.

- *Default*: undef

---

# Define Descriptions
## Defined type `bind::acl`

### Description

Manage acl declarations.

Must specify at least one of `entries` and `keys`.

### Parameters

---
#### name (type: String)
Unique name of the `acl` declaration.

---
#### entries (type: Array or undef)
List of entries for an `acl` declaration.

- *Default*: undef

---
#### keys (type: Array or undef)
List of keys for an `acl` declaration.

- *Default*: undef

---

## Defined type `bind::channel`

### Description

Manage a channel declaration. The types are fundamentally those of files or
syslog, so one of `syslog_facility` and `file` must be populated.

##### Example:
```yaml
bind::channels:
  'my_syslog':
    type: 'syslog'
    syslog_facility: 'daemon'
    severity: 'info'
```
---

### Parameters

---
#### name (type: String)
Name of logging channel.

---
#### type (type: String)
Type of logging channel. Valid values are 'file', 'syslog', 'stderr' and 'null'.

- *Required*

---
#### file (type: String)
Value of `file` option for channel. May be a relative path.

- *Default*: undef

---
#### severity (type: String)
Value of `severity` option for channel.

- *Default*: undef

---
#### syslog_facility (type: String)
Value of `syslog` option for channel.

- *Default*: undef

## Defined type `bind::key`

### Description

Manage a key declaration.

##### Example:
```yaml
bind::keys:
  'key-external-transfer':
    secret: 'generated_secret'
  'key-internal-transfer':
    secret: 'generated_secret'
```
---

### Parameters

---
#### name (type: String)
Name of key.

---
#### secret (type: String)
Value of `secret` option for key.

- *Required*

---
#### algorithm (type: String)
Value of `algorithm` option for key.

- *Default*: 'hmac-md5'

---
#### path (type: Integer)
Absolute path to file containing the key declaration.

- *Default*: "/etc/named/${name}.key"

## Defined type `bind::masters`

### Description

Manage a masters declaration.

##### Example:
```yaml
bind::masters:
  'masters-external':
    entries:
      '10.1.2.3': 'key-external'
  'masters-internal':
    entries:
      '10.3.2.1': 'key-internal'
      '10.3.2.2': 'key-internal'
```
---

### Parameters

---
#### name (type: String)
Name of masters declaration.

---
#### entries (type: Hash )
Hash of entries for masters declaration. The key is the IP address and the
value is the name of a key.

- *Required*

## Defined type `bind::view`

### Description

Manage a bind view clause.

### Example
```yaml
bind::views:
  'corp-internal':
    order: 10
    match_clients:
      - 'corporate'
      - 'key key-test'
    recursion: 'yes'
    includes:
      - '/etc/named.rfc1912.zones'
      - '/etc/named/zone_lists/internal.zones'
      - '/etc/named/zone_lists/corp_internal.zones'
    allow_update: 'internal-updates'
    allow_update_forwarding: 'internal-updates'
    allow_transfer: 'internal-transfer'
```

### Parameters

---
#### match_clients (type: String or Array)
- *Default*: 'any'

---
#### recursion (type: String)
Valid values are 'yes' and 'no'.

- *Default*: undef

---
#### includes (type: Array)
- *Default*: undef

---
#### allow_update (type: String)
- *Default*: undef

---
#### allow_update_forwarding (type: String)
- *Default*: undef

---
#### allow_transfer (type: String)
- *Default*: undef

---
#### order (type: Integer)

- *Default*: undef

---

## Defined type `bind::zone`

### Description

Manage a bind zone clause.

To allow for the same domain to be specified multiple times though with
different views, the `$title` may contain the view. This is done in the
form of `domain:tag`, by specifying the domain, a colon, then the name
of the tag. If no tag is specified, the tag will be set to the domain.
This allows you to collect these tags such as in a profile.

##### Example profile manifest
```puppet

include ::bind

Concat_fragment <| tag == 'internal' |>

concat_file { '/etc/named/zone_lists/internal.zones':
  tag            => 'internal',
  ensure_newline => true,
  owner          => 'root',
  group          => $::bind::group,
  mode           => '0640',
  require        => Package['bind'],
  before         => File['named_conf'],
  notify         => Service['named'],
}
```

##### Example without view
```yaml
bind::zones:
  'foo.example.com':
    type: 'master'
    target: '/etc/named/zone_lists/internal.zones'
    extra_path: '/internal'
```

##### Example with view set to 'internal'
```yaml
bind::zones:
  'foo.example.com:internal':
    type: 'master'
    target: '/etc/named/zone_lists/internal.zones'
    extra_path: '/internal'
```


##### Example:
```yaml
bind::zones:
  'foo.example.com:internal':
    type: 'master'
    target: '/etc/named/zone_lists/internal.zones'
    extra_path: '/internal'
    update_policies:
      'bar.example.net':
        matchtype: 'subdomain'
        key: 'key-internal'
      'x.example.org':
        matchtype: 'name'
        key: 'key-update-policy-x-example-org'
        rrs:
          - 'CNAME'
  'bar.example.com:internal':
    type: 'master'
    target: '/etc/named/zone_lists/internal.zones'
    extra_path: '/internal'
    allow_update:
      - '10.1.1.0/24'
      - '10.1.2.3'
      - 'key name-of-key'
  'bar.example.com:external':
    type: 'master'
    target: '/etc/named/zone_lists/external.zones'
    extra_path: '/external'
    allow_updates:
      - '10.1.1.0/24'
      - '10.1.2.3'
      - 'key name-of-key'
    forwarders:
      - '10.1.1.0/24'
      - '10.1.2.3'
      - 'key name-of-key'
```
---

### Parameters

---
#### target (type: String)
Absolute path to zone list file which is the target of concat_fragment.

- *Required*

---
#### extra_path (type: String)
Optional extra path to be appended to `$bind::zones_dir`. Must be an absolute
path.

- *Default*: undef

---
#### masters (type: String)
Value of `masters` config option in a zone declaration. If `type` is 'slave',
this is required, else it is not used.

- *Default*: undef

---
#### type (type: String)
Value of `type` config option in a zone declaration. Valid values are 'master'
and 'slave'.

- *Default*: undef

---
#### update_policies (type: Hash)
Values for entire update-policy declaration within the zone declaration. The
key is the target of the `grant` config option. Value 'key' is the key to be
used for the grant and is required. Value 'matchtype' maps to the matchtype and
is required. Value 'rrs' maps to an array of resource records and is optional.

- *Default*: undef

---
#### allow_updates (type: Array)
Values for allow-update declaration within the zone declaration. This is
mutually exclusive with update_policies.

---
#### forwarders (type: Array)
Values for forwarders declaration within the zone declaration.
