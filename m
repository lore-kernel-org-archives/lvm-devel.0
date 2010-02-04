From: Mike Snitzer <snitzer@redhat.com>
Date: Thu,  4 Feb 2010 18:20:01 -0500
Subject: [PATCH 2/2] switch lvconvert_single() over to using get_logical_volume()
In-Reply-To: <1265325601-10160-1-git-send-email-snitzer@redhat.com>
References: <1265325601-10160-1-git-send-email-snitzer@redhat.com>
Message-ID: <1265325601-10160-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This change was deferred to help ease the review of previous refactoring
related to using process_each_lv() for lvconvert's merge support.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/lvconvert.c |   28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

Index: lvm2/tools/lvconvert.c
===================================================================
--- lvm2.orig/tools/lvconvert.c
+++ lvm2/tools/lvconvert.c
@@ -1325,8 +1325,7 @@ static int poll_logical_volume(struct cm
 
 static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
 {
-	struct volume_group *vg;
-	struct lv_list *lvl;
+	struct logical_volume *lv = NULL;
 	int ret = ECMD_FAILED;
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
@@ -1335,36 +1334,29 @@ static int lvconvert_single(struct cmd_c
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
+	lv = get_logical_volume(cmd, lp->vg_name, lp->lv_name);
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
 


