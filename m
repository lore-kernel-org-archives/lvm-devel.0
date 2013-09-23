From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:27 +0000 (UTC)
Subject: master - activation: use improved lv_info
Message-ID: <20130923101627.E266661326@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1fdead8d97376c757af01b55d7556e3411255124
Commit:        1fdead8d97376c757af01b55d7556e3411255124
Parent:        3b604e5c8e505138fc86e009375fd33160ab84ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 19 22:18:16 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:13:08 2013 +0200

activation: use improved lv_info

Call lv_info() with info == NULL to query for local active presence.
---
 lib/activate/activate.c |   29 +++++++----------------------
 1 files changed, 7 insertions(+), 22 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index e4d9b49..c9d2c1a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -738,7 +738,7 @@ int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 	int r;
 	struct dev_manager *dm;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking snapshot percent for LV %s/%s", lv->vg->name, lv->name);
@@ -760,7 +760,6 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 {
 	int r;
 	struct dev_manager *dm;
-	struct lvinfo info;
 
 	/* If mirrored LV is temporarily shrinked to 1 area (= linear),
 	 * it should be considered in-sync. */
@@ -769,16 +768,11 @@ int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		return 1;
 	}
 
-	if (!activation())
+	if (!lv_info(cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking mirror percent for LV %s/%s", lv->vg->name, lv->name);
 
-	if (!lv_info(cmd, lv, 0, &info, 0, 0))
-		return_0;
-
-	if (!info.exists)
-		return 0;
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
@@ -804,15 +798,12 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 
 	*dev_health = NULL;
 
-	if (!activation())
-		return_0;
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
+		return 0;
 
 	log_debug_activation("Checking raid device health for LV %s/%s",
 			     lv->vg->name, lv->name);
 
-	if (!lv_is_active_locally(lv))
-		return 0;
-
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
@@ -835,15 +826,12 @@ int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 
 	*cnt = 0;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking raid mismatch count for LV %s/%s",
 			     lv->vg->name, lv->name);
 
-	if (!lv_is_active_locally(lv))
-		return_0;
-
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
@@ -866,15 +854,12 @@ int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action)
 
 	*sync_action = NULL;
 
-	if (!activation())
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
 		return 0;
 
 	log_debug_activation("Checking raid sync_action for LV %s/%s",
 			     lv->vg->name, lv->name);
 
-	if (!lv_is_active_locally(lv))
-		return_0;
-
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
@@ -906,7 +891,7 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 		return 0;
 	}
 
-	if (!lv_is_active_locally(lv)) {
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0)) {
 		log_error("Unable to send message to an inactive logical volume.");
 		return 0;
 	}


