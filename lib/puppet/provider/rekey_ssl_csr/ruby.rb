require 'openssl'
require 'puppet/ssl/certificate_request'

Puppet::Type.type(:rekey_ssl_csr).provide(:ruby) do
  desc 'Ruby openssl provider'

  def exists?
    File.exist?(resource[:path])
  end

  def create
    key = OpenSSL::PKey::RSA.new(File.read(resource[:private_key]))

     



    csr = OpenSSL::X509::Request.new
    csr.version = 0
    csr.subject = resource[:common_name]
    csr.public_key = key.public_key

    csr.sign(key, OpenSSL::Digest::SHA1.new)
    File.open(resource[:path], 'w') do { |f| f.write(csr.to_pem) }
  end

  def destroy
    File.delete(resource[:path]) if File.exist?(resource[:path])
  end
end
