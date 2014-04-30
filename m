From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:11 +0000 (UTC)
Subject: master - cleanup: modules_needed only for devmapper
Message-ID: <20140430082811.BEFD460DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94018279190d8f2d795a77482f3977f76687289b
Commit:        94018279190d8f2d795a77482f3977f76687289b
Parent:        62e8dd4f6ec73b6f94f66c3b14cdf3d80c06a2af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 23:41:17 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:30 2014 +0200

cleanup: modules_needed only for devmapper

Drop compilation of modules_needed and add_target_lin
function when compiled without devmapper support.
Cleanup surrounding ifdefs.
---
 lib/cache_segtype/cache.c |   50 ++++++++++++++------------------------------
 lib/error/errseg.c        |    4 +-
 lib/mirror/mirrored.c     |    8 +++---
 lib/raid/raid.c           |   35 ++++++++++++++++---------------
 lib/snapshot/snapshot.c   |   12 +++++-----
 lib/thin/thin.c           |    4 +--
 lib/zero/zero.c           |    4 +-
 7 files changed, 49 insertions(+), 68 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 3b1214b..0e49530 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -216,35 +216,6 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	return 1;
 }
 
-static int _cache_pool_add_target_line(struct dev_manager *dm,
-				       struct dm_pool *mem,
-				       struct cmd_context *cmd __attribute__((unused)),
-				       void **target_state __attribute__((unused)),
-				       struct lv_segment *seg,
-				       const struct lv_activate_opts *laopts __attribute__((unused)),
-				       struct dm_tree_node *node, uint64_t len,
-				       uint32_t *pvmove_mirror_count __attribute__((unused)))
-{
-	/*
-	 * This /could/ be directed at _cdata, but I prefer
-	 * not to give a user direct access to a sub-LV via
-	 * this cache_pool.
-	 */
-	return dm_tree_node_add_error_target(node, len);
-}
-
-static int _modules_needed(struct dm_pool *mem,
-			   const struct lv_segment *seg __attribute__((unused)),
-			   struct dm_list *modules)
-{
-	if (!str_list_add(mem, modules, "cache")) {
-		log_error("cache module string list allocation failed");
-		return 0;
-	}
-
-	return 1;
-}
-
 static void _destroy(struct segment_type *segtype)
 {
 	dm_free((void *) segtype);
@@ -281,6 +252,17 @@ static int _target_present(struct cmd_context *cmd,
 	return _cache_present;
 }
 
+static int _modules_needed(struct dm_pool *mem,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, "cache")) {
+		log_error("String list allocation failed for cache module.");
+		return 0;
+	}
+
+	return 1;
+}
 #endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _cache_pool_ops = {
@@ -288,13 +270,12 @@ static struct segtype_handler _cache_pool_ops = {
 	.text_import = _cache_pool_text_import,
 	.text_import_area_count = _cache_pool_text_import_area_count,
 	.text_export = _cache_pool_text_export,
-	.add_target_line = _cache_pool_add_target_line,
 #ifdef DEVMAPPER_SUPPORT
 	.target_present = _target_present,
+	.modules_needed = _modules_needed,
 #  ifdef DMEVENTD
 #  endif        /* DMEVENTD */
 #endif
-	.modules_needed = _modules_needed,
 	.destroy = _destroy,
 };
 
@@ -348,6 +329,7 @@ static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
 	return 1;
 }
 
