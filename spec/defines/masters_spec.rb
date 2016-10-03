require 'spec_helper'

describe 'bind::masters' do
  let(:title) { 'rspec' }
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  # $secret is mandatory (nothing set)
  context 'with defaults for all parameters' do
    # message format (Puppet4|Puppet3)
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter 'entries'|Must pass entries)/)
    end
  end

  # full featured test, includes all hard coded resource attributes
  context 'with all parameters set to valid values' do
    let(:params) do
      {
        :entries => {
          '10.1.2.3'    => 'rndc-key',
          '192.168.1.2' => 'internal-transfer',
        }
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |masters "rspec" {
      |  10.1.2.3 key "rndc-key";
      |  192.168.1.2 key "internal-transfer";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it do
      should contain_file('/etc/named/masters.d/rspec').with({
        'ensure'  => 'file',
        'content' => content,
        'owner'   => 'named',
        'group'   => 'named',
        'mode'    => '0640',
        'require' => 'Package[bind]',
      })
    end

    it do
      should contain_concat_fragment('bind::masters::rspec').with({
        'target'  => '/etc/named/masters',
        'content' => 'include "/etc/named/masters.d/rspec";',
        'tag'     => 'bind_masters',
      })
    end
  end

  describe 'variable type and content validations' do
    let(:facts) { mandatory_facts }

    validations = {
      'hash' => {
        :name    => %w(entries),
        :valid   => [{ 'ha' => 'sh' }],
        :invalid => ['string', 3, 2.42, %w(array), true, false, nil],
        :message => 'is not a Hash',
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
