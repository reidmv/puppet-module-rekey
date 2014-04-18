require 'openssl'

Puppet::Type.type(:rekey_ssl_public_key).provide(:ruby) do
  desc 'Ruby openssl provider'

  def exists?
    File.exist?(resource[:path])
  end

  def create
    key    = OpenSSL::PKey::RSA.new(File.read(resource[:private_key]))
    pubkey = key.public_key
    File.open(resource[:path], 'w') do { |f| f.write(pubkey.to_pem) }
  end

  def destroy
    File.delete(resource[:path]) if File.exist?(resource[:path])
  end
end
