From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 02 Dec 2013 16:48:57 -0600
Subject: lvm and umask changing
Message-ID: <529D0E59.2030106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

https://bugzilla.redhat.com/show_bug.cgi?id=1012113

The yum snapshot plug-in is using the python lvm bindings and by
importing it the umask is getting changed to whatever is specified in
the lvm config file (default 0077).  This was causing mock to fail, but
at the moment it appears to be working even though the umask continues
to be changed.

IMO changing the umask on a user of the library is a bad thing to do,
but I wanted to get folks input this?

I would think we should be able to adhere to the users umask preferences
when needed and not leave the environment globally changed.

Regards,
Tony


