require 'spec_helper'

describe 'bind::zone' do
  let(:title) { 'rspec' }
  # realize virtual resources to allow spec testing them
  let :pre_condition do
    'Concat_fragment <| |>'
  end

  context 'with defaults for all parameters' do
    # message format (Puppet4|Puppet3)
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter 'target'|Must pass target)/)
    end
  end

  # full featured test, includes all hard coded resource attributes
  context 'with all parameters set to valid values' do
    let(:params) do
      {
        :target     => '/etc/named/zone_lists/internal.zones',
        :tag        => 'internal',
        :extra_path => '/internal',
        :masters    => 'master-internal',
        :type       => 'slave',
      }
    end
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |zone "rspec" {
      |  type slave;
      |  masters { master-internal; };
      |  file "slaves/internal/rspec";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it do
      should contain_file('/etc/named/zones.d/rspec').with({
        'ensure'  => 'file',
        'content' => content,
        'owner'   => 'named',
        'group'   => 'named',
        'mode'    => '0640',
        'require' => 'Package[bind]',
      })
    end

    it do
      should contain_concat_fragment('bind::zone::rspec').with({
        'target'  => '/etc/named/zone_lists/internal.zones',
        'content' => 'include "/etc/named/zones.d/rspec";',
        'tag'     => 'internal',
      })
    end
  end

  context 'with target set to valid </absolute/path> and mandatories fullfilled' do
    let(:params) do
      {
        :target => '/absolute/path',
        # mandatories
        :type   => 'master',
      }
    end

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_concat_fragment('bind::zone::rspec').with_target('/absolute/path') }
  end

  context 'with tag set to valid <testing> and mandatories fullfilled' do
    let(:params) do
      {
        :tag    => 'testing',
        # mandatories
        :target => '/absolute/path',
        :type   => 'master',
      }
    end

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_concat_fragment('bind::zone::rspec').with_tag('testing') }
  end

  context 'with extra_path set to valid </SPECtacular> and mandatories fullfilled' do
    let(:params) do
      {
        :extra_path => '/SPECtacular',
        # mandatories
        :target     => '/absolute/path',
        :type       => 'master',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |zone "rspec" {
      |  type master;
      |  file "master/SPECtacular/rspec";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/zones.d/rspec').with_content(content) }
  end

  context 'with masters set to valid <master-spec> and type set to <master>' do
    let(:params) do
      {
        :masters => 'master-spec',
        :type    => 'master',
        # mandatories
        :target  => '/absolute/path',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |zone "rspec" {
      |  type master;
      |  file "master/rspec";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/zones.d/rspec').with_content(content) }
  end

  context 'with masters set to valid <master-spec> and type set to <slave>' do
    let(:params) do
      {
        :masters => 'master-spec',
        :type    => 'slave',
        # mandatories
        :target  => '/absolute/path',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |zone "rspec" {
      |  type slave;
      |  masters { master-spec; };
      |  file "slaves/rspec";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/zones.d/rspec').with_content(content) }
  end

  context 'with type set to valid <slave> but undefined masters' do
    let(:params) do
      {
        :type    => 'slave',
        # mandatories
        :target  => '/absolute/path',
      }
    end

    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /If type is slave, then masters must be specified\. Value for type is <slave> and masters is <>\./)
    end
  end
  context 'with type set to valid <slave> and master set to <master-spec>' do
    let(:params) do
      {
        :type    => 'slave',
        :masters => 'master-spec',
        # mandatories
        :target  => '/absolute/path',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |zone "rspec" {
      |  type slave;
      |  masters { master-spec; };
      |  file "slaves/rspec";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }
    it { should contain_file('/etc/named/zones.d/rspec').with_content(content) }
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
        :target => '/absolute/path',
        :type   => 'master',
      }
    end

    validations = {
      'regex for type' => {
        :name    => %w(type),
        :valid   => %w(master slave),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::zone::rspec::type is <.*> and must be 'master' or 'slave'\.",
        :params  => { :masters => 'master-spectest' },
      },
      'absolute_path' => {
        :name    => %w(target extra_path),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'string' => {
        :name    => %w(tag masters),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
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
