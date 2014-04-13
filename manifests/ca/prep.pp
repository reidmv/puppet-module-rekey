# Private class
class rekey::ca::prep {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $ssldir       = $rekey::ca::ssldir
  $rekey_module = get_module_path('rekey')

  file { $ssldir:
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  } ->

  exec { 'rekey_create_ca':
    command => "puppet cert list --all --ssldir ${ssldir}",
    path    => "/opt/puppet/bin:${::path}",
    creates => "${ssldir}/ca",
  } ->

  file { "${rekey_module}/files/var/ca.pem":
    ensure  => file,
    owner   => $::id,
    mode    => '0644',
    source  => "${ssldir}/ca/ca_crt.pem",
  }

  if $rekey::ca::install {
    include stdlib::stages
    class { 'rekey::ca::install':
      stage => 'deploy',
    }
  }

}
