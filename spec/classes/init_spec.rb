require 'spec_helper'
describe 'sc_apache' do

  context 'with defaults for all parameters' do
    it { should contain_class('sc_apache') }
  end
end
