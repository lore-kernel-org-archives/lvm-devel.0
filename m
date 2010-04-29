From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2010 01:45:31 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100429014531.26059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-29 01:45:30

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1541&r2=1.1542

--- LVM2/WHATS_NEW	2010/04/29 01:38:12	1.1541
+++ LVM2/WHATS_NEW	2010/04/29 01:45:30	1.1542
@@ -2,7 +2,6 @@
 =================================
   Remove no-longer-used arg_ptr_value.
   Fix -M and --type to use strings not pointers that change on config refresh.
-  Fix regression in down-convert of mirror images with partial PV specification.
   Fix lvconvert error message when existing mirrored LV is not found.
   Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
@@ -11,10 +10,10 @@
   Disallow primary mirror image removal when mirror is not in-sync.
   Remove obsolete --name parameter from vgcfgrestore.
   Add -S command to clvmd to restart the daemon preserving exclusive locks.
-  Increment lvm2app version from 1 to 2.
+  Increment lvm2app version from 1 to 2 (memory allocation changes).
   Change lvm2app memory alloc/free for pv/vg/lv properties.
   Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.
-  Added awk script relpath.awk to calculate relative paths.
+  Add awk script relpath.awk to calculate paths for relative symlinks.
   Fix double DESTDIR usage for infodir and mandir.
   Install symbolic .so links with relative paths between usrlibdir and libdir.
 


