From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 19 Aug 2019 11:36:42 -0400
Subject: stable-2.02 - Revert "pvmove_poll: instrument"
Message-ID: <201908191536.x7JFagNg016206@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=474963573af2112467fcd6b17f42971e3178eaa8
Commit:        474963573af2112467fcd6b17f42971e3178eaa8
Parent:        9e438b4bc6b9240b63fc79acfef3c77c01a848d8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 19 17:35:52 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 19 17:35:52 2019 +0200

Revert "pvmove_poll: instrument"

This reverts commit fdb014f02fe67d3a8455c919516e752ec07e9b04.

Went in by mistake!
---
 tools/pvmove_poll.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 23adf17..e50747c 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -78,28 +78,21 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			   struct dm_list *lvs_changed __attribute__((unused)),
 			   unsigned flags __attribute__((unused)))
 {
-printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 	if (!lv_update_and_reload(lv_mirr))
 		return_0;
 
-printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 	return 1;
 }
 
 int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed)
 {
-	int read_ahead = lv_mirr->read_ahead;
-
-printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 	if (!dm_list_empty(lvs_changed) &&
 	    (!_detach_pvmove_mirror(cmd, lv_mirr) ||
 	    !replace_lv_with_error_segment(lv_mirr))) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
-	lv_mirr->read_ahead = read_ahead;
-printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 
 	if (!lv_update_and_reload(lv_mirr))
 		return_0;


