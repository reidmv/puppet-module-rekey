define rekey::ca::certificate (
  $csr_content,
  $certname,
) {
  include rekey::ca
  $ssldir = $rekey::ca::ssldir

  if !defined(File["${ssldir}/ca/requests_archive"]) {
    file { "${ssldir}/ca/requests_archive":
      ensure  => directory,
      require => Exec['rekey_create_ca'],
    }
  }

  file { "${ssldir}/ca/requests_archive/${certname}.pem":
    ensure  => file,
    content => $csr_content,
    require => Exec['rekey_create_ca'],
  } ->
  exec { "rekey_stage_${certname}_csr":
    path    => "/opt/puppet/bin:${::path}",
    command => "cp ${ssldir}/ca/requests_archive/${certname}.pem ${ssldir}/ca/requests/",
    creates => "${ssldir}/ca/signed/${certname}.pem",
  } ->
  exec { "rekey_sign_${certname}":
    path    => "/opt/puppet/bin:${::path}",
    command => "puppet cert sign --ssldir ${ssldir} ${certname}",
    creates => "${ssldir}/ca/signed/${certname}.pem",
    before  => File['rekey_moduledir_signed_copy'],
  }

}
