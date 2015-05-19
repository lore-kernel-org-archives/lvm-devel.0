From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:02:59 +0000 (UTC)
Subject: master - polldaemon.c: call find_lv directly
Message-ID: <20150519190259.CFA7460FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fba37777c8a0931adf1164ff914aa494d8bcee8
Commit:        6fba37777c8a0931adf1164ff914aa494d8bcee8
Parent:        08114840caf0a31d76b8870ec96594dd715baff0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 19 15:08:50 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:56:07 2015 +0200

polldaemon.c: call find_lv directly

---
 tools/polldaemon.c |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 2cb56fa..d5daa62 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -179,7 +179,12 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 			return 0;
 		}
 
-		lv = parms->poll_fns->get_copy_lv(cmd, vg, id->lv_name, id->uuid, parms->lv_type);
+		lv = find_lv(vg, id->lv_name);
+
+		if (lv && id->uuid && strcmp(id->uuid, (char *)&lv->lvid))
+			lv = NULL;
+		if (lv && parms->lv_type && !(lv->status & parms->lv_type))
+			lv = NULL;
 
 		if (!lv && parms->lv_type == PVMOVE) {
 			log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
@@ -339,8 +344,13 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 
 	/* perform the poll operation on LVs collected in previous cycle */
 	dm_list_iterate_items(idl, &idls) {
-		lv = parms->poll_fns->get_copy_lv(cmd, vg, idl->id->lv_name, idl->id->uuid, parms->lv_type);
-		if (lv && _check_lv_status(cmd, vg, lv, idl->id->display_name, parms, &finished) && !finished)
+		if (!(lv = find_lv(vg, idl->id->lv_name)))
+			continue;
+		if (idl->id->uuid && strcmp(idl->id->uuid, (char *)&lv->lvid))
+			continue;
+		if (parms->lv_type && !(lv->status & parms->lv_type))
+			continue;
+		if (_check_lv_status(cmd, vg, lv, idl->id->display_name, parms, &finished) && !finished)
 			parms->outstanding_count++;
 	}
 
@@ -386,7 +396,13 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 		return 0;
 	}
 
-	lv = parms->poll_fns->get_copy_lv(cmd, vg, id->lv_name, id->uuid, parms->lv_type);
+	lv = find_lv(vg, id->lv_name);
+
+	if (lv && id->uuid && strcmp(id->uuid, (char *)&lv->lvid))
+		lv = NULL;
+	if (lv && parms->lv_type && !(lv->status & parms->lv_type))
+		lv = NULL;
+
 	if (!lv && parms->lv_type == PVMOVE) {
 		log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
 					id->display_name);


