# Fact: rekey_agent_ca_cert
#
# Purpose: Return the ca certificate currently used by the agent
#
# Resolution: Returns the contents of the file specified by the localcacert
#   setting in Puppet.
#
begin
  require 'facter/util/puppet_settings'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__), 'util', 'puppet_settings.rb')
  load rb_file if File.exists?(rb_file) or raise e
end

Facter.add("rekey_agent_ca_cert") do
  setcode do
    localcacert = Facter::Util::PuppetSettings.with_puppet do
      Puppet[:localcacert]
    end
    if File.exist?(localcacert)
      File.read(localcacert)
    end
  end
end
