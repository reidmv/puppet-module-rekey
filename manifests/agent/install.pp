# Private class
class rekey::agent::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $keyfile    = $rekey::agent::prep::keyfile
  $pubfile    = $rekey::agent::prep::pubfile
  $csrfile    = $rekey::agent::prep::csrfile
  $clientcert = $rekey::agent::prep::clientcert

  # Note on the subscribe default: this could as easily be a require but
  # using subscribe here for brevity and since most of the files here have
  # dependencies that override the resource-default require.
  File {
    ensure    => file,
    owner     => $::id,
    backup    => false,
    subscribe => File["${::puppet_ssldir}/certs/${clientcert}.pem"],
  }

  # Ensure that a rekeyed certificate exists and is installed.
  file { "${::puppet_ssldir}/certs/${clientcert}.pem":
    source    => "puppet:///modules/rekey/var/signed/${clientcert}.pem",
    mode      => '0644',
    subscribe => undef,
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

}
