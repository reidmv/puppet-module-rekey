require 'openssl'

Puppet::Type.type(:rekey_ssl_private_key).provide(:ruby) do
  desc 'Ruby openssl provider'

  def exists?
    File.exist?(resource[:path])
  end

  def create
    key = OpenSSL::PKey::RSA.new(resource[:size])
    File.open(resource[:path], 'w') do { |f| f.write(key.to_pem) }
  end

  def destroy
    File.delete(resource[:path]) if File.exist?(resource[:path])
  end
end
