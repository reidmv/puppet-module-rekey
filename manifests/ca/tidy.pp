# Private class
class rekey::ca::tidy {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $rekey::ca::ssldir:
    ensure => absent,
    force  => true,
  }

  file { 'rekey_moduledir_signed_copy':
    path    => "${rekey::rekey_module}/files/var/signed",
    ensure  => absent,
    force   => true,
  }
}