+#ifdef DEVMAPPER_SUPPORT
 static int _cache_add_target_line(struct dev_manager *dm,
 				 struct dm_pool *mem,
 				 struct cmd_context *cmd __attribute__((unused)),
@@ -384,19 +366,20 @@ static int _cache_add_target_line(struct dev_manager *dm,
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
 }
+#endif /* DEVMAPPER_SUPPORT */
 
 static struct segtype_handler _cache_ops = {
 	.name = _name,
 	.text_import = _cache_text_import,
 	.text_import_area_count = _cache_text_import_area_count,
 	.text_export = _cache_text_export,
-	.add_target_line = _cache_add_target_line,
 #ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _cache_add_target_line,
 	.target_present = _target_present,
+	.modules_needed = _modules_needed,
 #  ifdef DMEVENTD
 #  endif        /* DMEVENTD */
 #endif
-	.modules_needed = _modules_needed,
 	.destroy = _destroy,
 };
 
@@ -445,4 +428,3 @@ int init_cache_segtypes(struct cmd_context *cmd,
 
 	return 1;
 }
-
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index 179f1a6..f3bf9c9 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -63,7 +63,6 @@ static int _errseg_target_present(struct cmd_context *cmd,
 	_errseg_checked = 1;
 	return _errseg_present;
 }
-#endif
 
 static int _errseg_modules_needed(struct dm_pool *mem,
 				  const struct lv_segment *seg __attribute__((unused)),
@@ -76,6 +75,7 @@ static int _errseg_modules_needed(struct dm_pool *mem,
 
 	return 1;
 }
+#endif
 
 static void _errseg_destroy(struct segment_type *segtype)
 {
@@ -88,8 +88,8 @@ static struct segtype_handler _error_ops = {
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _errseg_add_target_line,
 	.target_present = _errseg_target_present,
-#endif
 	.modules_needed = _errseg_modules_needed,
+#endif
 	.destroy = _errseg_destroy,
 };
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index afb047e..e3f768f 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -531,7 +531,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	return _mirrored_present;
 }
 
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 static const char *_get_mirror_dso_path(struct cmd_context *cmd)
 {
 	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, dmeventd_mirror_library_CFG, NULL));
@@ -561,8 +561,7 @@ static int _target_unmonitor_events(struct lv_segment *seg, int events)
 	return _target_set_events(seg, events, 0);
 }
 
