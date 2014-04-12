# Private class
class rekey::tidy (
  $directories,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { [$directories, "${::puppet_vardir}/rekey.csr"]:
    ensure => absent,
    force  => true,
  }

}
