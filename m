From: okozina <okozina@fedoraproject.org>
Date: Mon, 30 Mar 2015 16:43:13 +0000 (UTC)
Subject: master - pvmove: fix pvmove --abort or pvmove w/o parameters
Message-ID: <20150330164313.E53FC60D2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c282a66132063d702d1df1e342961f75a5ffcdd2
Commit:        c282a66132063d702d1df1e342961f75a5ffcdd2
Parent:        7c66850ce506d9a8bdae74f999a658507943d57c
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Mar 30 16:25:04 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Mar 30 18:38:50 2015 +0200

pvmove: fix pvmove --abort or pvmove w/o parameters

_check_lv_status was called from within dm_list_iterate_items cycle.
This was utterly wrong! _check_lv_status may remove more than one LV from
vg->lvs list we iterated in the same time.

In some scenarios this could lead to deadlock iterationg over same LV
indefinitely or segfault depending on the circumstances.

Fixed by moving the _check_lv_status outside iterating the vg->lvs
list.

Note that commit 6e7b24d34ff3da1c56718bb7def8a8ecd4258c43 was not enough
as _check_lv_status may result in removal of more than one LV from the list.
---
 tools/polldaemon.c |   42 ++++++++++++++++++++++++++++++++++++------
 1 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 53dab96..5383812 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -192,7 +192,9 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		    struct volume_group *vg, struct processing_handle *handle)
 {
 	struct daemon_parms *parms = (struct daemon_parms *) handle->custom_handle;
-	struct lv_list *lvl, *tmp_lvl;
+	struct lv_list *lvl;
+	struct dm_list *sls;
+	struct dm_str_list *sl;
 	struct logical_volume *lv;
 	const char *name;
 	int finished;
@@ -202,7 +204,18 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		return ECMD_FAILED;
 	}
 
-	dm_list_iterate_items_safe(lvl, tmp_lvl, &vg->lvs) {
+	if (!(sls = str_list_create(cmd->mem)))
+		return ECMD_FAILED;
+
+	log_verbose("Looking for pvmove LVs in VG: %s.", vg->name);
+
+	/*
+	 * _check_lv_status must not be called from within any
+	 * dm_list_iterate_ routine with vg->lvs as list head.
+	 * It may remove more than one LV in the process thus
+	 * even "*_safe" variant won't help.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
 			continue;
@@ -217,13 +230,30 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 			continue;
 		}
 
-		if (_check_lv_status(cmd, vg, lv, name, parms, &finished) &&
-		    !finished)
-			parms->outstanding_count++;
+		if (!str_list_add(cmd->mem, sls, dm_pool_strdup(cmd->mem, name)))
+		{
+			log_error("Failed to clone pvname");
+			goto err;
+		}
+
+		log_verbose("Found LV: %s/%s. It belongs to pvmove task on PV %s.", lv->vg->name, lv->name, name);
 	}
 
-	return ECMD_PROCESSED;
+	dm_list_iterate_items(sl, sls) {
+		lv = parms->poll_fns->get_copy_lv(cmd, vg, sl->str, NULL, parms->lv_type);
+		if (lv) {
+			log_verbose("About to call _check_lv_status on LV: %s/%s, name: %s",
+				    lv->vg->name, lv->name, sl->str);
+			if (_check_lv_status(cmd, vg, lv, sl->str, parms, &finished) &&
+			    !finished)
+				parms->outstanding_count++;
+		}
+	}
+
+err:
+	dm_pool_free(cmd->mem, sls);
 
+	return ECMD_PROCESSED;
 }
 
 static void _poll_for_all_vgs(struct cmd_context *cmd,


