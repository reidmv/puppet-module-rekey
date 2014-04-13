# Private class
class rekey::agent::prep {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $ssldir     = $rekey::agent::ssldir
  $clientcert = $rekey::agent::clientcert

  $keyfile = "${ssldir}/private_keys/${clientcert}.pem"
  $pubfile = "${ssldir}/public_keys/${clientcert}.pem"
  $csrfile = "${ssldir}/certificate_requests/${clientcert}.pem"

  Exec {
    path => $::path,
  }

  file { $rekey::agent::directories:
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  } ->

  # TODO: Replace with ruby types for cross-platform and Puppet compatibility.
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
    before  => File["${::puppet_vardir}/rekey.csr"],
  }

  # This is a constat path to the file is picked up by the $::rekey_csr fact.
  file { "${::puppet_vardir}/rekey.csr":
    ensure => file,
    source => $csrfile,
    owner  => $::id,
    mode   => '0600',
  }

  # This is a constant path to the new ca cert
  file { "${::puppet_vardir}/rekey_ca_crt.pem":
    ensure  => file,
    content => $rekey::agent::ca_certificate,
    owner   => $::id,
    mode    => '0644',
  }

  if $rekey::agent::install_new_keys {
    # Use a class for this component in order to leverage the "deploy" stage
    # to push this to the very end of the run. This is desireable becase as
    # soon as the new certificates are installed, any calls to the old master
    # will fail, including in-run calls such as file metadata requests.
    include stdlib::stages
    class { 'rekey::agent::install':
      stage => 'deploy',
    }
  }

}
