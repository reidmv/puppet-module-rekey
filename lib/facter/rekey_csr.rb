# Fact: rekey_csr
#
# Purpose: Return the CSR created by the rekey class
#
# Resolution: Checks the known standard location for the generated CSR, and if
#   the file is present, returns its contents. If the file is absent, this
#   fact will not resolve.
#
Facter.add("rekey_csr") do
  setcode do
    rekey_csr = File.join(Facter.value('puppet_vardir'), 'rekey.csr')
    if File.exist?(rekey_csr)
      File.read(rekey_csr)
    end
  end
end
