From: David Teigland <teigland@redhat.com>
Date: Fri, 23 Aug 2013 16:55:09 -0400
Subject: [PATCH] polldaemon: remove unused code
Message-ID: <20130823205509.GA20443@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

poll_daemon is called with a non-null "name" arg in both places
it's used (pvmove and lvconvert.)
---
 tools/polldaemon.c | 59 ++++--------------------------------------------------
 1 file changed, 4 insertions(+), 55 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index c139d2b..fad7681 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -252,51 +252,6 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 	return 1;
 }
 
-static int _poll_vg(struct cmd_context *cmd, const char *vgname,
-		    struct volume_group *vg, void *handle)
-{
-	struct daemon_parms *parms = (struct daemon_parms *) handle;
-	struct lv_list *lvl;
-	struct logical_volume *lv;
-	const char *name;
-	int finished;
-
-	if (!parms) {
-		log_error(INTERNAL_ERROR "Handle is undefined.");
-		return ECMD_FAILED;
-	}
-
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		lv = lvl->lv;
-		if (!(lv->status & parms->lv_type))
-			continue;
-		name = parms->poll_fns->get_copy_name_from_lv(lv);
-		if (!name && !parms->aborting)
-			continue;
-
-		/* FIXME Need to do the activation from _set_up_pvmove here
-		 *       if it's not running and we're not aborting */
-		if (_check_lv_status(cmd, vg, lv, name, parms, &finished) &&
-		    !finished)
-			parms->outstanding_count++;
-	}
-
-	return ECMD_PROCESSED;
-
-}
-
-static void _poll_for_all_vgs(struct cmd_context *cmd,
-			      struct daemon_parms *parms)
-{
-	while (1) {
-		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, parms, _poll_vg);
-		if (!parms->outstanding_count)
-			break;
-		sleep(parms->interval);
-	}
-}
-
 /*
  * Only allow *one* return from poll_daemon() (the parent).
  * If there is a child it must exit (ignoring the memory leak messages).
@@ -349,16 +304,10 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		/*       fork one daemon per copy? */
 	}
 
-	/*
-	 * Process one specific task or all incomplete tasks?
-	 */
-	if (name) {
-		if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
-			stack;
-			ret = ECMD_FAILED;
-		}
-	} else
-		_poll_for_all_vgs(cmd, &parms);
+	if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
+		stack;
+		ret = ECMD_FAILED;
+	}
 
 	if (parms.background && daemon_mode == 1) {
 		/*
-- 
1.8.3.1


