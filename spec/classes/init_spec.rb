require 'spec_helper'
describe 'bind' do
  context 'with defaults for all parameters' do
    it { should contain_class('bind') }
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        #:fact => 'value',
      }
    end
    # /!\ template does not support $include = undef
    # workaround is to set $include to an empty array
    let(:mandatory_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'absolute_path' => {
        :name    => %w(config_path config_dir rndc_key named_checkconf directory dump_file statistics_file memstatistics_file channels_dir channels_list acls_dir acls_list keys_list masters_dir masters_list views_dir views_list zones_dir zone_lists_dir),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'bool' => {
        :name    => %w(use_default_logging_channel enable_logging_category_default enable_logging_category_general enable_logging_category_config enable_logging_category_client enable_logging_category_database enable_logging_category_network enable_logging_category_queries enable_logging_category_security enable_logging_category_resolver enable_logging_category_update enable_logging_category_update_security enable_logging_category_xfer_in enable_logging_category_xfer_out),
        :valid   => [true, false],
        :invalid => ['true', 'false', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'is not a boolean',
      },
      'integer' => {
        :name    => %w(cleaning_interval port),
        :valid   => [242, -242, '242'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, true, false, nil],
        :message => 'Expected .* to be an Integer',
      },
      'regex for type' => {
        :name    => %w(type),
        :valid   => %w(master slave),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::type is <.*> and must be 'master' or 'slave'\.",
      },
      'regex for default_logging_channel' => {
        :name    => %w(default_logging_channel),
        :valid   => %w(default_syslog default_debug default_stderr null),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::default_logging_channel is <.*> and valid values are 'default_syslog', 'default_debug', 'default_stderr' and 'null'\.",
      },
      # /!\ Downgrade for Puppet 3.x: remove fixnum and float from invalid list
      'string' => {
        :name    => %w(package package_ensure rndc_key_secret user group version notify_option recursion zone_statistics allow_query allow_transfer listen_from dnssec_enable dnssec_validation ),
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
