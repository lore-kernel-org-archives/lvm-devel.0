From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 03:50:01 -0400
Subject: [PATCH 0/7]: Implement lvm_vg_create() and 4 required vg_set*() APIs
Message-ID: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following 7 patches implement the beginning of lvm_vg_create() liblvm API.
This API will create a VG with default parameters and return a vg_t.  Later,
if any parameters of the VG need set, they are done with a separate 'set' call.
This is the approach that was discussed for liblvm, and required some refactoring
of the code, including vgcreate and vgsplit.  The reason for the refactoring of
vgcreate and vgsplit is that the existing vg_create() constructor did not
take this approach, but rather took input parameters such as extent_size, max_pv,
max_lv, etc.  Thus, to implement what was decided, I had to pull out all the
validity checks into a separate 'set' function.

In addition, lvm_vg_create() now takes the place of vg_lock_newname() in both
vgcreate and vgsplit.  I believe that down the road we may not have to export
vg_lock_newname() but can use lvm_vg_create() for the existence check, and as
a complement to the vg_read() APIs.  The only remaining use of vg_lock_newname()
is in vgrename, and this use can be hidden inside a vgrename API.

Note that in a few cases, for the 'set' functions, the return codes have been
modified slightly.  The cases are things like EINVALID_CMD_LINE becomes
ECMD_FAILED, and setting the same value returning SUCCESS or FAILURE (this
was inconsistent in the code - sometimes it was an error, sometimes it was
success - I made it always a success).

Passes the testsuite, and should apply cleanly on:
commit ea47a922568e19202ac365b5eb00bf55b4b6d8a2
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Mon Jul 6 21:42:25 2009 -0400

    Fix compile warning in lvmcmdline.c - use C99 PRIu64 for uint64_t.


