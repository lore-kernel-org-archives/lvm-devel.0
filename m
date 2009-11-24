From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Nov 2009 18:54:24 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20091124185424.13606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-24 18:54:23

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1328&r2=1.1329

--- LVM2/WHATS_NEW	2009/11/24 18:26:08	1.1328
+++ LVM2/WHATS_NEW	2009/11/24 18:54:23	1.1329
@@ -2,11 +2,11 @@
 ====================================
   Add missing vg_release to pvs and pvdisplay to fix memory leak.
   Do not try to unlock VG which is not locked in _process_one_vg.
-  Move persistent filter dump to more appropriate place.
+  Move is_long_lived persistent_filter_dump to happen after every full scan.
   Refresh device filters before full device rescan in lvmcache.
   Return error status if vgchange fails to activate some volume.
-  Fix memory lock imbalance in locking code.
-  Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)
+  Fix suspend/resume lock type test causing unbalanced memory locking.
+  Revert vg_read_internal change as clvmd was not ready for vg_read. (2.02.55)
 
 Version 2.02.55 - 19th November 2009
 ====================================


