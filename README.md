# Rekey Puppet Module #

The purpose of this module is to provide a means of declaring that a classified
agent should have a standby certificate generated for itself, and optionally
that that new certificate should be installed. The grander objective is to
re-key an entire Puppet infrastructure with keys issued by a new certificate
authority.

## Process ##

1. Classify the PE master node with the `rekey::ca` class. This will ensure
   that the master generates a standby CA, the certificate for which will be
   concatenated with the current CA certificate, and the resulting CA bundle
   made available at `puppet:///modules/rekey/var/ca.pem`. The CA bundle will
   also be installed in /etc/puppetlabs/puppet/ssl/certs/ca.pem.
2. Classify all agent nodes with the `rekey::agent` class. This will ensure all
   agent systems generate a new private key for themselves and submit as a fact
   a CSR for that key, and a CSR as an exported resource. They will also
   install the old+new CA bundle in /etc/puppetlabs/puppet/ssl/certs/ca.pem.
3. Using the standby CA, retrieve all submitted standby CSR requests from
   either the inventory service or by collecting the exported resources and
   sign them.
4. Choose a method for triggering a rollover from the old CA to the new one.

The triggering process options are not yet implemented.

* Currently, setting the `install` parameter of the `rekey::agent` class to
  "true" will cause classified nodes to attempt to retrieve signed certificates
  for their CSRs from `puppet:///modules/rekey/var/${certname}.pem` and if
  successful, install and use the new key and certificate. 
* Currently, setting the `install` parameter of the `rekey::ca` class will
  cause the CA system to backup the old ssl directory and switch over to using
  the new one.
* There exists a stub MCollective agent in this module for implementing rekey
  rollover and rollback actions.
