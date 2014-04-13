class rekey::install (
  $keyfile,
  $pubfile,
  $csrfile,
  $clientcert,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Ensure that the newly generated keys are installed for use by the Puppet
  # agent and that the remenants of the old CA are cleared out
  file { "${::puppet_ssldir}/private_keys/${clientcert}.pem":
    ensure  => file,
    source  => $keyfile,
    owner   => $::id,
    mode    => '0600',
    require => Exec['rekey_generate_new_private_key'],
  }
  file { "${::puppet_ssldir}/public_keys/${clientcert}.pem":
    ensure  => file,
    source  => $pubfile,
    owner   => $::id,
    mode    => '0644',
    require => Exec['rekey_generate_new_public_key'],
  }
  file { "${::puppet_ssldir}/certificate_requests/${clientcert}.pem":
    ensure  => file,
    source  => $csrfile,
    owner   => $::id,
    mode    => '0640',
    require => Exec['rekey_generate_new_csr'],
  }

  # These files should be cleared as their correct versions will be retrieved
  # on the next Puppet agent run (against the correct CA)
  file { "${::puppet_ssldir}/certs/${clientcert}.pem":
    ensure => absent,
  }
  file { "${::puppet_ssldir}/certs/ca.pem":
    ensure => absent,
  }
  file { "${::puppet_ssldir}/crl.pem":
    ensure => absent,
  }

}
