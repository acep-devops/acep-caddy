#
# Cookbook:: acep-caddy
# Spec:: debian
#
# Copyright:: 2024, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'acep-caddy::ubuntu' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/main/PLATFORMS.md
    platform 'ubuntu', '22.04'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
