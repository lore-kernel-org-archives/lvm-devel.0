From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 09 Jul 2010 11:04:04 +0200
Subject: [PATCH] pid files cleanup
Message-ID: <4C36E604.6090106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

as previously discussed, the patch:

- adds a generic create_lockfile fn to lvm-file.{c,h}. Based on
multipathd/pidfile.c
- adds --clvmd-pidfile configure option (autoreconf on F-12)
- make clvmd use the new create_lockfile
- make cmirrord use the new create_lockfile and drop duplicate code
- unlink pidfiles on exit (note that because of the atexit() behavior
this has to be done locally in the daemon and cannot be generalized in
the library).

NOTES:

- I had some issues to build dmeventd that I need to investigate
locally. dmeventd also needs to be ported (if possible) to use the
library implementation of create_lockfile().

- create_lockfile can probably use fcntl_lock_file, but I am not
entirely sure about its behavior yet (specially the waiting note in the
header), so I choose a safe path for now and use a known (to me)
implementation.

- WHATS_NEW will be updated once patch is ACK.

Thanks
Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: pid_files.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100709/b8252385/attachment.ksh>
