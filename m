From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 29 Sep 2009 11:22:55 -0400
Subject: [PATCH 2/4] Eliminate _check_lv_status's 'name' argument
In-Reply-To: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
References: <1254237777-30501-1-git-send-email-snitzer@redhat.com>
Message-ID: <1254237777-30501-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_check_lv_status's 'name' argument sometimes contains a name of a VG and
sometimes name of an LV, so using it in generic code would be dangerous.
'name' was never used for anything other than progress_display.

The next patch will properly split out context specific
progress_display.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>

---
 tools/polldaemon.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

Index: lvm2/tools/polldaemon.c
===================================================================
--- lvm2.orig/tools/polldaemon.c
+++ lvm2/tools/polldaemon.c
@@ -66,7 +66,7 @@ static int _become_daemon(struct cmd_con
 static int _check_lv_status(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct logical_volume *lv,
-			    const char *name, struct daemon_parms *parms,
+			    struct daemon_parms *parms,
 			    int *finished)
 {
 	struct dm_list *lvs_changed;
@@ -94,12 +94,6 @@ static int _check_lv_status(struct cmd_c
 	}
 
 	overall_status = copy_percent(lv, &overall_percent);
-	if (parms->progress_display)
-		log_print("%s: %s: %.1f%%", name, parms->progress_title,
-			  overall_percent);
-	else
-		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
-			    overall_percent);
 
 	if (status < TARGET_STATUS_FINISHED) {
 		/* The only case the caller *should* try again later */
@@ -163,7 +157,7 @@ static int _wait_for_single_lv(struct cm
 			return 0;
 		}
 
-		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
+		if (!_check_lv_status(cmd, vg, lv, parms, &finished)) {
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
@@ -180,19 +174,19 @@ static int _poll_vg(struct cmd_context *
 	struct daemon_parms *parms = (struct daemon_parms *) handle;
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	const char *name;
 	int finished;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
 			continue;
-		if (!(name = parms->poll_fns->get_copy_name_from_lv(lv)))
+		/* NOTE don't need name but this check has significance
+		 *      because it skips LVs that aren't mirrored */
+		if (parms->poll_fns->get_copy_name_from_lv(lv) == NULL)
 			continue;
 		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting */
-		if (_check_lv_status(cmd, vg, lv, name,
-				     parms, &finished) && !finished)
+		if (_check_lv_status(cmd, vg, lv, parms, &finished) && !finished)
 			parms->outstanding_count++;
 	}
 


