From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Feb 2010 22:47:22 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100205224722.12830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-05 22:47:22

Modified files:
	tools          : lvconvert.c 

Log message:
	Switch lvconvert_single() over to using get_vg_lock_and_logical_volume()
	
	This change was deferred to help ease the review of previous refactoring
	related to using process_each_lv() for lvconvert's merge support.  Not
	that doing so _really_ helped but...
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/tools/lvconvert.c	2010/02/05 22:44:38	1.118
+++ LVM2/tools/lvconvert.c	2010/02/05 22:47:22	1.119
@@ -1342,8 +1342,7 @@
 
 static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
 {
-	struct volume_group *vg;
-	struct lv_list *lvl;
+	struct logical_volume *lv = NULL;
 	int ret = ECMD_FAILED;
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
@@ -1352,36 +1351,29 @@
 		cmd->handles_missing_pvs = 1;
 	}
 
-	log_verbose("Checking for existing volume group \"%s\"", lp->vg_name);
-
-	vg = vg_read_for_update(cmd, lp->vg_name, NULL, 0);
-	if (vg_read_error(vg))
-		goto out;
-
-	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
-		log_error("Logical volume \"%s\" not found in "
-			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
-		goto bad;
-	}
+	lv = get_vg_lock_and_logical_volume(cmd, lp->vg_name, lp->lv_name);
+	if (!lv)
+		goto_out;
 
 	if (lp->pv_count) {
-		if (!(lp->pvh = create_pv_list(cmd->mem, vg, lp->pv_count,
+		if (!(lp->pvh = create_pv_list(cmd->mem, lv->vg, lp->pv_count,
 					      lp->pvs, 0)))
 			goto_bad;
 	} else
-		lp->pvh = &vg->pvs;
+		lp->pvh = &lv->vg->pvs;
 
-	lp->lv_to_poll = lvl->lv;
-	ret = _lvconvert_single(cmd, lvl->lv, lp);
+	lp->lv_to_poll = lv;
+	ret = _lvconvert_single(cmd, lv, lp);
 bad:
 	unlock_vg(cmd, lp->vg_name);
 
 	if (ret == ECMD_PROCESSED && lp->need_polling)
 		ret = poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
+
+	vg_release(lv->vg);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	vg_release(vg);
 	return ret;
 }
 


