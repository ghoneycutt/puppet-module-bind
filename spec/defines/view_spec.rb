require 'spec_helper'

describe 'bind::view' do
  let(:title) { 'rspec' }

  context 'with defaults for all parameters' do
    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { any; };
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
  end

  # full featured test, includes all hard coded resource attributes
  context 'with all parameters set to valid values' do
    let(:params) do
      {
        :match_clients           => '10.0.0.0/8',
        :recursion               => 'yes',
        :includes                => ['10.0.0.0/16', 'included'],
        :allow_update            => '172.16.0.0/16',
        :allow_update_forwarding => '172.16.0.0/24',
        :allow_transfer          => '10.0.0.0/24',
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { "10.0.0.0/8"; };
      |  recursion yes;
      |  include "10.0.0.0/16";
      |  include "included";
      |  allow-update { "172.16.0.0/16"; };
      |  allow-update-forwarding { "172.16.0.0/24"; };
      |  allow-transfer { "10.0.0.0/24"; };
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it do
      should contain_file('/etc/named/views.d/rspec').with({
        'ensure'  => 'file',
        'content' => content,
        'owner'   => 'named',
        'group'   => 'named',
        'mode'    => '0640',
        'require' => 'Package[bind]',
      })
    end

    it do
      should contain_concat_fragment('bind::view::rspec').with({
        'target'  => '/etc/named/views',
        'content' => 'include "/etc/named/views.d/rspec";',
        'tag'     => 'bind_view',
      })
    end
  end

  context 'with match_clients set to valid <10.0.0.0/16>' do
    let(:params) { { :match_clients => '10.0.0.0/16' } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { "10.0.0.0/16"; };
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
  end

  context 'with recursion set to valid <10.0.0.0/16>' do
    let(:params) { { :recursion => 'no' } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { any; };
      |  recursion no;
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
  end

  context 'with includes set to valid array [included1 included2]' do
    let(:params) do
      {
        :includes => %w(included1 included2),
      }
    end

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { any; };
      |  include "included1";
      |  include "included2";
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
  end

  context 'with allow_update set to valid <172.16.0.0/24>' do
    let(:params) { { :allow_update => '172.16.0.0/24' } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { any; };
      |  allow-update { "172.16.0.0/24"; };
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
  end

  context 'with allow_update_forwarding set to valid <172.16.0.0/16>' do
    let(:params) { { :allow_update_forwarding => '172.16.0.0/16' } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { any; };
      |  allow-update-forwarding { "172.16.0.0/16"; };
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
  end

  context 'with allow_update set to valid <172.16.0.0/24>' do
    let(:params) { { :allow_transfer => '10.0.0.0/8' } }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |view "rspec" {
      |  match-clients { any; };
      |  allow-transfer { "10.0.0.0/8"; };
      |};
    END

    it { should compile.with_all_deps }
    it { should contain_class('bind') }

    it { should contain_file('/etc/named/views.d/rspec').with_content(content) }
    it { should contain_concat_fragment('bind::view::rspec') }
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
        :name    => %w(includes),
        :valid   => [%w(ar ray)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an Array',
      },
      'regex for recursion' => {
        :name    => %w(recursion),
        :valid   => %w(yes no),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => "bind::view::rspec::recursion is <.*> and must be either 'yes' or 'no'\.",
      },
      'string' => {
        :name    => %w(match_clients allow_update allow_update_forwarding allow_transfer),
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
