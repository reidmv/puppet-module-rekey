# Configures a CA Puppet Master to generate a new CA and optionally install
# it.
class rekey::ca (
  $new_ca_name,
  $install = false,
  $purge   = false,
) {
  # This should probably be gleaned from a fact.
  $confdir = $settings::confdir

  $filesafe_name = regsubst($new_ca_name, '[^0-9A-Za-z.\-]', '_', 'G')
  $ssldir        = "${::puppet_vardir}/rekey_ca_${filesafe_name}"
  $backup_dir    = "${confdir}/ssl_backups/${filesafe_name}_predecessor"

  $rekey_ca_is_installed = ($new_ca_name == $::rekey_active_cacert_cn)

  if $rekey_ca_is_installed {
    include rekey::ca::tidy
  } else {
    include rekey::ca::prep
  }

  # Export what the CA cert bundle should look like. Because this will be
  # installed on the master system and because the master process cares what
  # order the CA certs are given in, this resource needs to care too. IMHO it's
  # totally a bug that the master cares during startup.
  if ($::rekey_cacert_old and $::rekey_cacert_new) {
    $bundle_content = $purge ? {
      true  => $::rekey_cacert_new,
      false => $rekey_ca_is_installed ? {
        true  => "${::rekey_cacert_new}${::rekey_cacert_old}",
        false => $install ? {
          true  => "${::rekey_cacert_new}${::rekey_cacert_old}",
          false => "${::rekey_cacert_old}${::rekey_cacert_new}",
        }
      }
    }
    @@file { 'rekey_ca_bundle':
      ensure  => present,
      path    => "${::puppet_ssldir}/certs/ca.pem",
      content => $bundle_content,
    }
  }

  # Also instantiate it.
  File <<| title == 'rekey_ca_bundle' |>>

}
