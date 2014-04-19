# This facter fact returns the CN of the CA currently installed and in use by
# Puppet

begin
  require 'facter/util/puppet_settings'
rescue LoadError => e
  # puppet apply does not add module lib directories to the $LOAD_PATH (See
  # #4248). It should (in the future) but for the time being we need to be
  # defensive which is what this rescue block is doing.
  rb_file = File.join(File.dirname(__FILE__), 'util', 'puppet_settings.rb')
  load rb_file if File.exists?(rb_file) or raise e
end

Facter.add(:rekey_active_cacert_cn) do
  setcode do
    begin
      # This will be nil if Puppet is not available.
      cacert = Facter::Util::PuppetSettings.with_puppet { Puppet[:cacert] }
      certificate = OpenSSL::X509::Certificate.new(File.read(cacert))
      issuer = certificate.subject.to_s.match(%r{CN=([^/]*)})[1].to_s
    rescue
      nil
    end
  end
end
