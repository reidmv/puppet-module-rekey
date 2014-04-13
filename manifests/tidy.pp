# Private class
class rekey::tidy {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { [$rekey::directories, "${::puppet_vardir}/rekey.csr"]:
    ensure => absent,
    force  => true,
  }
}
