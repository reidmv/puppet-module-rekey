# Private class
class rekey::prep (
  $directories,
  $keyfile,
  $pubfile,
  $csrfile,
  $clientcert,
  $install,
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

  # TODO: Replace with ruby types for cross-platform and Puppet compatibility.
  #       The stand-in exec resources below demonstrate what needs to happen
  #       but these exec-generated keys are not drop-in compatible with
  #       Puppet. I don't know what flags to give to the openssl cli to build
  #       the correct kind of file(s).
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

  # This file is picked up by the $::rekey_csr fact. If using a puppet version
  # that supports symlinks on all platforms, create a symlink. This allows noop
  # runs to complete without error. Otherwise copy the file from it's
  # CA-specific directory into the fact location (works on Windows in PE <3.2).
  if ($::puppetversion =~ /^3.[4-9]|^3.\d\d|[4-9]|\d\d/) {
    file { "${::puppet_vardir}/rekey.csr":
      ensure  => symlink,
      target  => $csrfile,
    }
  } else {
    file { "${::puppet_vardir}/rekey.csr":
      ensure => file,
      source => $csrfile,
      owner  => $::id,
      mode   => '0600',
    }
  }

  if "x${install}" == 'xtrue' {
    # Use a class for this component in order to leverage the "deploy" stage
    # to push this to the very end of the run. This is desireable becase as
    # soon as the new certificates are installed, any calls to the old master
    # will fail, including in-run calls such as file metadata requests.
    include stdlib::stages
    class { 'rekey::install':
      keyfile    => $keyfile,
      pubfile    => $pubfile,
      csrfile    => $csrfile,
      clientcert => $clientcert,
      stage      => 'deploy',
    }
  }

}
