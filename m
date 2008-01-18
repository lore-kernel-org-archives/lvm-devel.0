From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2008 22:02:37 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20080118220237.24572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-18 22:02:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h mirror.c 
	tools          : lvcreate.c 

Log message:
	Fix lvcreate --nosync not to wait for non-happening sync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.769&r2=1.770
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170

--- LVM2/WHATS_NEW	2008/01/18 22:00:46	1.769
+++ LVM2/WHATS_NEW	2008/01/18 22:02:37	1.770
@@ -1,5 +1,6 @@
 Version 2.02.31 -
 ===================================
+  Fix lvcreate --nosync not to wait for non-happening sync. (2.02.30)
   Add very_verbose lvconvert messages.
   Avoid error message when using default setting of lvcreate -M1. (2.02.30)
 
--- LVM2/lib/metadata/metadata-exported.h	2008/01/17 17:17:09	1.40
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/18 22:02:37	1.41
@@ -95,6 +95,7 @@
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
+#define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
--- LVM2/lib/metadata/mirror.c	2008/01/18 22:00:46	1.64
+++ LVM2/lib/metadata/mirror.c	2008/01/18 22:02:37	1.65
@@ -1356,8 +1356,8 @@
 	 * create and initialize mirror log
 	 */
 	if (log_count &&
-	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
-					  region_size, alloc, 0)))
+	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
+					  alloc, mirror_in_sync())))
 		return_0;
 
 	/* The log initialization involves vg metadata commit.
@@ -1427,7 +1427,10 @@
 	 * the global mirror_in_sync status. As we are adding
 	 * a new mirror, it should be set as 'out-of-sync'
 	 * so that the sync starts. */
-	if (!log_count)
+	/* However, MIRROR_SKIP_INIT_SYNC even overrides it. */
+	if (flags & MIRROR_SKIP_INIT_SYNC)
+		init_mirror_in_sync(1);
+	else if (!log_count)
 		init_mirror_in_sync(0);
 
 	if (flags & MIRROR_BY_SEG) {
--- LVM2/tools/lvcreate.c	2008/01/18 21:56:39	1.169
+++ LVM2/tools/lvcreate.c	2008/01/18 22:02:37	1.170
@@ -789,7 +789,8 @@
 						lv->le_count,
 						lp->region_size),
 				    lp->corelog ? 0U : 1U, pvh, lp->alloc,
-				    MIRROR_BY_LV)) {
+				    MIRROR_BY_LV |
+				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
 			stack;
 			goto revert_new_lv;
 		}


