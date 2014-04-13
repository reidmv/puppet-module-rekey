# Private class
class rekey::ca::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $old_ca_hash = sha1($rekey::ca::installed_ca)
  $backup_file = "${settings::confdir}/ssl_backups/ssl.${old_ca_hash}.tar.gz"

  file { "${settings::confdir}/ssl_backups":
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  }

  exec { 'rekey_preserve_installed_ssldir':
    command => "tar -czf ${backup_file} ${settings::ssldir}",
    creates => $backup_file,
    path    => $::path,
    require => File["${settings::confdir}/ssl_backups"],
  }

  file { $settings::ssldir:
    ensure  => directory,
    source  => $rekey::ca::ssldir,
    recurse => true,
    purge   => true,
    force   => true,
    require => Exec['rekey_preserve_installed_ssldir'],
  }

}
