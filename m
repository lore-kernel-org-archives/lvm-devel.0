From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Apr 2009 10:20:29 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20090407102029.22429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-07 10:20:29

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 

Log message:
	Fix memory pool leak.
	
	Call the alloc_destory call always after finishing operation
	with handle otherwise it will leak a memory pool.
	
	Also fix return code in lv_extend.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1076&r2=1.1077
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/WHATS_NEW	2009/04/02 21:34:41	1.1076
+++ LVM2/WHATS_NEW	2009/04/07 10:20:28	1.1077
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix memory leak in mirror allocation code.
   Save and restore the previous logging level when log level is changed.
   Fix error message when archive initialization fails.
   Make sure clvmd-corosync releases the lockspace when it exits.
--- LVM2/lib/metadata/lv_manip.c	2009/03/26 09:25:18	1.164
+++ LVM2/lib/metadata/lv_manip.c	2009/04/07 10:20:29	1.165
@@ -1608,16 +1608,12 @@
 				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (mirrors < 2) {
-		if (!lv_add_segment(ah, 0, ah->area_count, lv, segtype, stripe_size,
-			    status, 0, NULL))
-			goto_out;
-	} else {
-		if (!_lv_extend_mirror(ah, lv, extents, 0))
-			return_0;
-	}
+	if (mirrors < 2)
+		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
+				   stripe_size, status, 0, NULL);
+	else
+		r = _lv_extend_mirror(ah, lv, extents, 0);
 
-      out:
 	alloc_destroy(ah);
 	return r;
 }
--- LVM2/lib/metadata/mirror.c	2009/02/28 20:04:24	1.81
+++ LVM2/lib/metadata/mirror.c	2009/04/07 10:20:29	1.82
@@ -1160,6 +1160,7 @@
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
 	uint32_t adjusted_region_size;
+	int r = 1;
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 		return_0;
@@ -1180,10 +1181,11 @@
 
 	if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
 		log_error("Failed to add mirror areas to %s", lv->name);
-		return 0;
+		r = 0;
 	}
 
-	return 1;
+	alloc_destroy(ah);
+	return r;
 }
 
 /*
@@ -1349,6 +1351,7 @@
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
+	int r = 0;
 
 	/* Unimplemented features */
 	if (log_count > 1) {
@@ -1404,13 +1407,15 @@
 
 	if (!(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
 					  region_size, alloc, in_sync)))
-		return_0;
+		goto_out;
 
 	if (!attach_mirror_log(first_seg(lv), log_lv))
-		return_0;
+		goto_out;
 
+	r = 1;
+out:
 	alloc_destroy(ah);
-	return 1;
+	return r;
 }
 
 /*
@@ -1455,8 +1460,10 @@
 	 */
 	if (log_count &&
 	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
-					  alloc, mirror_in_sync())))
-		return_0;
+					  alloc, mirror_in_sync()))) {
+		stack;
+		goto out_remove_imgs;
+	}
 
 	/* The log initialization involves vg metadata commit.
 	   So from here on, if failure occurs, the log must be explicitly
@@ -1503,6 +1510,7 @@
 			  "abandoned log LV before retrying.");
 
   out_remove_imgs:
+	alloc_destroy(ah);
 	return 0;
 }
 


