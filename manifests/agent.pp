# Configures a Puppet agent to generate a new private key and optionally
# install it.
#
# Fact expected:
# $::rekey_agent_ca_cert_fingerprint
class rekey::agent (
  $new_ca_name,
  $install = false,
) {

  # This is something that could be made tunable, but in order to limit scope
  # it is not tunable in this release.
  $clientcert = $::clientcert

  # The ssldir variable specifies the temporary ssldir to create new keys in
  $module_cacert_sha1 = sha1($module_cacert)
  $filesafe_name = regsubst($new_ca_name, '[^0-9A-Za-z.\-]', '_', 'G')
  $ssldir        = "${::puppet_vardir}/rekey_agent_${filesafe_name}"

  $rekey_installed = ($new_ca_name == $::rekey_agent_cert_issuer)

  $directories = [
    $ssldir,
    "${ssldir}/private_keys",
    "${ssldir}/public_keys",
    "${ssldir}/certificate_requests",
  ]

  # Dependent on whether the active cert issuer matches the new CA, either prep
  # new keys or clean up after the successful rekeying.
  if $rekey_installed {
    include rekey::agent::tidy
  } else {
    include rekey::agent::prep
  }

  # Import the CA cert bundle exported by the re-keying CA system
  File <<| title == 'rekey_ca_bundle' |>>

}
