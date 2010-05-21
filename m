From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 14:15:39 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20100521141539.20115.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 14:15:39

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Replicator: use cmd_vg for process_each_lv_in_vg()
	
	As for _process_one_vg() we need similar retry loop for
	process_each_lv_in_vg(). This patch retries to process
	failed LVs with reopened VGs.
	
	Patch does not add any extra repeated invocations if there is not
	found any missing VG during LV processing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1586&r2=1.1587
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201

--- LVM2/WHATS_NEW	2010/05/21 14:11:13	1.1586
+++ LVM2/WHATS_NEW	2010/05/21 14:15:39	1.1587
@@ -1,6 +1,7 @@
 Version 2.02.67 -
 ===============================
-  Update _process_one_vg() to work with cmd_vg struture.
+  Update process_each_lv_in_vg() to use cmd_vg structure.
+  Update _process_one_vg() to work with cmd_vg structure.
   Add functions for read and release VGs list.
   Add find_replicator_vgs() to discover all needed VGs for replicator-dev LV.
   Add functions for handling cmd_vg structure.
--- LVM2/tools/toollib.c	2010/05/21 14:11:13	1.200
+++ LVM2/tools/toollib.c	2010/05/21 14:15:39	1.201
@@ -155,6 +155,7 @@
 		if (!process_lv)
 			continue;
 
+		lvl->lv->vg->cmd_missing_vgs = 0;
 		ret = process_single_lv(cmd, lvl->lv, handle);
 		if (ret != ECMD_PROCESSED && failed_lvnames) {
 			lv_name = dm_pool_strdup(cmd->mem, lvl->lv->name);
@@ -163,6 +164,8 @@
 				log_error("Allocation failed for str_list.");
 				return ECMD_FAILED;
 			}
+			if (lvl->lv->vg->cmd_missing_vgs)
+				ret = ECMD_PROCESSED;
 		}
 		if (ret > ret_max)
 			ret_max = ret;
@@ -190,7 +193,9 @@
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
 	struct str_list *sll, *strl;
-	struct volume_group *vg;
+	struct cmd_vg *cvl_vg;
+	struct dm_list cmd_vgs;
+	struct dm_list failed_lvnames;
 	struct dm_list tags, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
 	char *vglv;
@@ -200,6 +205,7 @@
 
 	dm_list_init(&tags);
 	dm_list_init(&arg_lvnames);
+	dm_list_init(&failed_lvnames);
 
 	if (argc) {
 		struct dm_list arg_vgnames;
@@ -295,13 +301,17 @@
 		}
 	}
 
-	vg = NULL;
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		vg = vg_read(cmd, vgname, NULL, flags);
+		dm_list_init(&cmd_vgs);
+		if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs,
+					  vgname, NULL, flags))) {
+			stack;
+			return ECMD_FAILED;
+		}
 
-		if (vg_read_error(vg)) {
-			vg_release(vg);
+		if (!cmd_vg_read(cmd, &cmd_vgs)) {
+			cmd_vg_release(&cmd_vgs);
 			if (ret_max < ECMD_FAILED) {
 				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
@@ -327,17 +337,34 @@
 						  dm_pool_strdup(cmd->mem,
 								 lv_name + 1))) {
 					log_error("strlist allocation failed");
-					unlock_and_release_vg(cmd, vg, vgname);
+					cmd_vg_release(&cmd_vgs);
 					return ECMD_FAILED;
 				}
 			}
 		}
 
-		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    NULL, handle, process_single_lv);
-		unlock_and_release_vg(cmd, vg, vgname);
+		while (!sigint_caught()) {
+			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
+						    tags_arg, &failed_lvnames,
+						    handle, process_single_lv);
+			if (ret != ECMD_PROCESSED ||
+			    dm_list_empty(&failed_lvnames))
+				break;
+
+			/* Try again with failed LVs in this VG */
+			dm_list_init(&lvnames);
+			dm_list_splice(&lvnames, &failed_lvnames);
+
+			cmd_vg_release(&cmd_vgs);
+			if (!cmd_vg_read(cmd, &cmd_vgs)) {
+				ret = ECMD_FAILED; /* break */
+				break;
+			}
+		}
 		if (ret > ret_max)
 			ret_max = ret;
+
+		cmd_vg_release(&cmd_vgs);
 		/* FIXME: logic for breaking command is not consistent */
 		if (sigint_caught())
 			return ECMD_FAILED;


