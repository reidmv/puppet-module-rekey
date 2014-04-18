# Configures a Puppet agent to generate a new private key and optionally
# install it.
#
# Fact expected:
# $::rekey_agent_ca_cert_fingerprint
class rekey::agent (
  $install = false,
) {

  # This is something that could be made tunable, but in order to limit scope
  # it is not tunable in this release.
  $clientcert = $::clientcert

  # It is assumed that the master has already applied the rekey::ca class to
  # itself prior to compiling any catalogs for agent systems. Therefore the
  # new ca.pem file should be available in the module's files dir.
  $rekey_module  = get_module_path('rekey')
  $module_cacert = file("${rekey_module}/files/var/ca.pem")

  # The ssldir variable specifies the temporary ssldir to create new keys in
  $module_cacert_sha1 = sha1($module_cacert)
  $ssldir = "${::puppet_vardir}/rekey_${module_cacert_sha1}"

  $directories = [
    $ssldir,
    "${ssldir}/private_keys",
    "${ssldir}/public_keys",
    "${ssldir}/certificate_requests",
  ]

  # Dependent on whether the active CA matches the rekey'd CA, either prep new
  # keys or clean up after the successful rekeying.
  if $module_cacert != $::rekey_agent_cacert {
    include rekey::agent::prep
  } else {
    include rekey::agent::tidy
  }

}
