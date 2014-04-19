# This facter fact returns the CN of the CA currently installed and in use by
# Puppet

Facter.add(:rekey_cacert_new) do
  setcode do
    # This will be nil if Puppet is not available.
    vardir = Facter.value('puppet_vardir')
    cacert = File.join(vardir, 'rekey_cadir_new', 'ca_crt.pem')
    if File.exist?(cacert)
      File.read(cacert)
    end
  end
end
