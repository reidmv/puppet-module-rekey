metadata :name        => "rekey",
         :description => "Puppet Re-key trigger",
         :author      => "Reid Vandewiele",
         :license     => "Commercial",
         :version     => "1.0",
         :url         => "http://puppetlabs.com",
         :timeout     => 60

action "rollover", :description => "Activate new pending keys" do
   output :msg,
          :description => "The message we received",
          :display_as  => "Message"
end

action "rollback", :description => "Roll back to the pre-rollover keys" do
   output :msg,
          :description => "The message we received",
          :display_as  => "Message"
end
