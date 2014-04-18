Puppet::Type.newtype(:rekey_ssl_public_key) do
  desc 'An OpenSSL public key'

  ensurable

  newparam(:path) do
    desc 'The path to the public key file'
    isnamevar
  end

  newparam(:private_key) do
    desc 'The path to the private key file'
  end
end
