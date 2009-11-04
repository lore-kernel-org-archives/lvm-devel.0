From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Nov 2009 14:47:29 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c tools/lvresize.c
Message-ID: <20091104144729.29830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-04 14:47:28

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c lvresize.c 

Log message:
	Fix lvcreate processing of %PVS argument.
	
	- fix missing unlocking of VG
	lvcreate -l 100%PVS -n lv1 vg_test
	Please specify physical volume(s) with %PVS
	Internal error: Volume Group vg_test was not unlocked
	
	- if no PVS specified, use all available
	
	Fix segfault if %PVS in lvresize without PVs list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1313&r2=1.1314
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.209&r2=1.210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2009/11/03 15:50:42	1.1313
+++ LVM2/WHATS_NEW	2009/11/04 14:47:27	1.1314
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Fix lvcreate and lvresize processing of %PVS argument.
   Tidy some uses of arg_count and introduce arg_is_set.
   Export outnl and indent functions for modules.
   Flush stdout after yes/no prompt.
--- LVM2/tools/lvcreate.c	2009/11/03 15:50:44	1.209
+++ LVM2/tools/lvcreate.c	2009/11/04 14:47:28	1.210
@@ -160,13 +160,12 @@
 			lp->extents = lp->extents * vg->free_count / 100;
 			break;
 		case PERCENT_PVS:
-			if (!lcp->pv_count) {
-				log_error("Please specify physical volume(s) "
-					  "with %%PVS");
-				return 0;
+			if (!lcp->pv_count)
+				lp->extents = lp->extents * vg->extent_count / 100;
+			else {
+				pv_extent_count = pv_list_extents_free(lp->pvh);
+				lp->extents = lp->extents * pv_extent_count / 100;
 			}
-			pv_extent_count = pv_list_extents_free(lp->pvh);
-			lp->extents = lp->extents * pv_extent_count / 100;
 			break;
 		case PERCENT_LV:
 			log_error("Please express size as %%VG, %%PVS, or "
@@ -584,15 +583,15 @@
 	}
 
 	if (!_update_extents_params(vg, &lp, &lcp)) {
-		stack;
-		return ECMD_FAILED;
+		r = ECMD_FAILED;
+		goto_out;
 	}
 
 	if (!lv_create_single(vg, &lp)) {
 		stack;
 		r = ECMD_FAILED;
 	}
-
+out:
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
--- LVM2/tools/lvresize.c	2009/11/03 15:50:44	1.115
+++ LVM2/tools/lvresize.c	2009/11/04 14:47:28	1.116
@@ -367,8 +367,11 @@
 			lp->extents = lp->extents * lv->le_count / 100;
 			break;
 		case PERCENT_PVS:
-			pv_extent_count = pv_list_extents_free(pvh);
-			lp->extents = lp->extents * pv_extent_count / 100;
+			if (lp->argc) {
+				pv_extent_count = pv_list_extents_free(pvh);
+				lp->extents = lp->extents * pv_extent_count / 100;
+			} else
+				lp->extents = lp->extents * vg->extent_count / 100;
 			break;
 		case PERCENT_NONE:
 			break;


