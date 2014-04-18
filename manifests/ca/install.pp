# Private class
class rekey::ca::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $backup_file = "${rekey::ca::backup_dir}/final_snapshot.tar.gz"

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
    backup  => false,
    require => Exec['rekey_preserve_installed_ssldir'],
  }

}
