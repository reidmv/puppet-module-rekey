# Configures a CA Puppet Master to generate a new CA and optionally install
# it.
class rekey::ca (
  $install = false,
) {

  $ssldir       = "${::puppet_vardir}/rekey_ca"
  $rekey_module = get_module_path('rekey')

  $installed_ca = file("${settings::ssldir}/ca/ca_crt.pem")
  $rekey_ca     = file(
    "${rekey_module}/files/var/ca.pem",
    "${ssldir}/ca/ca_crt.pem",
    '/dev/null'
  )

  $rekey_ca_is_installed = ($installed_ca == $rekey_ca)

  if $rekey_ca_is_installed {
    include rekey::ca::tidy
  } else {
    include rekey::ca::prep
  }

}
