# This facter fact returns the CN of the CA which signed the puppet
# agent's certificate.

begin
  require 'facter/util/puppet_settings'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__), 'util', 'puppet_settings.rb')
  load rb_file if File.exists?(rb_file) or raise e
end

Facter.add(:rekey_agent_cert_issuer) do
  setcode do
    begin
      # This will be nil if Puppet is not available.
      hostcert = Facter::Util::PuppetSettings.with_puppet { Puppet[:hostcert] }
      certificate = OpenSSL::X509::Certificate.new(File.read(hostcert))
      issuer = certificate.issuer.to_s.match(%r{CN=([^/]*)})[1].to_s
    rescue
      nil
    end
  end
end
