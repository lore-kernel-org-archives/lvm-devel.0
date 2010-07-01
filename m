From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 1 Jul 2010 10:10:52 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100701101052.19929.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-07-01 10:10:52

Modified files:
	tools          : lvconvert.c 

Log message:
	Restore the "removemissing" behaviour of lvconvert --repair --use-policies.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/tools/lvconvert.c	2010/06/23 20:32:29	1.135
+++ LVM2/tools/lvconvert.c	2010/07/01 10:10:52	1.136
@@ -790,7 +790,6 @@
 			stack;
 			return;
 		}
-
 		log_warn("%d missing and now unallocated Physical Volumes removed from VG.", removed);
 	}
 }
@@ -1177,7 +1176,6 @@
 	int replace_log = 0;
 	int replace_mirrors = 0;
 	uint32_t new_log_count, log_count;
-	struct dm_list *failed_pvs = NULL;
 	struct logical_volume *log_lv;
 
 	cmd->handles_missing_pvs = 1;
@@ -1232,14 +1230,14 @@
 	/*
 	 * First phase - remove faulty devices
 	 */
-	if (!(failed_pvs = _failed_pv_list(lv->vg)))
+	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))
 		return_0;
 
 	/*
 	 * We must adjust the log first, or the entire mirror
 	 * will get stuck during a suspend.
 	 */
-	if (!_lv_update_mirrored_log(lv, failed_pvs, new_log_count))
+	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, new_log_count))
 		return 0;
 
 	if (lp->mirrors == 1)
@@ -1252,7 +1250,7 @@
 			return 0;
 	}
 
-	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs,
+	if (!_lv_update_log_type(cmd, lp, lv, lp->failed_pvs,
 				 new_log_count))
 		return 0;
 


