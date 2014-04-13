# Fact expected:
# $::rekey_agent_ca_cert_fingerprint
class rekey (
  $ca_certificate,
  $install_new_keys = false,
  $clientcert       = $::clientcert,
) {

  # The ssldir variable specifies the temporary ssldir to create new keys in
  $ca_sha1 = sha1($ca_certificate)
  $ssldir = "${::puppet_vardir}/rekey_${ca_sha1}"

  $directories = [
    $ssldir,
    "${ssldir}/private_keys",
    "${ssldir}/public_keys",
    "${ssldir}/certificate_requests",
  ]

  # Dependent on whether the active CA matches the rekey'd CA, either prep new
  # keys or clean up after the successful rekeying.
  if $ca_certificate != $::rekey_agent_ca_certificate {
    include rekey::prep
  } else {
    include rekey::tidy
  }

}
