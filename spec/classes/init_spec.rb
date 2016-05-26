require 'spec_helper'
describe 'bind' do

  context 'with defaults for all parameters' do
    it { should contain_class('bind') }
  end
end
