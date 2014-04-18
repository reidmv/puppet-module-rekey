Puppet::Type.newtype(:rekey_ssl_private_key) do
  desc 'An OpenSSL private key'

  ensurable

  newparam(:path) do
    desc 'The path to the private key file'
    isnamevar
  end

  newparam(:size) do
    desc 'The key size'
    defaultto 4096
  end
end
