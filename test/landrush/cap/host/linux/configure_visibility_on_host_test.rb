require_relative '../../../../test_helper'

module Landrush
  module Cap
    module Linux
      describe ConfigureVisibilityOnHost do
        TEST_IP = '10.42.42.42'.freeze
        TEST_TLD = 'landrush.test'.freeze
        TEST_CONFIG = "/etc/dnsmasq.d/vagrant-landrush-#{TEST_TLD}".freeze

        CONFIG = <<-EOF.gsub(/^ +/, '')
        # Generated by landrush, a vagrant plugin
        server=/landrush.test/127.0.0.1#10053
        EOF

        after do
          system("sudo rm #{TEST_CONFIG}") if Pathname(TEST_CONFIG).exist?
        end

        describe 'dnsmasq' do
          it 'creates dnsmasq config' do
            skip('Only supported on Linux') unless Vagrant::Util::Platform.linux?
            File.exist?(TEST_CONFIG).must_equal false

            Landrush::Cap::Linux::ConfigureVisibilityOnHost.configure_visibility_on_host(Vagrant::Environment.new, TEST_IP, TEST_TLD)

            File.exist?(TEST_CONFIG).must_equal true
            Pathname(TEST_CONFIG).read.must_equal CONFIG
          end
        end
      end
    end
  end
end
