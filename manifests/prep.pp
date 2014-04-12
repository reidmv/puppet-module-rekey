# Private class
class rekey::prep (
  $directories,
  $keyfile,
  $pubfile,
  $csrfile,
  $clientcert,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  Exec {
    path => $::path,
  }

  file { $directories:
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  } ->

  # TODO: Replace with ruby types for cross-platform compatibility
  exec { 'rekey_generate_new_private_key':
    command => "openssl genrsa -out ${keyfile} 4096",
    creates => $keyfile,
  } ->
  exec { 'rekey_generate_new_public_key':
    command => "openssl rsa -in ${keyfile} -pubout -out ${pubfile}",
    creates => $pubfile,
  } ->
  exec { 'rekey_generate_new_csr':
    command => "openssl req -new -key ${keyfile} -out ${csrfile} -subj /CN=${clientcert}",
    creates => $csrfile,
  } ->

  # This file is picked up by the $::rekey_csr fact
  file { "${::puppet_vardir}/rekey.csr":
    ensure => file,
    source => $csrfile,
    owner  => $::id,
    mode   => '0644',
  }

}
