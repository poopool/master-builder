require 'spec_helper'
describe 'wordpress' do

  context 'with defaults for all parameters' do
    it { should contain_class('wordpress') }
  end
end
