require 'spec_helper'

describe 'bind::channel' do
  let(:title) { 'rspec' }

  # $type is mandatory (nothing set)
  context 'with defaults for all parameters' do
    # message format (Puppet4|Puppet3)
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter 'type'|Must pass type)/)
    end
  end

  # full featured test, includes all hard coded resource attributes
  context 'with all parameters set to valid values' do
    let(:params) do
      {
        :type            => 'stderr',
        :file            => '/absolute/path',
        :severity        => 'error',
        :syslog_facility => 'daemon',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |channel rspec {
      |  file "/absolute/path";
      |  syslog daemon;
      |  severity error;
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it do
      should contain_file('/etc/named/channels.d/rspec').with({
        'ensure'  => 'file',
        'owner'   => 'named',
        'group'   => 'named',
        'mode'    => '0640',
        'require' => 'Package[bind]',
        'content' => content,
      })
    end

    it do
      should contain_concat_fragment('bind::channel::rspec').with({
        'target'  => '/etc/named/channels',
        'content' => 'include "/etc/named/channels.d/rspec";',
        'tag'     => 'bind_channel',
      })
    end
  end

  # $type is mandatory (others set)
  %w(file severity syslog_facility).each do |param|
    context "with #{param} set to valid value" do
      let(:params) { { :"#{param}" => 'file' } }

      # message format (Puppet4|Puppet3)
      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter 'type'|Must pass type)/)
      end
    end
  end

  # syslog_facility and file cannot both be undef (only $type set)
  context 'with type set to valid value' do
    let(:params) { { :type => 'file' } }

    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /bind::channel::syslog_facility and bind::channel::file cannot both be undef/)
    end
  end

  # syslog_facility and file cannot both be undef ($type and $severity set)
  context 'with type and severity set to valid values' do
    let(:params) do
      {
        :type     => 'file',
        :severity => 'debug',
      }
    end

    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /bind::channel::syslog_facility and bind::channel::file cannot both be undef/)
    end
  end

  # /!\ there is no functionality for $type yet
  # functionality check only, see 'variable type and content validations' below for more
  context 'with type set to valid value <stderr> and mandatories fullfilled' do
    let(:params) do
      {
        :type => 'stderr',
        # mandatories:
        :file => '/absolute/path',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |channel rspec {
      |  file "/absolute/path";
      |  severity ;
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/channels.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::channel::rspec') }
  end

  # functionality check only, see 'variable type and content validations' below for more
  context 'with file set to valid value </absolute/path> and mandatories fullfilled' do
    let(:params) do
      {
        :file => '/absolute/path',
        # mandatories:
        :type => 'file',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |channel rspec {
      |  file "/absolute/path";
      |  severity ;
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/channels.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::channel::rspec') }
  end

  # functionality check only, see 'variable type and content validations' below for more
  context 'with severity set to valid value <warning> and mandatories fullfilled' do
    let(:params) do
      {
        :severity => 'warning',
        # mandatories:
        :type     => 'file',
        :file     => '/absolute/path',
      }
    end

    # /!\ unsure if severity should get printed if no value is set
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |channel rspec {
      |  file "/absolute/path";
      |  severity warning;
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/channels.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::channel::rspec') }
  end

  # functionality check only, see 'variable type and content validations' below for more
  # enhancement: validate valid values for syslog
  context 'with syslog_facility set to valid value <syslog> and mandatories fullfilled' do
    let(:params) do
      {
        :syslog_facility => 'syslog',
        # mandatories:
        :type            => 'file',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |channel rspec {
      |  syslog syslog;
      |  severity ;
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/channels.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::channel::rspec') }
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
        :type => 'file',
        :file => '/absolute/path',
      }
    end

    validations = {
      'regex for type' => {
        :name    => %w(type),
        :valid   => %w(file syslog stderr null),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'bind::channel::rspec::type is <.*>\. Valid values are',
      },
      # enhancement: validate valid values for severity & syslog_facility
      'string' => {
        :name    => %w(file severity syslog_facility),
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
