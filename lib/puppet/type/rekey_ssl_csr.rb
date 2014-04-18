Puppet::Type.newtype(:rekey_ssl_csr) do
  desc 'An OpenSSL certificate signing request'

  ensurable

  newparam(:path) do
    desc 'The path to the public key file'
    isnamevar
  end

  newparam(:private_key) do
    desc 'The path to the private key file'
  end

  newparam(:dns_alt_names) do
    desc 'Subject Alternative Names to request'
  end

  newparam(:common_name) do
    desc 'The certificate common name requested'
  end
end
