From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 14:11:16 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20100521141116.18841.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 14:11:13

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Replicator: use cmd_vg list for _process_one_vg()
	
	Patch modifes behavior of _process_one_vg().
	
	In the first pass vg_read() collectis for replicator sorted list of
	additional VGs during lock_vol().
	If any other VG is needed by the replicator and it is not yet opened
	then next iteration loop is taken with all collected VGs.
	
	Flag vg->cmd_missing_vgs detects missing VGs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1585&r2=1.1586
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200

--- LVM2/WHATS_NEW	2010/05/21 14:07:16	1.1585
+++ LVM2/WHATS_NEW	2010/05/21 14:11:13	1.1586
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Update _process_one_vg() to work with cmd_vg struture.
   Add functions for read and release VGs list.
   Add find_replicator_vgs() to discover all needed VGs for replicator-dev LV.
   Add functions for handling cmd_vg structure.
--- LVM2/tools/toollib.c	2010/05/21 12:21:52	1.199
+++ LVM2/tools/toollib.c	2010/05/21 14:11:13	1.200
@@ -432,37 +432,51 @@
 			   uint32_t flags, void *handle, int ret_max,
 			   process_single_vg_fn_t process_single_vg)
 {
-	struct volume_group *vg;
+	struct dm_list cmd_vgs;
+	struct cmd_vg *cvl_vg;
 	int ret = 0;
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
-	vg = vg_read(cmd, vg_name, vgid, flags);
-	/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
-	if (vg_read_error(vg) &&
-	    !((vg_read_error(vg) == FAILED_INCONSISTENT) &&
-	      (flags & READ_ALLOW_INCONSISTENT))) {
-		ret_max = ECMD_FAILED;
-		goto_out;
-	}
+	dm_list_init(&cmd_vgs);
+	if (!(cvl_vg = cmd_vg_add(cmd->mem, &cmd_vgs, vg_name, vgid, flags)))
+		return_0;
+
+	for (;;) {
+		/* FIXME: consistent handling of command break */
+		if (sigint_caught()) {
+                        ret = ECMD_FAILED;
+			break;
+		}
+		if (!cmd_vg_read(cmd, &cmd_vgs))
+			/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
+			if (vg_read_error(cvl_vg->vg) &&
+			    (!((flags & READ_ALLOW_INCONSISTENT) &&
+			       (vg_read_error(cvl_vg->vg) == FAILED_INCONSISTENT)))) {
+				ret = ECMD_FAILED;
+				break;
+			}
+
+		if (!dm_list_empty(tags) &&
+		    /* Only process if a tag matches or it's on arg_vgnames */
+		    !str_list_match_item(arg_vgnames, vg_name) &&
+		    !str_list_match_list(tags, &cvl_vg->vg->tags))
+			break;
 
-	if (!dm_list_empty(tags)) {
-		/* Only process if a tag matches or it's on arg_vgnames */
-		if (!str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &vg->tags))
-			goto out;
+		ret = process_single_vg(cmd, vg_name, cvl_vg->vg, handle);
+
+		if (vg_read_error(cvl_vg->vg)) /* FAILED_INCONSISTENT */
+			break;
+
+		if (!cvl_vg->vg->cmd_missing_vgs)
+			break;
+
+		cmd_vg_release(&cmd_vgs);
 	}
 
-	if ((ret = process_single_vg(cmd, vg_name, vg,
-				  handle)) > ret_max)
-		ret_max = ret;
+	cmd_vg_release(&cmd_vgs);
 
-out:
-	if (vg_read_error(vg))
-		vg_release(vg);
-	else
-		unlock_and_release_vg(cmd, vg, vg_name);
-	return ret_max;
+	return (ret > ret_max) ? ret : ret_max;
 }
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,


