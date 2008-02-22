From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Feb 2008 13:22:24 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20080222132224.10323.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-22 13:22:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Add missing no-longer-used segs_using_this_lv test to check_lv_segments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.795&r2=1.796
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/WHATS_NEW	2008/02/15 14:12:32	1.795
+++ LVM2/WHATS_NEW	2008/02/22 13:22:19	1.796
@@ -1,17 +1,18 @@
 Version 2.02.34 -
 ===================================
-  Remove redundant if-before-free tests in clvmd.c.
-  Avoid a compiler warning: make is_orphan's parameter "const".
+  Add missing no-longer-used segs_using_this_lv test to check_lv_segments.
+  Remove redundant non-NULL tests before calling free in clvmd.c.
+  Avoid a compiler warning: make is_orphan's parameter const.
   Fix lvconvert detection of mirror conversion in progress. (2.02.30)
   Avoid automatic lvconvert polldaemon invocation when -R specified. (2.02.30)
   Fix 'pvs -a' to detect VGs of PVs without metadata areas.
   Divide up internal orphan volume group by format type.
   Update usage message for clvmd.
-  Fix clvmd man page printing <br>, clarified debug options.
-  Fix lvresize to support /dev/mapper prefix in the lvname
-  Fix unfilled paramater passed to fsadm from lvresize
-  Update fsadm to call lvresize if the partition size differs (with option -l)
-  Fix fsadm to support vg/lv name (like the rest of lv-tools)
+  Fix clvmd man page not to print <br> and clarified debug options.
+  Fix lvresize to support /dev/mapper prefix in the LV name.
+  Fix unfilled parameter passed to fsadm from lvresize.
+  Update fsadm to call lvresize if the partition size differs (with option -l).
+  Fix fsadm to support VG/LV names.
 
 Version 2.02.33 - 31st January 2008
 ===================================
--- LVM2/lib/metadata/lv_manip.c	2008/01/30 14:17:29	1.150
+++ LVM2/lib/metadata/lv_manip.c	2008/02/22 13:22:21	1.151
@@ -2308,6 +2308,9 @@
 	    parent->le_count != layer_lv->le_count)
 		return_0;
 
+	if (!lv_empty(parent))
+		return_0;
+
 	if (!_move_lv_segments(parent, layer_lv, 0, 0))
 		return_0;
 


