From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 10 Feb 2015 16:01:08 -0600
Subject: Suggested changes to lvm command line tools
Message-ID: <54DA7FA4.9060404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following changes would be helpful for projects that are writing
wrappers for the lvm command line tools.

* Have an option to output JSON or XML for all operations
* When creating/modifying something, if it is successful, output all the
information about the newly created/modified object so that the user
doesn't need to turn around and query what they just created/changed.
Optionally if the change causes other objects in the system to change,
output those objects too if possible.  Otherwise the client needs to
'know' what side effects a change has and then query those affected
objects.  Not sure how easy or feasible this change would be.
* A mechanism for a client to know that a change has been made without
having to poll for changes.  For a lvm dbus daemon we could provide a
dbus method that can be used to signal the daemon that one or more
things have changed.

Thanks!

Regards,
Tony


