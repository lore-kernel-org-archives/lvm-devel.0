From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 30 Sep 2013 06:20:01 +0000 (UTC)
Subject: master - fix: also make commit b4637 work without dmeventd
Message-ID: <20130930062001.8026161007@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e02ff3226021ddaf0861f65637d9be65d855506b
Commit:        e02ff3226021ddaf0861f65637d9be65d855506b
Parent:        e4c7236c07056ddc9af3ba6ad2314d649d6814f9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 30 08:17:56 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 30 08:17:56 2013 +0200

fix: also make commit b4637 work without dmeventd

---
 lib/raid/raid.c |   44 ++++++++++++++++++++++----------------------
 lib/thin/thin.c |   53 +++++++++++++++++++++++++++--------------------------
 2 files changed, 49 insertions(+), 48 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 20e8c1a..c963fd2 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -282,28 +282,6 @@ static void _raid_destroy(struct segment_type *segtype)
 }
 
 #ifdef DEVMAPPER_SUPPORT
-#ifdef DMEVENTD
-static const char *_get_raid_dso_path(struct cmd_context *cmd)
-{
-	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
-	return get_monitor_dso_path(cmd, config_str);
-}
-
-static int _raid_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg __attribute__((unused)),
-				unsigned *attributes __attribute__((unused)))
-{
-	static int _raid_checked = 0;
-	static int _raid_present = 0;
-
-	if (!_raid_checked)
-		_raid_present = target_present(cmd, "raid", 1);
-
-	_raid_checked = 1;
-
-	return _raid_present;
-}
-
 static int _raid_target_percent(void **target_state,
 				percent_t *percent,
 				struct dm_pool *mem,
@@ -346,6 +324,28 @@ static int _raid_target_percent(void **target_state,
 	return 1;
 }
 
+static int _raid_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes __attribute__((unused)))
+{
+	static int _raid_checked = 0;
+	static int _raid_present = 0;
+
+	if (!_raid_checked)
+		_raid_present = target_present(cmd, "raid", 1);
+
+	_raid_checked = 1;
+
+	return _raid_present;
+}
+
+#ifdef DMEVENTD
+static const char *_get_raid_dso_path(struct cmd_context *cmd)
+{
+	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
+	return get_monitor_dso_path(cmd, config_str);
+}
+
 static int _raid_target_monitored(struct lv_segment *seg, int *pending)
 {
 	struct cmd_context *cmd = seg->lv->vg->cmd;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 531e546..8477aac 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -224,6 +224,33 @@ static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
 				unsigned *attributes);
 
+static int _thin_pool_modules_needed(struct dm_pool *mem,
+				     const struct lv_segment *seg __attribute__((unused)),
+				     struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, _thin_pool_module)) {
+		log_error("String list allocation failed for thin_pool.");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _thin_modules_needed(struct dm_pool *mem,
+				const struct lv_segment *seg,
+				struct dm_list *modules)
+{
+	if (!_thin_pool_modules_needed(mem, seg, modules))
+		return_0;
+
+	if (!str_list_add(mem, modules, _thin_module)) {
+		log_error("String list allocation failed for thin.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _thin_pool_add_target_line(struct dev_manager *dm,
 				      struct dm_pool *mem,
 				      struct cmd_context *cmd,
@@ -416,32 +443,6 @@ static int _target_unregister_events(struct lv_segment *seg,
 	return _target_set_events(seg, events, 0);
 }
 
-static int _thin_pool_modules_needed(struct dm_pool *mem,
-				     const struct lv_segment *seg __attribute__((unused)),
-				     struct dm_list *modules)
-{
-	if (!str_list_add(mem, modules, _thin_pool_module)) {
-		log_error("String list allocation failed for thin_pool.");
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _thin_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg,
-				struct dm_list *modules)
-{
-	if (!_thin_pool_modules_needed(mem, seg, modules))
-		return_0;
-
-	if (!str_list_add(mem, modules, _thin_module)) {
-		log_error("String list allocation failed for thin.");
-		return 0;
-	}
-
-	return 1;
-}
 #  endif /* DMEVENTD */
 #endif /* DEVMAPPER_SUPPORT */
 


