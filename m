From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Oct 2009 01:24:18 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20091023012418.20664.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-23 01:24:17

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Cleanup mimagetmp LV if allocation fails for new lvconvert mimage.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1301&r2=1.1302
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2009/10/22 17:45:23	1.1301
+++ LVM2/WHATS_NEW	2009/10/23 01:24:17	1.1302
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Cleanup mimagetmp LV if allocation fails for new lvconvert mimage.
   Fix clvmd segfault when refresh_toolcontext fails.
   Remember to clear 'global lock held during cache refresh' state after use.
   Use udev flags support in LVM.
--- LVM2/tools/lvconvert.c	2009/10/21 22:19:39	1.94
+++ LVM2/tools/lvconvert.c	2009/10/23 01:24:17	1.95
@@ -532,7 +532,7 @@
 	const char *mirrorlog;
 	unsigned corelog = 0;
 	int r = 0;
-	struct logical_volume *log_lv;
+	struct logical_volume *log_lv, *layer_lv;
 	int failed_mirrors = 0, failed_log = 0;
 	struct dm_list *old_pvh = NULL, *remove_pvs = NULL;
 
@@ -733,8 +733,21 @@
 						lv->le_count,
 						lp->region_size),
 				    0U, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV))
+				    MIRROR_BY_LV)) {
+			layer_lv = seg_lv(first_seg(lv), 0);
+			if (!remove_layer_from_lv(lv, layer_lv) ||
+			    !deactivate_lv(cmd, layer_lv) ||
+			    !lv_remove(layer_lv) || !vg_write(lv->vg) ||
+			    !vg_commit(lv->vg)) {
+				log_error("ABORTING: Failed to remove "
+					  "temporary mirror layer %s.",
+					  layer_lv->name);
+				log_error("Manual cleanup with vgcfgrestore "
+					  "and dmsetup may be required.");
+				return 0;
+			}
 			return_0;
+		}
 		lv->status |= CONVERTING;
 		lp->need_polling = 1;
 	}


