# Private class
class rekey::agent::tidy {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { [$rekey::agent::directories, "${::puppet_vardir}/rekey.csr"]:
    ensure => absent,
    force  => true,
  }
}
