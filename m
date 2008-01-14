From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Jan 2008 21:11:47 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20080114211147.9451.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-14 21:11:47

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	lvconvert waits for initial completion by default

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.758&r2=1.759
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2008/01/11 07:02:34	1.758
+++ LVM2/WHATS_NEW	2008/01/14 21:11:47	1.759
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  lvconvert waits for completion of initial sync by default.
   Refactor vgcreate for parameter validation and add tests.
   Add new convert_lv field to lvs output.
   Print warning when lvm tools are running as non-root.
--- LVM2/tools/lvconvert.c	2008/01/10 18:35:51	1.53
+++ LVM2/tools/lvconvert.c	2008/01/14 21:11:47	1.54
@@ -24,7 +24,8 @@
 	const char *lv_name;
 	const char *lv_name_full;
 	const char *vg_name;
-	int wait_daemon;
+	int wait_completion;
+	int need_polling;
 
 	uint32_t chunk_size;
 	uint32_t region_size;
@@ -116,6 +117,9 @@
 		return 0;
 	}
 
+	if (!arg_count(cmd, background_ARG))
+		lp->wait_completion = 1;
+
 	if (arg_count(cmd, snapshot_ARG))
 		lp->snapshot = 1;
 
@@ -374,7 +378,7 @@
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG)) {
-		lp->wait_daemon = 1;
+		lp->need_polling = 1;
 		return 1;
 	}
 
@@ -476,6 +480,8 @@
 				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV))
 			return_0;
+		if (lp->wait_completion)
+			lp->need_polling = 1;
 		goto commit_changes;
 	}
 
@@ -549,7 +555,7 @@
 				    MIRROR_BY_LV))
 			return_0;
 		lv->status |= CONVERTING;
-		lp->wait_daemon = 1;
+		lp->need_polling = 1;
 	} else {
 		/* Reduce number of mirrors */
 		if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
@@ -584,7 +590,7 @@
 		return 0;
 	}
 
-	if (!lp->wait_daemon)
+	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
 	return 1;
@@ -740,13 +746,13 @@
 error:
 	unlock_vg(cmd, lp.vg_name);
 
-	if (ret == ECMD_PROCESSED && lp.wait_daemon) {
+	if (ret == ECMD_PROCESSED && lp.need_polling) {
 		if (!lv_info(cmd, lvl->lv, &info, 1, 0) || !info.exists) {
 			log_print("Conversion starts after activation");
 			return ret;
 		}
 		ret = lvconvert_poll(cmd, lp.lv_name_full,
-				     arg_count(cmd, background_ARG) ? 1U : 0);
+				     lp.wait_completion ? 0 : 1U);
 	}
 
 	return ret;


