# Fact expected:
# $::rekey_agent_ca_cert
class rekey (
  $ca_cert,
  $rekey_ssldir = undef,
  $clientcert   = $::clientcert,
) {

  # Choose an alternate ssldir to use for generating new keys, if not supplied
  $rekey_ca_cert_sha1 = sha1($ca_cert)
  $ssldir = $rekey_ssldir ? {
    undef   => "${::puppet_vardir}/rekey_${rekey_ca_cert_sha1}",
    default => $rekey_ssldir,
  }

  $directories = [
    $ssldir,
    "${ssldir}/private_keys",
    "${ssldir}/public_keys",
    "${ssldir}/certificate_requests",
  ]

  file { $directories:
    ensure => directory,
    owner  => $::id,
    mode   => '0700',
  }

  if $ca_cert != $::puppet_agent_ca_cert {
    $keyfile = "${ssldir}/private_keys/${clientcert}.pem"
    $pubfile = "${ssldir}/public_keys/${clientcert}.pem"
    $csrfile = "${ssldir}/certificate_requests/${clientcert}.pem"

    Exec {
      require => File[$directories],
      path    => $::path,
    }

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
      ensure  => file,
      content => $csrfile,
      owner   => $::id,
      mode    => '0644',
    }
  }

  ## TODO: provide for cleaning up the rekey ssldir when appropriate

}
