From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:19 +0000 (UTC)
Subject: master - cleanup: use supplied cmd pointer
Message-ID: <20140924085719.4A0E8613A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec4ffeb51ca15d5bd79acf77dfe38630328f1db0
Commit:        ec4ffeb51ca15d5bd79acf77dfe38630328f1db0
Parent:        30777fa46fb21001f3e5a9ba610d50c57c6dfe27
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 23 16:49:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

cleanup: use supplied cmd pointer

---
 lib/activate/activate.c |    3 +--
 tools/lvconvert.c       |    3 ++-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4e1ec5f..8843ec9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -645,7 +645,7 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
-	if (!dev_manager_info(lv->vg->cmd->mem, lv,
+	if (!dev_manager_info(cmd->mem, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
 			      with_open_count, with_read_ahead,
 			      &dminfo, (info) ? &info->read_ahead : NULL))
@@ -794,7 +794,6 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 
 	log_debug_activation("Checking mirror percent for LV %s/%s", lv->vg->name, lv->name);
 
-
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1b71866..9681f3a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2135,7 +2135,8 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)
+	/* FIXME: test when snapshot is remotely active */
+	if (lv_info(cmd, lv, 0, &info, 1, 0)
 	    && info.exists && info.live_table &&
 	    (!lv_snapshot_percent(lv, &snap_percent) ||
 	     snap_percent == DM_PERCENT_INVALID)) {


