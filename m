From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:28 +0000 (UTC)
Subject: master - cleanup: simplier code
Message-ID: <20161205161528.97C846036D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3331199cc9f4b3935bc531428f03fbf3bb017d4c
Commit:        3331199cc9f4b3935bc531428f03fbf3bb017d4c
Parent:        81ef4eb4f887381d67546884be5a717030fb505a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 14:59:02 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

cleanup: simplier code

---
 lib/activate/dev_manager.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6a8e487..581e900 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -728,15 +728,13 @@ int dev_manager_info(struct cmd_context *cmd, const struct logical_volume *lv,
 		     struct lv_seg_status *seg_status)
 {
 	char *dlid, *name;
-	int r;
+	int r = 0;
 
 	if (!(name = dm_build_dm_name(cmd->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(cmd->mem, lv, layer))) {
-		r = 0;
+	if (!(dlid = build_dm_uuid(cmd->mem, lv, layer)))
 		goto_out;
-	}
 
 	log_debug_activation("Getting device info for %s [%s].", name, dlid);
 	r = _info(cmd, dlid, with_open_count, with_read_ahead,
@@ -1446,13 +1444,13 @@ int dev_manager_thin_pool_percent(struct dev_manager *dm,
 {
 	char *name;
 	const char *dlid;
+	const char *layer = lv_layer(lv);
 
 	/* Build a name for the top layer */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name,
-				      lv_layer(lv))))
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	log_debug_activation("Getting device status percentage for %s.", name);


