module Landrush
  class Plugin < Vagrant.plugin('2')
    name 'landrush'

    command 'landrush' do
      require_relative 'command'
      Command
    end

    config 'landrush' do
      require_relative 'config'
      Config
    end

    action_hook 'landrush_setup', :machine_action_up do |hook|
      require_relative 'action/setup'
      require_relative 'action/install_prerequisites'
      require_relative 'action/redirect_dns'

      register_boot_hooks = lambda { |boot_action|
        hook.before(boot_action, pre_boot_actions)
        hook.after(boot_action, post_boot_actions)
      }

      register_boot_hooks.call(VagrantPlugins::ProviderVirtualBox::Action::Boot)

      if defined?(HashiCorp::VagrantVMwarefusion)
        register_boot_hooks.call(HashiCorp::VagrantVMwarefusion::Action::Boot)
      end
    end

    def self.pre_boot_actions
      Vagrant::Action::Builder.new.tap do |b|
        b.use Action::Setup
      end
    end

    def self.post_boot_actions
      Vagrant::Action::Builder.new.tap do |b|
        b.use Action::InstallPrerequisites
        b.use Action::RedirectDns
      end
    end

    action_hook 'landrush_teardown', :machine_action_halt do |hook|
      require_relative 'action/teardown'
      hook.after(Vagrant::Action::Builtin::GracefulHalt, Action::Teardown)
    end

    action_hook 'landrush_teardown', :machine_action_destroy do |hook|
      require_relative 'action/teardown'
      hook.after(Vagrant::Action::Builtin::GracefulHalt, Action::Teardown)
    end

    guest_capability('debian', 'iptables_installed') do
      require_relative 'cap/debian/iptables_installed'
      Cap::Debian::IptablesInstalled
    end

    guest_capability('debian', 'install_iptables') do
      require_relative 'cap/debian/install_iptables'
      Cap::Debian::InstallIptables
    end

    guest_capability('linux', 'configured_dns_server') do
      require_relative 'cap/linux/configured_dns_server'
      Cap::Linux::ConfiguredDnsServer
    end

    guest_capability('linux', 'redirect_dns') do
      require_relative 'cap/linux/redirect_dns'
      Cap::Linux::RedirectDns
    end

    guest_capability('linux', 'add_iptables_rule') do
      require_relative 'cap/linux/add_iptables_rule'
      Cap::Linux::AddIptablesRule
    end
  end
end
