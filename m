From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:22:50 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20111118192250.16354.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:22:49

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Allow to activate snapshot
	
	Add extra code to active and deactivate related
	snapshots and origin when user specifies snapshot
	logical volume as lvchange parameter.
	
	Before patch:
	
	$> lvs -a
	LV    VG   Attr     LSize  Pool Origin Snap%  Move Log Copy%  Convert
	lvol0 mvg  owi-a-s-  1.00k
	lvol1 mvg  swi-a-s- 16.00k      lvol0    0.00
	lvol2 mvg  swi-a-s- 16.00k      lvol0    0.00
	
	$> lvchange -an mvg/lvol2; echo $?
	Can't change snapshot logical volume "lvol2".
	5
	
	After patch:
	
	$> lvchange -an mvg/lvol2
	Change of snapshot lvol2 will also change its origin lvol0 and 1 other
	snapshot(s). Proceed? [y/n]: n
	Logical volume lvol2 not changed.
	
	$> lvchange -y -an mvg/lvol2; echo $?
	0
	
	$> lvs -a
	LV    VG   Attr     LSize  Pool Origin Snap%  Move Log Copy%  Convert
	lvol0 mvg  owi---s-  1.00k
	lvol1 mvg  swi---s- 16.00k      lvol0
	lvol2 mvg  swi---s- 16.00k      lvol0

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2187&r2=1.2188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/WHATS_NEW	2011/11/18 19:19:22	1.2187
+++ LVM2/WHATS_NEW	2011/11/18 19:22:49	1.2188
@@ -1,6 +1,7 @@
 Version 2.02.89 - 
 ==================================
-  Skip non-virtual origins for availability change for lvchange.
+  Allow changing availability state of snapshots.
+  Skip non-virtual snapshots for availability change for lvchange with vg name.
   Adjusted mirror region size only for mirrors and raids.
   Reorder prompt conditions for removal of active volumes.
   Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
--- LVM2/tools/lvchange.c	2011/11/03 14:59:20	1.135
+++ LVM2/tools/lvchange.c	2011/11/18 19:22:49	1.136
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -125,6 +125,9 @@
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
+	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
+		lv = origin_from_cow(lv);
+
 	if (activate == CHANGE_ALN) {
 		log_verbose("Deactivating logical volume \"%s\" locally",
 			    lv->name);
@@ -515,6 +518,7 @@
 	int doit = 0, docmds = 0;
 	int dmeventd_mode, archived = 0;
 	struct logical_volume *origin;
+	char snaps_msg[128];
 
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
@@ -534,11 +538,24 @@
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)) &&
+	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin = origin_from_cow(lv)) &&
 	    arg_count(cmd, available_ARG)) {
-		log_error("Can't change snapshot logical volume \"%s\"",
-			  lv->name);
-		return ECMD_FAILED;
+		if (origin->origin_count < 2)
+			snaps_msg[0] = '\0';
+		else if (dm_snprintf(snaps_msg, sizeof(snaps_msg),
+				     " and %u other snapshot(s)",
+				     origin->origin_count - 1) < 0) {
+			log_error("Failed to prepare message.");
+			return ECMD_FAILED;
+		}
+
+		if (!arg_count(cmd, yes_ARG) &&
+		    (yes_no_prompt("Change of snapshot %s will also change its"
+				   " origin %s%s. Proceed? [y/n]: ", lv->name,
+				   origin->name, snaps_msg) == 'n')) {
+			log_error("Logical volume %s not changed.", lv->name);
+			return ECMD_FAILED;
+		}
 	}
 
 	if (lv->status & PVMOVE) {


