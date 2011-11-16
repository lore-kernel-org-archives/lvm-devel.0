From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:48 +0100
Subject: [PATCH 01/12] Allow to activate snapshot
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <a74ac6f477b6bda487acfc6a9c2535ed09224df9.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add extra code to active and deactivate related
snapshots and origin when user specifies snapshot
volume as lvchange parameter.

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
snapshot(s)? [y/n]: n
  Can't change snapshot logical volume "lvol2".

$> lvchange -y -an mvg/lvol2; echo $?
0

$> lvs -a
  LV    VG   Attr     LSize  Pool Origin Snap%  Move Log Copy%  Convert
  lvol0 mvg  owi---s-  1.00k
  lvol1 mvg  swi---s- 16.00k      lvol0
  lvol2 mvg  swi---s- 16.00k      lvol0

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvchange.c |   28 +++++++++++++++++++++++-----
 1 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6cb9185..2cd4ba3 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -125,6 +125,9 @@ static int lvchange_availability(struct cmd_context *cmd,
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
+	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
+		lv = origin_from_cow(lv);
+
 	if (activate == CHANGE_ALN) {
 		log_verbose("Deactivating logical volume \"%s\" locally",
 			    lv->name);
@@ -515,6 +518,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int doit = 0, docmds = 0;
 	int dmeventd_mode, archived = 0;
 	struct logical_volume *origin;
+	char snaps_msg[128];
 
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
@@ -534,11 +538,25 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
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
+		    (yes_no_prompt("Change of snapshot %s will also change its "
+				   "origin %s%s? [y/n]: ", lv->name,
+				   origin->name, snaps_msg) == 'n')) {
+			log_error("Can't change snapshot logical volume \"%s\".",
+				  lv->name);
+			return ECMD_FAILED;
+		}
 	}
 
 	if (lv->status & PVMOVE) {
-- 
1.7.7.3


