From: okozina <okozina@fedoraproject.org>
Date: Tue, 28 Apr 2015 21:35:25 +0000 (UTC)
Subject: master - polldaemon: remove redundant log messages
Message-ID: <20150428213525.4DC50601FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15a563c376d5288f6ec61c20422c27352363f6e1
Commit:        15a563c376d5288f6ec61c20422c27352363f6e1
Parent:        ea5c1b0a7310ffb9528a4c3451d347360b021303
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Apr 14 14:43:16 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Apr 28 23:19:20 2015 +0200

polldaemon: remove redundant log messages

also alter comments describing the change in _poll_vg
wrt correct handling of multiple LVs
---
 tools/polldaemon.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 1b6e1b4..2684f63 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -207,13 +207,9 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 	if (!(sls = str_list_create(cmd->mem)))
 		return ECMD_FAILED;
 
-	log_verbose("Looking for pvmove LVs in VG: %s.", vg->name);
-
 	/*
-	 * _check_lv_status must not be called from within any
-	 * dm_list_iterate_ routine with vg->lvs as list head.
-	 * It may remove more than one LV in the process thus
-	 * even "*_safe" variant won't help.
+	 * first iterate all LVs in a VG and collect LVs suitable
+	 * for polling (or an abort) which takes place below
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
@@ -240,19 +236,13 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 			log_error("Failed to clone pvname");
 			goto err;
 		}
-
-		log_verbose("Found LV: %s/%s. It belongs to pvmove task on PV %s.", lv->vg->name, lv->name, name);
 	}
 
+	/* perform the poll operation on LVs collected in previous cycle */
 	dm_list_iterate_items(sl, sls) {
 		lv = parms->poll_fns->get_copy_lv(cmd, vg, sl->str, NULL, parms->lv_type);
-		if (lv) {
-			log_verbose("About to call _check_lv_status on LV: %s/%s, name: %s",
-				    lv->vg->name, lv->name, sl->str);
-			if (_check_lv_status(cmd, vg, lv, sl->str, parms, &finished) &&
-			    !finished)
-				parms->outstanding_count++;
-		}
+		if (lv && _check_lv_status(cmd, vg, lv, sl->str, parms, &finished) && !finished)
+			parms->outstanding_count++;
 	}
 
 err:


