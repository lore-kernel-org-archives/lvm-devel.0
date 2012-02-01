From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Feb 2012 13:47:28 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120201134728.22038.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-01 13:47:27

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Disable partial activation for thin LVs and LVs with all missing segments
	
	Count number of error and existing areas and if there is no existing area
	for the LV avoid its activation.
	
	Always disable partial activatio for thin volumes.
	
	For mirrors currently put in hack to let it pass with a special name
	since current mirror code needs to activate such LV during some operations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2252&r2=1.2253
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.269&r2=1.270

--- LVM2/WHATS_NEW	2012/02/01 13:42:18	1.2252
+++ LVM2/WHATS_NEW	2012/02/01 13:47:27	1.2253
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Disable partial activation for thin LVs and LVs with all missing segments.
   Do not print warning for pv_min_size set in range between 512KB and 2MB.
   Clean up systemd unit ordering and requirements.
   Fix lcov reports when srcdir != builddir.
--- LVM2/lib/activate/dev_manager.c	2012/01/28 20:12:29	1.269
+++ LVM2/lib/activate/dev_manager.c	2012/02/01 13:47:27	1.270
@@ -1373,6 +1373,8 @@
 	char *dlid;
 	struct stat info;
 	const char *name;
+	unsigned num_error_areas = 0;
+	unsigned num_existing_areas = 0;
 
 	/* FIXME Avoid repeating identical stat in dm_tree_node_add_target_area */
 	for (s = start_area; s < areas; s++) {
@@ -1388,10 +1390,12 @@
 			}
 			if (!_add_error_area(dm, node, seg, s))
 				return_0;
+			num_error_areas++;
 		} else if (seg_type(seg, s) == AREA_PV) {
 			if (!dm_tree_node_add_target_area(node, dev_name(seg_dev(seg, s)), NULL,
 				    (seg_pv(seg, s)->pe_start + (extent_size * seg_pe(seg, s)))))
 				return_0;
+			num_existing_areas++;
 		} else if (seg_is_raid(seg)) {
 			/*
 			 * RAID can handle unassigned areas.  It simple puts
@@ -1436,6 +1440,28 @@
 		}
 	}
 
+        if (num_error_areas) {
+		/* Thins currently do not support partial activation */
+		if (lv_is_thin_type(seg->lv)) {
+			log_error("Cannot activate %s%s: pool incomplete.",
+				  seg->lv->vg->name, seg->lv->name);
+			return 0;
+		}
+
+		/*
+		 * Mirrors activate LVs replaced with error targets
+		 *
+		 * TODO: Can we eventually skip to activate such LVs ?
+		 */
+		if (!num_existing_areas &&
+		    !strstr(seg->lv->name, "_mimage_") &&
+		    !((name = strstr(seg->lv->name, "_mlog")) && !name[5])) {
+			log_error("Cannot activate %s/%s: all segments missing.",
+				  seg->lv->vg->name, seg->lv->name);
+			return 0;
+		}
+	}
+
 	return 1;
 }
 


