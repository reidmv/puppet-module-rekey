# Private class
class rekey::ca::prep {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $ssldir       = $rekey::ca::ssldir
  $backup_dir   = $rekey::ca::backup_dir
  $ca_name      = $rekey::ca::new_ca_name
  $rekey_module = get_module_path('rekey')

  file { $ssldir:
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  }

  file { "${settings::confdir}/ssl_backups":
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  }

  exec { 'rekey_preserve_installed_ssldir':
    command => "cp -Rp ${settings::ssldir} ${backup_dir}",
    creates => $backup_dir,
    path    => $::path,
    require => File["${settings::confdir}/ssl_backups"],
  }

  exec { 'rekey_create_ca':
    command => "puppet cert list --all --ssldir ${ssldir} --ca_name '${ca_name}'",
    path    => "/opt/puppet/bin:${::path}",
    creates => "${ssldir}/ca",
    require => File[$ssldir],
  }

  file { "${::puppet_vardir}/rekey_cadir_new":
    ensure => symlink,
    target => "${ssldir}/ca",
  }
  file { "${::puppet_vardir}/rekey_cadir_old":
    ensure => symlink,
    target => "${backup_dir}/ca",
  }

  # Collect and sign all exported certificate requests
  Rekey::Ca::Certificate <<| ca_name == $ca_name |>>

  if $rekey::ca::install {
    include stdlib::stages
    class { 'rekey::ca::install':
      stage => 'deploy',
    }
  }

}
