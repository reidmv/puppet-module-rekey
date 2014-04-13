# Private class
class rekey::agent::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $keyfile    = $rekey::agent::prep::keyfile
  $pubfile    = $rekey::agent::prep::pubfile
  $csrfile    = $rekey::agent::prep::csrfile
  $clientcert = $rekey::agent::prep::clientcert

  File {
    ensure  => file,
    owner   => $::id,
    require => File["${::puppet_ssldir}/certs/${clientcert}.pem"],
    backup  => false,
  }

  # Ensure that a rekeyed certificate exists and is installed
  file { "${::puppet_ssldir}/certs/${clientcert}.pem":
    source  => "puppet:///modules/rekey/var/${clientcert}.pem",
    mode    => '0644',
    require => undef,
  }

  # Ensure that the newly generated keys are installed for use by the Puppet
  # agent and that the remenants of the old CA are cleared out
  file { "${::puppet_ssldir}/private_keys/${clientcert}.pem":
    source  => $keyfile,
    mode    => '0600',
    require => Exec['rekey_generate_new_private_key'],
  }
  file { "${::puppet_ssldir}/public_keys/${clientcert}.pem":
    source  => $pubfile,
    mode    => '0644',
    require => Exec['rekey_generate_new_public_key'],
  }
  file { "${::puppet_ssldir}/certificate_requests/${clientcert}.pem":
    source  => $csrfile,
    mode    => '0640',
    require => Exec['rekey_generate_new_csr'],
  }

  # Part of rolling over to a new CA is installing the new CA cert. We can't
  # just blow it away because then we don't have any assurance that the next
  # run will be against a master certified by the correct ca, and if we don't
  # install the cert now we can't ensure the agent will be keyed to the new
  # one.
  file { "${::puppet_ssldir}/certs/ca.pem":
    source  => "${::puppet_vardir}/rekey_ca_crt.pem",
    mode    => '0644',
    require => File["${::puppet_vardir}/rekey_ca_crt.pem"],
  }

  # These files should be cleared as their correct versions will be retrieved
  # on the next Puppet agent run (against the correct CA)
  file { "${::puppet_ssldir}/certs/${clientcert}.pem":
    ensure => absent,
  }
  file { "${::puppet_ssldir}/crl.pem":
    ensure => absent,
  }

}
