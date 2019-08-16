From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 16 Aug 2019 12:12:15 -0400
Subject: stable-2.02 - pvmove_poll: instrument
Message-ID: <201908161612.x7GGCFc2002270@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdb014f02fe67d3a8455c919516e752ec07e9b04
Commit:        fdb014f02fe67d3a8455c919516e752ec07e9b04
Parent:        4a3e1ac7407dff9e53c5efea179a5620ad13f8f3
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 16 14:28:19 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Aug 14 21:40:26 2019 +0200

pvmove_poll: instrument

---
 tools/pvmove_poll.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index e50747c..23adf17 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -78,21 +78,28 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			   struct dm_list *lvs_changed __attribute__((unused)),
 			   unsigned flags __attribute__((unused)))
 {
+printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 	if (!lv_update_and_reload(lv_mirr))
 		return_0;
 
+printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 	return 1;
 }
 
 int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed)
 {
+	int read_ahead = lv_mirr->read_ahead;
+
+printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 	if (!dm_list_empty(lvs_changed) &&
 	    (!_detach_pvmove_mirror(cmd, lv_mirr) ||
 	    !replace_lv_with_error_segment(lv_mirr))) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
+	lv_mirr->read_ahead = read_ahead;
+printf("%s[%u] lv_mirr->read_ahead=%d\n", __func__, __LINE__, lv_mirr->read_ahead);
 
 	if (!lv_update_and_reload(lv_mirr))
 		return_0;


