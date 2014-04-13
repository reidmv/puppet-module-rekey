class rekey::ca::tidy {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { $rekey::ca::ssldir:
    ensure => absent,
    force  => true,
  }
}