-#endif /* DMEVENTD */
-#endif /* DEVMAPPER_SUPPORT */
+#  endif /* DMEVENTD */
 
 static int _mirrored_modules_needed(struct dm_pool *mem,
 				    const struct lv_segment *seg,
@@ -585,6 +584,7 @@ static int _mirrored_modules_needed(struct dm_pool *mem,
 
 	return 1;
 }
+#endif /* DEVMAPPER_SUPPORT */
 
 static void _mirrored_destroy(struct segment_type *segtype)
 {
@@ -602,13 +602,13 @@ static struct segtype_handler _mirrored_ops = {
 	.target_percent = _mirrored_target_percent,
 	.target_present = _mirrored_target_present,
 	.check_transient_status = _mirrored_transient_status,
+	.modules_needed = _mirrored_modules_needed,
 #  ifdef DMEVENTD
 	.target_monitored = _target_registered,
 	.target_monitor_events = _target_monitor_events,
 	.target_unmonitor_events = _target_unmonitor_events,
 #  endif	/* DMEVENTD */
 #endif
-	.modules_needed = _mirrored_modules_needed,
 	.destroy = _mirrored_destroy,
 };
 
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 815c6f7..b77c315 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -262,18 +262,6 @@ static int _raid_target_status_compatible(const char *type)
 	return (strstr(type, "raid") != NULL);
 }
 
-static int _raid_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg __attribute__((unused)),
-				struct dm_list *modules)
-{
-	if (!str_list_add(mem, modules, "raid")) {
-		log_error("raid module string list allocation failed");
-		return 0;
-	}
-
-	return 1;
-}
-
 static void _raid_destroy(struct segment_type *segtype)
 {
 	dm_free((void *) segtype);
@@ -367,7 +355,19 @@ static int _raid_target_present(struct cmd_context *cmd,
 	return _raid_present;
 }
 
-#ifdef DMEVENTD
+static int _raid_modules_needed(struct dm_pool *mem,
+				const struct lv_segment *seg __attribute__((unused)),
+				struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, "raid")) {
+		log_error("raid module string list allocation failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+#  ifdef DMEVENTD
 static const char *_get_raid_dso_path(struct cmd_context *cmd)
 {
 	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
@@ -399,8 +399,9 @@ static int _raid_target_unmonitor_events(struct lv_segment *seg, int events)
 {
 	return _raid_set_events(seg, events, 0);
 }
+#  endif /* DMEVENTD */
 #endif /* DEVMAPPER_SUPPORT */
-#endif /* DMEVENTD */
+
 static struct segtype_handler _raid_ops = {
 	.name = _raid_name,
 	.text_import_area_count = _raid_text_import_area_count,
@@ -411,13 +412,13 @@ static struct segtype_handler _raid_ops = {
 #ifdef DEVMAPPER_SUPPORT
 	.target_percent = _raid_target_percent,
 	.target_present = _raid_target_present,
+	.modules_needed = _raid_modules_needed,
 #  ifdef DMEVENTD
 	.target_monitored = _raid_target_monitored,
 	.target_monitor_events = _raid_target_monitor_events,
 	.target_unmonitor_events = _raid_target_unmonitor_events,
 #  endif        /* DMEVENTD */
 #endif
-	.modules_needed = _raid_modules_needed,
 	.destroy = _raid_destroy,
 };
 
@@ -475,10 +476,10 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	int monitored = 0;
 
 #ifdef DEVMAPPER_SUPPORT
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 	if (_get_raid_dso_path(cmd))
 		monitored = SEG_MONITORED;
-#endif
+#  endif
 #endif
 
 	for (i = 0; i < DM_ARRAY_SIZE(_raid_types); ++i)
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 7ee0365..a4ee2ea 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -100,12 +100,12 @@ static int _snap_text_export(const struct lv_segment *seg, struct formatter *f)
 	return 1;
 }
 
+#ifdef DEVMAPPER_SUPPORT
 static int _snap_target_status_compatible(const char *type)
 {
 	return (strcmp(type, "snapshot-merge") == 0);
 }
 
-#ifdef DEVMAPPER_SUPPORT
 static int _snap_target_percent(void **target_state __attribute__((unused)),
 				percent_t *percent,
 				struct dm_pool *mem __attribute__((unused)),
@@ -178,7 +178,7 @@ static int _snap_target_present(struct cmd_context *cmd,
 	return _snap_present;
 }
 
-#ifdef DMEVENTD
+#  ifdef DMEVENTD
 
 static const char *_get_snapshot_dso_path(struct cmd_context *cmd)
 {
@@ -212,8 +212,7 @@ static int _target_unregister_events(struct lv_segment *seg,
 	return _target_set_events(seg, events, 0);
 }
 
-#endif /* DMEVENTD */
-#endif
+#  endif /* DMEVENTD */
 
 static int _snap_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute__((unused)),
@@ -226,6 +225,7 @@ static int _snap_modules_needed(struct dm_pool *mem,
 
 	return 1;
 }
+#endif /* DEVMAPPER_SUPPORT */
 
 static void _snap_destroy(struct segment_type *segtype)
 {
@@ -237,17 +237,17 @@ static struct segtype_handler _snapshot_ops = {
 	.target_name = _snap_target_name,
 	.text_import = _snap_text_import,
 	.text_export = _snap_text_export,
-	.target_status_compatible = _snap_target_status_compatible,
 #ifdef DEVMAPPER_SUPPORT
+	.target_status_compatible = _snap_target_status_compatible,
 	.target_percent = _snap_target_percent,
 	.target_present = _snap_target_present,
+	.modules_needed = _snap_modules_needed,
 #  ifdef DMEVENTD
 	.target_monitored = _target_registered,
 	.target_monitor_events = _target_register_events,
 	.target_unmonitor_events = _target_unregister_events,
 #  endif	/* DMEVENTD */
 #endif
-	.modules_needed = _snap_modules_needed,
 	.destroy = _snap_destroy,
 };
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index a1bfaaa..28f3e43 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -729,15 +729,13 @@ static struct segtype_handler _thin_pool_ops = {
 	.add_target_line = _thin_pool_add_target_line,
 	.target_percent = _thin_pool_target_percent,
 	.target_present = _thin_target_present,
+	.modules_needed = _thin_pool_modules_needed,
 #  ifdef DMEVENTD
 	.target_monitored = _target_registered,
 	.target_monitor_events = _target_register_events,
 	.target_unmonitor_events = _target_unregister_events,
 #  endif /* DMEVENTD */
 #endif
-#ifdef DEVMAPPER_SUPPORT
-	.modules_needed = _thin_pool_modules_needed,
-#endif
 	.destroy = _thin_destroy,
 };
 
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 555c570..2a1fd0b 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -59,7 +59,6 @@ static int _zero_target_present(struct cmd_context *cmd,
 
 	return _zero_present;
 }
-#endif
 
 static int _zero_modules_needed(struct dm_pool *mem,
 				const struct lv_segment *seg __attribute__((unused)),
@@ -72,6 +71,7 @@ static int _zero_modules_needed(struct dm_pool *mem,
 
 	return 1;
 }
+#endif
 
 static void _zero_destroy(struct segment_type *segtype)
 {
@@ -84,8 +84,8 @@ static struct segtype_handler _zero_ops = {
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _zero_add_target_line,
 	.target_present = _zero_target_present,
-#endif
 	.modules_needed = _zero_modules_needed,
+#endif
 	.destroy = _zero_destroy,
 };
 


