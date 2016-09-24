require 'spec_helper'
describe 'bind' do
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  concats = {
    '/etc/named/channels' => { :tag => 'bind_channel', },
    '/etc/named/acls'     => { :tag => 'bind_acl', },
    '/etc/named/keys'     => { :tag => 'bind_keys', },
    '/etc/named/masters'  => { :tag => 'bind_masters', },
    '/etc/named/views'    => { :tag => 'bind_view', },
  }

  directories = {
    'named.channels.d' => { :path => '/etc/named/channels.d', },
    'named.acls.d'     => { :path => '/etc/named/acls.d', },
    'named.masters.d'  => { :path => '/etc/named/masters.d', },
    'named.zones.d'    => { :path => '/etc/named/zones.d', },
    'named.views.d'    => { :path => '/etc/named/views.d', },
    'named.zone_lists' => { :path => '/etc/named/zone_lists', },
  }

  context 'with defaults for all parameters' do
    it { should contain_class('bind') }

    it do
      should contain_package('bind').with({
        'ensure' => 'present',
        'name'   => 'bind-chroot',
      })
    end

    it do
      should contain_bind__key('rndc-key').with({
        'secret' => 'U803nlXs4b5x6t7UDw8hnw==',
        'path'   => '/etc/rndc.key',
      })
    end

    it do
      should contain_bind__channel('default_syslog').with({
        'type'     => 'file',
        'file'     => 'data/named.run',
        'severity' => 'dynamic',
      })
    end

    it do
      should contain_file('named_config_dir').with({
        'ensure'  => 'directory',
        'path'    => '/etc/named',
        'owner'   => 'root',
        'group'   => 'named',
        'mode'    => '0750',
        'require' => 'Package[bind]',
      })
    end

    named_conf_content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |options {
      |  version "not so easy";
      |  notify no;
      |  recursion no;
      |  zone-statistics yes;
      |  allow-query { any; };
      |  allow-transfer { none; };
      |  cleaning-interval 1440;
      |  check-names master ignore;
      |  listen-on port 53 { any; };
      |  dnssec-enable no;
      |  dnssec-validation no;
      |  directory "/var/named";
      |  dump-file "/var/named/data/cache_dump.db";
      |  statistics-file "/var/named/data/named_stats.txt";
      |  memstatistics-file "/var/named/data/named_mem_stats.txt";
      |};
      |
      |include "/etc/named/acls";
      |
      |include "/etc/named/masters";
      |
      |include "/etc/named/keys";
      |
      |
      |include "/etc/named/views";
      |
      |logging {
      |
      |  include "/etc/named/channels";
      |
      |};
    END

    it do
      should contain_file('named_conf').with({
        'ensure'       => 'file',
        'path'         => '/etc/named.conf',
        'content'      => named_conf_content,
        'owner'        => 'root',
        'group'        => 'named',
        'mode'         => '0640',
        'validate_cmd' => '/usr/sbin/named-checkconf %',
        'require'      => 'Package[bind]',
        'notify'       => 'Service[named]',
      })
    end

    directories.each do |directory, v|
      it do
        should contain_file(directory).with({
          'ensure'       => 'directory',
          'path'         => v[:path],
          'purge'        => true,
          'recurse'      => true,
          'owner'        => 'named',
          'group'        => 'named',
          'mode'         => '0700',
          'require'      => 'Package[bind]',
          'notify'       => 'Service[named]',
        })
      end
    end

    # deviations for files in named_directories{} list
    it { should contain_file('named.zone_lists').with_before('File[named_conf]') }

    root_zone_content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |zone "." {
      |  type hint;
      |  file "named.ca";
      |};
    END

    it do
      should contain_file('root_zone').with({
        'ensure'       => 'file',
        'path'         => '/etc/named/root.zone',
        'content'      => root_zone_content,
        'owner'        => 'named',
        'group'        => 'named',
        'mode'         => '0644',
        'require'      => 'Package[bind]',
        'before'       => 'File[named_conf]',
        'notify'       => 'Service[named]',
      })
    end

    concats.each do |concat, v|
      it do
        should contain_concat_file(concat).with({
          'tag'            => v[:tag],
          'ensure_newline' => true,
          'owner'          => 'root',
          'group'          => 'named',
          'mode'           => '0640',
          'require'        => 'Package[bind]',
          'before'         => 'File[named_conf]',
          'notify'         => 'Service[named]',
        })
      end
    end

    it do
      should contain_service('named').with({
        'ensure' => 'running',
        'name'   => 'named',
        'enable' => true,
      })
    end


    # one resourcec for use_default_logging_channel defaulting to true
    it { should contain_bind__channel('default_syslog') }
    it { should have_bind__channel_resource_count(1) }
    it { should have_bind__acl_resource_count(0) }
    # one resource for calling bind::key in the code
    it { should contain_bind__key('rndc-key') }
    it { should have_bind__key_resource_count(1) }
    it { should have_bind__masters_resource_count(0) }
    it { should have_bind__view_resource_count(0) }
    it { should have_bind__zone_resource_count(0) }
  end

  context 'with package set to valid string <rspec>' do
    let(:params) { { :package => 'rspec' } }

    it { should contain_package('bind').with_name('rspec') }
  end

  context 'with package_ensure set to valid string <installed>' do
    let(:params) { { :package_ensure => 'installed' } }

    it { should contain_package('bind').with_ensure('installed') }
  end

  context 'with config_path set to valid string </specific/path>' do
    let(:params) { { :config_path => '/specific/path' } }

    it { should contain_file('named_conf').with_path('/specific/path') }
  end

  context 'with config_dir set to valid string </specific/dir>' do
    let(:params) { { :config_dir => '/specific/dir' } }

    it { should contain_file('named_config_dir').with_path('/specific/dir') }
    it { should contain_file('root_zone').with_path('/specific/dir/root.zone') }
  end

  context 'with rndc_key set to valid string </specific/otherrndc.key>' do
    let(:params) { { :rndc_key => '/specific/otherrndc.key' } }

    it { should contain_bind__key('rndc-key').with_path('/specific/otherrndc.key') }
  end

  context 'with rndc_key_secret set to valid string <s3cr3t>' do
    let(:params) { { :rndc_key_secret => 's3cr3t' } }

    it { should contain_bind__key('rndc-key').with_secret('s3cr3t') }
  end

  context 'with service set to valid string <nonamed>' do
    let(:params) { { :service => 'nonamed' } }

    it { should contain_service('named').with_name('nonamed') }
  end

  context 'with user set to valid string <username>' do
    let(:params) { { :user => 'username' } }

    directories.each do |directory, _|
      it { should contain_file(directory).with_owner('username') }
    end

    it { should contain_file('root_zone').with_owner('username') }
  end

  context 'with group set to valid string <groupname>' do
    let(:params) { { :group => 'groupname' } }

    it { should contain_file('named_config_dir').with_group('groupname') }
    it { should contain_file('named_conf').with_group('groupname') }

    directories.each do |directory, _|
      it { should contain_file(directory).with_group('groupname') }
    end

    it { should contain_file('root_zone').with_group('groupname') }

    concats.each do |concat, _|
      it { should contain_concat_file(concat).with_group('groupname') }
    end
  end

  context 'with named_checkconf set to valid string </other/check>' do
    let(:params) { { :named_checkconf => '/other/check' } }

    it { should contain_file('named_conf').with_validate_cmd('/other/check %') }
  end

  context 'with version set to valid string <2.42>' do
    let(:params) { { :version => '2.42' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*version "2.42";(\n.*)*\};/) }
  end

  context 'with notify_option set to valid string <yes>' do
    let(:params) { { :notify_option => 'yes' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*notify yes;(\n.*)*\};/) }
  end

  context 'with recursion set to valid string <yes>' do
    let(:params) { { :recursion => 'yes' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*recursion yes;(\n.*)*\};/) }
  end

  context 'with forwarders set to valid array [10.0.0.242]' do
    let(:params) { { :forwarders => %w(10.0.0.242) } }

    it { should contain_file('named_conf').with_content(/^  forwarders { 10.0.0.242; };/) }
  end

  context 'with forwarders set to valid array [10.0.0.3 10.0.0.242]' do
    let(:params) { { :forwarders => %w(10.0.0.3 10.0.0.242) } }

    it { should contain_file('named_conf').with_content(/^  forwarders { 10.0.0.3; 10.0.0.242; };/) }
  end

  context 'with zone_statistics set to valid string <no>' do
    let(:params) { { :zone_statistics => 'no' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*zone-statistics no;(\n.*)*\};/) }
  end

  context 'with allow_query set to valid string <none>' do
    let(:params) { { :allow_query => 'none' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*allow-query \{ none; \};(\n.*)*\};/) }
  end

  context 'with allow_transfer set to valid string <any>' do
    let(:params) { { :allow_transfer => 'any' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*allow-transfer \{ any; \};(\n.*)*\};/) }
  end

  context 'with cleaning_interval set to valid integer <242>' do
    let(:params) { { :cleaning_interval => 242 } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*cleaning-interval 242;(\n.*)*\};/) }
  end

  context 'with check_names set to valid string <fail>' do
    let(:params) { { :check_names => 'fail' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*check-names master fail;(\n.*)*\};/) }
  end

  context 'with port set to valid integer <242>' do
    let(:params) { { :port => 242 } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*listen-on port 242 \{ any; \};(\n.*)*\};/) }
  end

  context 'with listen_from set to valid string <none>' do
    let(:params) { { :listen_from => 'none' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*listen-on port 53 \{ none; \};(\n.*)*\};/) }
  end

  context 'with dnssec_enable set to valid string <yes>' do
    let(:params) { { :dnssec_enable => 'yes' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*dnssec-enable yes;(\n.*)*\};/) }
  end

  context 'with dnssec_validation set to valid string <yes>' do
    let(:params) { { :dnssec_validation => 'yes' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*dnssec-validation yes;(\n.*)*\};/) }
  end

  context 'with directory set to valid string </other/dir>' do
    let(:params) { { :directory => '/other/dir' } }

    it { should contain_file('named_conf').with_content(%r{^options \{(\n.*)*^\s*directory "/other/dir";(\n.*)*\};}) }
  end

  context 'with dump_file set to valid string </other/dump>' do
    let(:params) { { :dump_file => '/other/dump' } }

    it { should contain_file('named_conf').with_content(%r{^options \{(\n.*)*^\s*dump-file "/other/dump";(\n.*)*\};}) }
  end

  context 'with statistics_file set to valid string </other/stats>' do
    let(:params) { { :statistics_file => '/other/stats' } }

    it { should contain_file('named_conf').with_content(%r{^options \{(\n.*)*^\s*statistics-file "/other/stats";(\n.*)*\};}) }
  end

  context 'with memstatistics_file set to valid string </other/memstats>' do
    let(:params) { { :memstatistics_file => '/other/memstats' } }

    it { should contain_file('named_conf').with_content(%r{^options \{(\n.*)*^\s*memstatistics-file "/other/memstats";(\n.*)*\};}) }
  end

  context 'with type set to valid string <slave>' do
    let(:params) { { :type => 'slave' } }

    it { should contain_file('named_conf').with_content(/^options \{(\n.*)*^\s*check-names slave ignore;(\n.*)*\};/) }
  end

  context 'with default_logging_channel set to valid string <default_debug>' do
    let(:params) { { :default_logging_channel => 'default_debug' } }

    it { should contain_bind__channel('default_debug') }
  end

  context 'with use_default_logging_channel set to valid bool <false>' do
    let(:params) { { :use_default_logging_channel => false } }

    it { should have_bind__channel_resource_count(0) }
  end

  channels = {
    'default'         => { :category => 'default', },
    'general'         => { :category => 'general', },
    'config'          => { :category => 'config', },
    'client'          => { :category => 'client', },
    'database'        => { :category => 'database', },
    'network'         => { :category => 'network', },
    'notify'          => { :category => 'notify', },
    'queries'         => { :category => 'queries', },
    'security'        => { :category => 'security', },
    'resolver'        => { :category => 'resolver', },
    'update'          => { :category => 'update', },
    'update_security' => { :category => 'update-security', },
    'xfer_in'         => { :category => 'xfer-in', },
    'xfer_out'        => { :category => 'xfer-out', },
  }

  channels.each do |channel, v|
    context "with enable_logging_category_#{channel} set to valid bool <true>" do
      let(:params) { { :"enable_logging_category_#{channel}" => true } }

      it { should contain_file('named_conf').with_content(/^logging \{(\n.*)*^\s*category #{v[:category]} \{ default_syslog; \};(\n.*)*\};/) }
    end

    context "with logging_category_#{channel}_channels set to valid array [default_debug, default_stderr]" do
      let(:params) do
        {
          :"logging_category_#{channel}_channels" => %w(default_debug default_stderr),
          :"enable_logging_category_#{channel}"   => true, # to activate functionality
        }
      end

      it { should contain_file('named_conf').with_content(/^logging \{(\n.*)*^\s*category #{v[:category]} \{ default_debug; default_stderr; \};(\n.*)*\};/) }
    end
  end

  context 'with dump_file set to valid string </other/dump>' do
    let(:params) { { :dump_file => '/other/dump' } }

    it { should contain_file('named_conf').with_content(%r{^options \{(\n.*)*^\s*dump-file "/other/dump";(\n.*)*\};}) }
  end

  context 'with channels_dir set to valid string </other/path>' do
    let(:params) { { :channels_dir => '/other/path' } }

    it { should contain_file('named.channels.d').with_path('/other/path') }
  end

  context 'with channels_list set to valid string </other/path>' do
    let(:params) { { :channels_list => '/other/path' } }

    it { should contain_concat_file('/other/path') }
  end

  context 'with channels set to valid hash' do
    let(:facts) do
      {
        :fqdn      => 'hiera-merge.example.local',
        :parameter => 'hiera-mergers',
      }
    end

    context 'when channels_hiera_merge is <true> (default value)' do
      let(:params) do
        {
          :channels => {
            'fromparams' => {
              'type' => 'file',
              'file' => 'satisfy bind::channel',
            },
          },
          :channels_hiera_merge => true,
        }
      end

      it { should_not contain_bind__channel('fromparams') }
      it { should contain_bind__channel('from_hiera_parameter') }
      it { should contain_bind__channel('from_hiera_fqdn') }
    end

    context 'when channels_hiera_merge is <false>' do
      let(:params) do
        {
          :channels => {
            'fromparams' => {
              'type' => 'file',
              'file' => 'satisfy bind::channel',
            },
          },
          :channels_hiera_merge => false,
        }
      end

      it { should contain_bind__channel('fromparams') }
      it { should_not contain_bind__channel('from_hiera_parameter') }
      it { should_not contain_bind__channel('from_hiera_fqdn') }
    end
  end

  context 'with acls_dir set to valid string </other/path>' do
    let(:params) { { :acls_dir => '/other/path' } }

    it { should contain_file('named.acls.d').with_path('/other/path') }
  end

  context 'with acls_list set to valid string </other/path>' do
    let(:params) { { :acls_list => '/other/path' } }

    it { should contain_concat_file('/other/path') }
  end

  context 'with acls set to valid hash' do
    let(:facts) do
      {
        :fqdn      => 'hiera-merge.example.local',
        :parameter => 'hiera-mergers',
      }
    end

    context 'when acls_hiera_merge is <true> (default value)' do
      let(:params) do
        {
          :acls => {
            'fromparams' => {
              'keys' => ['satisfy bind::acl'],
            },
          },
          :acls_hiera_merge => true,
        }
      end

      it { should_not contain_bind__acl('fromparams') }
      it { should contain_bind__acl('from_hiera_parameter') }
      it { should contain_bind__acl('from_hiera_fqdn') }
    end

    context 'when acls_hiera_merge is <false>' do
      let(:params) do
        {
          :acls => {
            'fromparams' => {
              'keys' => ['satisfy bind::acl'],
            },
          },
          :acls_hiera_merge => false,
        }
      end

      it { should contain_bind__acl('fromparams') }
      it { should_not contain_bind__acl('from_hiera_parameter') }
      it { should_not contain_bind__acl('from_hiera_fqdn') }
    end
  end

  context 'with controls set to valid hash </other/path>' do
    let(:params) do
      {
        :controls => {
          '*' => {
            'port'   => '953',
            'allows' => %w(127.0.0.1 127.0.0.2),
            'keys'   => %w(key1 key2),
          }
        }
      }
    end

    controls_content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |options {
      |  version "not so easy";
      |  notify no;
      |  recursion no;
      |  zone-statistics yes;
      |  allow-query { any; };
      |  allow-transfer { none; };
      |  cleaning-interval 1440;
      |  check-names master ignore;
      |  listen-on port 53 { any; };
      |  dnssec-enable no;
      |  dnssec-validation no;
      |  directory "/var/named";
      |  dump-file "/var/named/data/cache_dump.db";
      |  statistics-file "/var/named/data/named_stats.txt";
      |  memstatistics-file "/var/named/data/named_mem_stats.txt";
      |};
      |
      |include "/etc/named/acls";
      |
      |include "/etc/named/masters";
      |
      |include "/etc/named/keys";
      |
      |controls {
      |  inet * port 953 allow { 127.0.0.1; 127.0.0.2; } keys { "key1"; "key2"; };
      |};
      |
      |include "/etc/named/views";
      |
      |logging {
      |
      |  include "/etc/named/channels";
      |
      |};
    END

    it { should contain_file('named_conf').with_content(controls_content) }
  end

  context 'with keys set to valid hash' do
    let(:facts) do
      {
        :fqdn      => 'hiera-merge.example.local',
        :parameter => 'hiera-mergers',
      }
    end

    context 'when keys_hiera_merge is <true> (default value)' do
      let(:params) do
        {
          :keys => {
            'fromparams' => {
              'secret'   => 'satisfy bind::key',
            },
          },
          :keys_hiera_merge => true,
        }
      end

      it { should_not contain_bind__key('fromparams') }
      it { should contain_bind__key('from_hiera_parameter') }
      it { should contain_bind__key('from_hiera_fqdn') }
    end

    context 'when keys_hiera_merge is <false>' do
      let(:params) do
        {
          :keys => {
            'fromparams' => {
              'secret'   => 'satisfy bind::key',
            },
          },
          :keys_hiera_merge => false,
        }
      end

      it { should contain_bind__key('fromparams') }
      it { should_not contain_bind__key('from_hiera_parameter') }
      it { should_not contain_bind__key('from_hiera_fqdn') }
    end
  end

  context 'with keys_list set to valid string </other/path>' do
    let(:params) { { :keys_list => '/other/path' } }

    it { should contain_concat_file('/other/path') }
  end

  context 'with masters_dir set to valid string </other/path>' do
    let(:params) { { :masters_dir => '/other/path' } }

    it { should contain_file('named.masters.d').with_path('/other/path') }
  end

  context 'with masters_list set to valid string </other/path>' do
    let(:params) { { :masters_list => '/other/path' } }

    it { should contain_concat_file('/other/path') }
  end

  context 'with masters set to valid hash' do
    let(:facts) do
      {
        :fqdn      => 'hiera-merge.example.local',
        :parameter => 'hiera-mergers',
      }
    end

    context 'when masters_hiera_merge is <true> (default value)' do
      let(:params) do
        {
          :masters => {
            'fromparams' => {
              'entries' => {
                'satisfy' => 'bind::master',
              },
            },
          },
          :masters_hiera_merge => true,
        }
      end

      it { should_not contain_bind__masters('fromparams') }
      it { should contain_bind__masters('from_hiera_parameter') }
      it { should contain_bind__masters('from_hiera_fqdn') }
    end

    context 'when masters_hiera_merge is <false>' do
      let(:params) do
        {
          :masters => {
            'fromparams' => {
              'entries' => {
                'satisfy' => 'bind::master',
              },
            },
          },
          :masters_hiera_merge => false,
        }
      end

      it { should contain_bind__masters('fromparams') }
      it { should_not contain_bind__masters('from_hiera_parameter') }
      it { should_not contain_bind__masters('from_hiera_fqdn') }
    end
  end

  context 'with views_dir set to valid string </other/path>' do
    let(:params) { { :views_dir => '/other/path' } }

    it { should contain_file('named.views.d').with_path('/other/path') }
  end

  context 'with views_list set to valid string </other/path>' do
    let(:params) { { :views_list => '/other/path' } }

    it { should contain_concat_file('/other/path') }
  end

  context 'with views set to valid hash' do
    let(:facts) do
      {
        :fqdn      => 'hiera-merge.example.local',
        :parameter => 'hiera-mergers',
      }
    end

    context 'when views_hiera_merge is <true> (default value)' do
      let(:params) do
        {
          :views => {
            'fromparams' => {
              'match_clients' => 'none',
            },
          },
          :views_hiera_merge => true,
        }
      end

      it { should_not contain_bind__view('fromparams') }
      it { should contain_bind__view('from_hiera_parameter') }
      it { should contain_bind__view('from_hiera_fqdn') }
    end

    context 'when views_hiera_merge is <false>' do
      let(:params) do
        {
          :views => {
            'fromparams' => {
              'match_clients' => 'none',
            },
          },
          :views_hiera_merge => false,
        }
      end

      it { should contain_bind__view('fromparams') }
      it { should_not contain_bind__view('from_hiera_parameter') }
      it { should_not contain_bind__view('from_hiera_fqdn') }
    end
  end

  context 'with zones_dir set to valid string </other/path>' do
    let(:params) { { :zones_dir => '/other/path' } }

    it { should contain_file('named.zones.d').with_path('/other/path') }
  end

  context 'with zone_lists_dir set to valid string </other/path>' do
    let(:params) { { :zone_lists_dir => '/other/path' } }

    it { should contain_file('named.zone_lists').with_path('/other/path') }
  end

  context 'with zones set to valid hash' do
    let(:facts) do
      {
        :fqdn      => 'hiera-merge.example.local',
        :parameter => 'hiera-mergers',
      }
    end

    context 'when zones_hiera_merge is <true> (default value)' do
      let(:params) do
        {
          :zones => {
            'fromparams' => {
              'target' => '/satisfy/bind__zones',
              'type'   => 'master',
            },
          },
          :zones_hiera_merge => true,
        }
      end

      it { should_not contain_bind__zone('fromparams') }
      it { should contain_bind__zone('from_hiera_parameter') }
      it { should contain_bind__zone('from_hiera_fqdn') }
    end

    context 'when zones_hiera_merge is <false>' do
      let(:params) do
        {
          :zones => {
            'fromparams' => {
              'target' => '/satisfy/bind__zones',
              'type'   => 'master',
            },
          },
          :zones_hiera_merge => false,
        }
      end

      it { should contain_bind__zone('fromparams') }
      it { should_not contain_bind__zone('from_hiera_parameter') }
      it { should_not contain_bind__zone('from_hiera_fqdn') }
    end
  end

  describe 'variable type and content validations' do
    let(:facts) { mandatory_facts }

    validations = {
      'absolute_path' => {
        :name    => %w(config_path config_dir rndc_key named_checkconf directory dump_file statistics_file memstatistics_file
                       channels_dir channels_list acls_dir acls_list keys_list masters_dir masters_list views_dir views_list
                       zones_dir zone_lists_dir),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'array' => {
        :name    => %w(logging_category_default_channels logging_category_general_channels logging_category_config_channels
                       logging_category_client_channels logging_category_database_channels logging_category_network_channels
                       logging_category_notify_channels logging_category_queries_channels logging_category_security_channels
                       logging_category_resolver_channels logging_category_update_channels logging_category_update_security_channels
                       logging_category_xfer_in_channels logging_category_xfer_out_channels forwarders),
        :valid   => [%w(ar ray)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an Array',
      },
      'bool' => {
        :name    => %w(use_default_logging_channel enable_logging_category_default enable_logging_category_general
                       enable_logging_category_config enable_logging_category_client enable_logging_category_database
                       enable_logging_category_network enable_logging_category_notify enable_logging_category_queries
                       enable_logging_category_security enable_logging_category_resolver enable_logging_category_update
                       enable_logging_category_update_security enable_logging_category_xfer_in enable_logging_category_xfer_out),
        :valid   => [true, false],
        :invalid => ['true', 'false', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'is not a boolean',
      },
      'bool stringified' => {
        :name    => %w(channels_hiera_merge acls_hiera_merge keys_hiera_merge masters_hiera_merge views_hiera_merge zones_hiera_merge),
        :valid   => [true, false, 'true', 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      'hash' => {
        :name    => %w(controls channels acls keys masters views zones),
        :valid   => [], # valid hashes are to complex to block test them here. Subclasses have their own specific spec tests anyway.
        :invalid => ['string', 3, 2.42, %w(array), true, false, nil],
        :message => 'is not a Hash',
      },
      'integer' => {
        :name    => %w(cleaning_interval port),
        :valid   => [242, -242, '242'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, true, false, nil],
        :message => 'Expected .* to be an Integer',
      },
      'regex for check_names' => {
        :name    => %w(check_names),
        :valid   => %w(fail ignore warn),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::check_names is <.*>. Valid values are 'fail', 'ignore' and 'warn'\.",
      },
      'regex for default_logging_channel' => {
        :name    => %w(default_logging_channel),
        :valid   => %w(default_syslog default_debug default_stderr null),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::default_logging_channel is <.*> and valid values are 'default_syslog', 'default_debug', 'default_stderr' and 'null'\.",
      },
      'regex for type' => {
        :name    => %w(type),
        :valid   => %w(master slave),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::type is <.*> and must be 'master' or 'slave'\.",
      },
      # /!\ Downgrade for Puppet 3.x: remove fixnum and float from invalid list
      'string' => {
        :name    => %w(package package_ensure rndc_key_secret user group version notify_option recursion zone_statistics
                       allow_query allow_transfer listen_from dnssec_enable dnssec_validation ),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, true, false],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
