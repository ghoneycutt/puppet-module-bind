### v2.3.0 - 2017-11-22
  * Allow for empty forwarders in named.conf and zones.
  * Support Puppet v5.

### v2.2.0 - 2017-09-26
  * Add ability to specify forwarders config option for each zone

### v2.1.0 - 2017-08-27
  * Manage /etc/sysconfig/named

### v2.0.0 - 2017-06-28
  * bind::zone now take a tuple of the zone and the view as the title.

### v1.1.0 - 2017-05-09
  * Add bind::zone::allow_update parameter to support allow-update in
    zone declarations

### v1.0.0 - 2016-10-03
  * Initial release
