From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 04 Sep 2013 15:23:00 -0500
Subject: lvm2app and handle modifications during error conditions
Message-ID: <522796A4.1010807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

While working on a VG reduce bug in lvm2app it became very apparent that
in general when a user of a library runs into an error condition that
they should discard whatever VG/PV/LV handle they passed in to the call
and fetch a new one.  This is because the code base modifies the
structures during processing and if we fail we don't restore them.
Sometimes the structures are modified before we are even done checking
preconditions.  This isn't a problem when running as a command line as
when we exit all in flight changes are lost.

Does anyone have a simple solution to address this or is the best we can
do is educate library users with some updated documentation?

Thanks,
Tony


