From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jan 2010 23:55:18 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100121235518.11190.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-21 23:55:17

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.221&r2=1.222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1399&r2=1.1400
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.338&r2=1.339

--- LVM2/VERSION	2010/01/14 14:42:06	1.221
+++ LVM2/VERSION	2010/01/21 23:55:17	1.222
@@ -1 +1 @@
-2.02.59(1)-cvs (2010-01-14)
+2.02.59(1)-cvs (2010-01-21)
--- LVM2/VERSION_DM	2010/01/14 14:42:06	1.33
+++ LVM2/VERSION_DM	2010/01/21 23:55:17	1.34
@@ -1 +1 @@
-1.02.43-cvs (2010-01-14)
+1.02.43-cvs (2010-01-21)
--- LVM2/WHATS_NEW	2010/01/21 22:15:45	1.1399
+++ LVM2/WHATS_NEW	2010/01/21 23:55:17	1.1400
@@ -1,17 +1,23 @@
-Version 2.02.59 - 
+Version 2.02.59 - 21st January 2010
 ===================================
   Add libdevmapper-event-lvm2.so to serialise dmeventd plugin liblvm2cmd use.
   Cleanup memory initialization and freeing in pv_read() and pv_create().
   Clear pointer and counters after their release in _fin_commands().
+  Stop dmeventd trying to access already-removed snapshots.
+  Remove (fallback) /dev mknod from cmirrord.
   Add t-topology-support.sh and t-snapshot-merge.sh tests.
   Fix clvmd to never scan suspended devices.
-  Initial version of the cmirror init script (Red Hat).
-  Initial version of the cmirrord man page.
+  Fix dmeventd build outside source tree.
+  Assorted cmirror code changes to remove various compiler warnings.
+  Fix detection of completed snapshot merge.
+  Add Red Hat cmirror initscript (unfinished).
+  Add cmirrord man page (incomplete).
   Make cluster log communication structures architecture independant.
-  Fix cluster log issues with in-memory bitmaps.
+  Fix cluster log in-memory bitmap handling.
+  Improve snapshot merge metadata import validation.
   Improve target type compatibility checking in _percent_run().
   Add 'target_status_compatible' method to 'struct segtype_handler'.
-  Fix difference between CTR table built and expected for cluster log.
+  Change underscore to hyphen in table line for clustered log type.
 
 Version 2.02.58 - 14th January 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/01/15 16:18:14	1.338
+++ LVM2/WHATS_NEW_DM	2010/01/21 23:55:17	1.339
@@ -1,5 +1,6 @@
-Version 1.02.43 - 
+Version 1.02.43 - 21st January 2010
 ===================================
+  Remove bitset, hash and pool headers superceded by libdevmapper.h.
   Fix off-by-one error causing bad cluster mirror table construction.
 
 Version 1.02.42 - 14th January 2010


