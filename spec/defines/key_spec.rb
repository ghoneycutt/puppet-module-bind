require 'spec_helper'

describe 'bind::key' do
  let(:title) { 'rspec' }

  # $secret is mandatory (nothing set)
  context 'with defaults for all parameters' do
    # message format (Puppet4|Puppet3)
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter 'secret'|Must pass secret)/)
    end
  end

  # full featured test, includes all hard coded resource attributes
  context 'with all parameters set to valid values' do
    let(:params) do
      {
        :secret    => 'Passw0rd',
        :algorithm => 'dsa',
        :path      => '/absolute/path',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |key "rspec" {
      |  algorithm dsa;
      |  secret "Passw0rd";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it do
      should contain_file('bind::key::rspec').with({
        'ensure'  => 'file',
        'path'    => '/absolute/path',
        'content' => content,
        'owner'   => 'root',
        'group'   => 'named',
        'mode'    => '0640',
        'require' => 'Package[bind]',
        'notify'  => 'Service[named]',
      })
    end

    it do
      should contain_concat_fragment('bind::keys::rspec').with({
        'target'  => '/etc/named/keys',
        'content' => 'include "/absolute/path";',
        'tag'     => 'bind_keys',
      })
    end
  end

  # $secret is mandatory (others set)
  %w(algorithm path).each do |param|
    context "with #{param} set to valid value" do
      let(:params) { { :"#{param}" => '/absolute/path' } }

      # message format (Puppet4|Puppet3)
      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter 'secret'|Must pass secret)/)
      end
    end
  end

  context 'with secret set to valid value <Pa55w0rd!>' do
    let(:params) { { :secret => 'Pa55w0rd!' } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |key "rspec" {
      |  algorithm hmac-md5;
      |  secret "Pa55w0rd!";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('bind::key::rspec').with_content(content) }
    it { should contain_concat_fragment('bind::keys::rspec') }
  end

  context 'with algorithm set to valid value <hmac-sha512> and mandatories fullfilled' do
    let(:params) do
      {
        :secret    => 'secret',
        :algorithm => 'hmac-sha512',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |key "rspec" {
      |  algorithm hmac-sha512;
      |  secret "secret";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('bind::key::rspec').with_content(content) }
    it { should contain_concat_fragment('bind::keys::rspec') }
  end

  context 'with path set to valid value </special/path> and mandatories fullfilled' do
    let(:params) do
      {
        :secret => 'secret',
        :path   => '/special/path',
      }
    end

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('bind::key::rspec').with_path('/special/path') }
    it { should contain_concat_fragment('bind::keys::rspec') }
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
        :secret => 'geheim',
      }
    end

    validations = {
      # enhancement: validate valid values for algorithm
      'absolute_path' => {
        :name    => %w(path),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'string' => {
        :name    => %w(algorithm secret),
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
