From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 20:08:51 +0100
Subject: [PATCH] Resume volumes in reverse order to preserve memlock pairing.
Message-ID: <1262027331-19005-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If renaming snapshot with virtual origin, the origin is renamed too.
But the code must resume LVs in reverse order to properly
pair memlock (in cluster locking).

(The resume of snapshot resumes origin too and later resume
is ignored otherwise.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7a0171e..041ed08 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1767,7 +1767,7 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names;
 	DM_LIST_INIT(lvs_changed);
-	struct lv_list lvl, lvl2;
+	struct lv_list lvl, lvl2, *lvlp;
 	int r = 0;
 
 	/* rename is not allowed on sub LVs */
@@ -1822,7 +1822,8 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(r = vg_commit(vg)))
 		stack;
 
-	resume_lvs(cmd, &lvs_changed);
+	dm_list_iterate_back_items(lvlp, &lvs_changed)
+		resume_lv(cmd, lvlp->lv);
 out:
 	backup(vg);
 	return r;
-- 
1.6.5.7


