From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Nov 2009 16:08:50 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20091124160850.22066.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-24 16:08:49

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Return error status if vgchange fails to activate some volume.
	
	(on one node a storage connection failed):
	
	# vgchange -a y vg_bar ; echo $?
	Error locking on node bar-02: Refusing activation of partial LV lv1. Use --partial to override.
	1 logical volume(s) in volume group "vg_bar" now active
	0
	
	So activation fails on one node, error is correctly printed but
	status code is wrong.
	
	This patch fixes the top level (vgchange) to return proper code
	(and print # of activated LVs).
	
	(lvchange returns error properly here.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1322&r2=1.1323
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2009/11/23 10:55:14	1.1322
+++ LVM2/WHATS_NEW	2009/11/24 16:08:49	1.1323
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Return error status if vgchange fails to activate some volume.
   Fix memory lock imbalance in locking code.
   Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)
 
--- LVM2/tools/vgchange.c	2009/11/18 17:20:18	1.90
+++ LVM2/tools/vgchange.c	2009/11/24 16:08:49	1.91
@@ -56,7 +56,7 @@
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	int count = 0;
+	int count = 0, expected_count = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
@@ -78,6 +78,8 @@
 		    ((lv->status & PVMOVE) ))
 			continue;
 
+		expected_count++;
+
 		if (activate == CHANGE_AN) {
 			if (!deactivate_lv(cmd, lv))
 				continue;
@@ -100,7 +102,12 @@
 		count++;
 	}
 
-	return count;
+	if (expected_count)
+		log_verbose("%s %d logical volumes in volume group %s",
+			    activate ? "Activated" : "Deactivated",
+			    count, vg->name);
+
+	return (expected_count != count) ? ECMD_FAILED : ECMD_PROCESSED;
 }
 
 static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg)
@@ -121,7 +128,7 @@
 static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 {
 	int lv_open, active, monitored;
-	int available;
+	int available, ret;
 	int activate = 1;
 
 	/*
@@ -158,17 +165,11 @@
 		}
 	}
 
-	if (activate && _activate_lvs_in_vg(cmd, vg, available))
-		log_verbose("Activated logical volumes in "
-			    "volume group \"%s\"", vg->name);
-
-	if (!activate && _activate_lvs_in_vg(cmd, vg, available))
-		log_verbose("Deactivated logical volumes in "
-			    "volume group \"%s\"", vg->name);
+	ret = _activate_lvs_in_vg(cmd, vg, available);
 
 	log_print("%d logical volume(s) in volume group \"%s\" now active",
 		  lvs_in_vg_activated(vg), vg->name);
-	return ECMD_PROCESSED;
+	return ret;
 }
 
 static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)


