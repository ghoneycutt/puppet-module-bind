require 'spec_helper'

describe 'bind::acl' do
  let(:title) { 'rspec' }

  context 'with defaults for all parameters' do
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /There must be at least one parameter of .* specified and all are undef/)
    end
  end

  context 'with all parameters set to valid values' do
    let(:params) do
      {
        :entries     => %w(10.0.0.0/24 network),
        :not_entries => %w(66.66.66.66/23 not_network),
        :keys        => %w(key1 key2),
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |acl "rspec" {
      |  !66.66.66.66/23;
      |  !"not_network";
      |
      |  10.0.0.0/24;
      |  "network";
      |
      |  key "key1";
      |  key "key2";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it do
      should contain_file('/etc/named/acls.d/rspec').with({
        'ensure'  => 'file',
        'owner'   => 'named',
        'group'   => 'named',
        'mode'    => '0640',
        'require' => 'Package[bind]',
        'content' => content,
      })
    end

    it do
      should contain_concat_fragment('bind::acl::rspec').with({
        'target'  => '/etc/named/acls',
        'content' => 'include "/etc/named/acls.d/rspec";',
        'tag'     => 'bind_acl',
      })
    end
  end

  context 'with entries set to valid array' do
    let(:params) { { :entries => ['10.0.0.0/24', 'network'] } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |acl "rspec" {
      |
      |  10.0.0.0/24;
      |  "network";
      |
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/acls.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::acl::rspec') }
  end

  context 'with not_entries set to valid array' do
    let(:params) { { :not_entries => ['66.66.66.66/23', 'not_network'] } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |acl "rspec" {
      |  !66.66.66.66/23;
      |  !"not_network";
      |
      |
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/acls.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::acl::rspec') }
  end

  context 'with keys set to valid array' do
    let(:params) { { :keys => %w(key1 key2) } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |acl "rspec" {
      |
      |
      |  key "key1";
      |  key "key2";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/acls.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::acl::rspec') }
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
        #:fact => 'value',
      }
    end
    let(:mandatory_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'array' => {
        :name    => %w(entries not_entries keys),
        :valid   => [%w(ar ray)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an Array',
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
