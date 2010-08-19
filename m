From: Milan Broz <mbroz@redhat.com>
Date: Fri, 20 Aug 2010 00:48:18 +0200
Subject: [PATCH] Fix pvmove --abort to work even for empty pvmove LV
Message-ID: <1282258098-24500-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If pvmove crashed and metadata contains pvmove LV
but without miorrored segments, pvmove --abort
will not repair the situation (and finish wth success!).

Fix it by allowing metadata update if aborting
(thus removing pvmove LV) even if no moved LVs detected.

(Tested on real metadata provided by an lvm user:-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/polldaemon.c |    4 +++-
 tools/pvmove.c     |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d51f4bb..147d532 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -234,8 +234,10 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
 			continue;
-		if (!(name = parms->poll_fns->get_copy_name_from_lv(lv)))
+		name = parms->poll_fns->get_copy_name_from_lv(lv);
+		if (!name && !parms->aborting)
 			continue;
+
 		/* FIXME Need to do the activation from _set_up_pvmove here
 		 *       if it's not running and we're not aborting */
 		if (_check_lv_status(cmd, vg, lv, name, parms, &finished) &&
diff --git a/tools/pvmove.c b/tools/pvmove.c
index c8a480f..0346ca3 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -520,7 +520,8 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 {
 	int r = 1;
 
-	if (!_detach_pvmove_mirror(cmd, lv_mirr)) {
+	if (!dm_list_empty(lvs_changed) &&
+	    !_detach_pvmove_mirror(cmd, lv_mirr)) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
-- 
1.7.1


