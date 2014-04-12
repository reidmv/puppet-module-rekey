# Fact expected:
# $::rekey_agent_ca_cert_fingerprint
class rekey (
  $ca_sha1_fingerprint,
  $clientcert = $::clientcert,
) {

  # Sanitize the sha1 fingerprint parameter and verify that it looks like a
  # valid sha1. Note that in order to use the size() function we have to make
  # the string be not a valid number. The size() function rejects any string
  # that can be cast to a Float.
  $sanitized_ca_fingerprint = delete($ca_sha1_fingerprint, ':')
  if size("x${sanitized_ca_fingerprint}") != 41 {
    fail("Class[rekey]/ca_sha1_fingerprint: Expected sha1 hash string")
  }

  # The ssldir variable specifies the temporary ssldir to create new keys in
  $ssldir = "${::puppet_vardir}/rekey_${ca_sha1_fingerprint}"

  $directories = [
    $ssldir,
    "${ssldir}/private_keys",
    "${ssldir}/public_keys",
    "${ssldir}/certificate_requests",
  ]

  # Dependent on whether the active CA matches the rekey'd CA, either prep new
  # keys or clean up after the successful rekeying.
  if $ca_sha1_fingerprint != $::rekey_agent_ca_sha1_fingerprint {
    class { 'rekey::prep':
      directories => $directories,
      keyfile     => "${ssldir}/private_keys/${clientcert}.pem",
      pubfile     => "${ssldir}/public_keys/${clientcert}.pem",
      csrfile     => "${ssldir}/certificate_requests/${clientcert}.pem",
      clientcert  => $clientcert,
    }
  } else {
    class { 'rekey::tidy':
      directories => $ssldir,
    }
  }

}
