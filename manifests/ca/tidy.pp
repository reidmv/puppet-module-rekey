# Private class
class rekey::ca::tidy {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # This class being called means that the re-keyed CA has been installed.

  file { "${::puppet_vardir}/rekey_cadir_new":
    ensure => symlink,
    target => "${::puppet_ssldir}/ca",
  } ->
  file { $rekey::ca::ssldir:
    ensure => absent,
    force  => true,
  }

}
