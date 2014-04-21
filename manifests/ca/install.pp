# Private class
class rekey::ca::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $backup_file = "${rekey::ca::backup_dir}/final_snapshot.tar.gz"

  exec { 'rekey_final_snapshot_installed_ssldir':
    command => "tar -czf ${backup_file} ${settings::ssldir}",
    creates => $backup_file,
    path    => $::path,
    require => File["${settings::confdir}/ssl_backups"],
  }

  file { "${::puppet_ssldir}/ca":
    ensure  => directory,
    source  => "${rekey::ca::ssldir}/ca",
    recurse => true,
    purge   => true,
    force   => true,
    backup  => false,
    require => Exec['rekey_final_snapshot_installed_ssldir'],
  }

}
