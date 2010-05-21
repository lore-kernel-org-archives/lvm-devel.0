From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 14:34:03 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20100521143403.30825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 14:34:02

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Replicator: activate checks for missing vgs
	
	Activation needs to have all remote VGs locked to pass for replicator.
	So if activated LV is replicator-dev LV - read all remote VGs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1588&r2=1.1589
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/WHATS_NEW	2010/05/21 14:29:49	1.1588
+++ LVM2/WHATS_NEW	2010/05/21 14:34:01	1.1589
@@ -1,6 +1,7 @@
 Version 2.02.67 -
 ===============================
-  Check for missing VGs before taking lock_lv_vol (for Replicator).
+  Activation code read and releases also remote VGs (Replicator).
+  Check for missing VGs before taking lock_vol (Replicator).
   Update process_each_lv_in_vg() to use cmd_vg structure.
   Update _process_one_vg() to work with cmd_vg structure.
   Add functions for read and release VGs list.
--- LVM2/lib/activate/activate.c	2010/03/26 22:15:43	1.168
+++ LVM2/lib/activate/activate.c	2010/05/21 14:34:02	1.169
@@ -865,6 +865,9 @@
 		goto out;
 	}
 
+	if (!lv_read_replicator_vgs(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	/* If VG was precommitted, preload devices for the LV */
@@ -894,8 +897,10 @@
 out:
 	if (lv_pre)
 		vg_release(lv_pre->vg);
-	if (lv)
+	if (lv) {
+		lv_release_replicator_vgs(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }
@@ -1025,6 +1030,9 @@
 			goto_out;
 	}
 
+	if (!lv_read_replicator_vgs(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (!monitor_dev_for_events(cmd, lv, 0))
@@ -1038,8 +1046,10 @@
 	if (!lv_info(cmd, lv, &info, 1, 0) || info.exists)
 		r = 0;
 out:
-	if (lv)
+	if (lv) {
+		lv_release_replicator_vgs(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }
@@ -1118,6 +1128,9 @@
 		goto out;
 	}
 
+	if (!lv_read_replicator_vgs(lv))
+		goto_out;
+
 	lv_calculate_readahead(lv, NULL);
 
 	if (exclusive)
@@ -1133,8 +1146,10 @@
 		stack;
 
 out:
-	if (lv)
+	if (lv) {
+		lv_release_replicator_vgs(lv);
 		vg_release(lv->vg);
+	}
 
 	return r;
 }


