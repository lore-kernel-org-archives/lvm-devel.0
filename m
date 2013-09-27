From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Sep 2013 12:05:27 +0000 (UTC)
Subject: master - fix: make it possible to compile with --disable-devmapper again
Message-ID: <20130927120527.4F94A614CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4637bd298a7a12e0ce9f15104d41158b96cb642
Commit:        b4637bd298a7a12e0ce9f15104d41158b96cb642
Parent:        acdc731e83f7ba646a5e3c55398032464605ee58
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 27 13:58:55 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 27 13:58:55 2013 +0200

fix: make it possible to compile with --disable-devmapper again

Some code has been added recently which makes it impossible to compile
when "configure --disable-devmapper" is used. This patch just shuffles
the code around so it's under proper #ifdef DEVMAPPER_SUPPORT.
---
 lib/activate/activate.c |  201 ++++++++++++++++++++++++-----------------------
 lib/config/defaults.h   |    7 +-
 lib/raid/raid.c         |   81 +++++++++----------
 lib/thin/thin.c         |   66 ++++++++--------
 4 files changed, 179 insertions(+), 176 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c9d2c1a..28549fc 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -111,6 +111,97 @@ int list_lv_modules(struct dm_pool *mem, const struct logical_volume *lv,
 	return 1;
 }
 
+static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
+				     const struct dm_config_node *cn, const int cfg_id)
+{
+	const struct dm_config_value *cv;
+	const char *str;
+	static char config_path[PATH_MAX];
+	static char path[PATH_MAX];
+
+	config_def_get_path(config_path, sizeof(config_path), cfg_id);
+	log_verbose("%s configuration setting defined: "
+		    "Checking the list to match %s/%s",
+		    config_path, lv->vg->name, lv->name);
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type == DM_CFG_EMPTY_ARRAY)
+			goto out;
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Ignoring invalid string in config file %s",
+				  config_path);
+			continue;
+		}
+		str = cv->v.str;
+		if (!*str) {
+			log_error("Ignoring empty string in config file %s",
+				  config_path);
+			continue;
+		}
+
+
+		/* Tag? */
+		if (*str == '@') {
+			str++;
+			if (!*str) {
+				log_error("Ignoring empty tag in config file "
+					  "%s", config_path);
+				continue;
+			}
+			/* If any host tag matches any LV or VG tag, activate */
+			if (!strcmp(str, "*")) {
+				if (str_list_match_list(&cmd->tags, &lv->tags, NULL)
+				    || str_list_match_list(&cmd->tags,
+							   &lv->vg->tags, NULL))
+					    return 1;
+				else
+					continue;
+			}
+			/* If supplied tag matches LV or VG tag, activate */
+			if (str_list_match_item(&lv->tags, str) ||
+			    str_list_match_item(&lv->vg->tags, str))
+				return 1;
+			else
+				continue;
+		}
+		if (!strchr(str, '/')) {
+			/* vgname supplied */
+			if (!strcmp(str, lv->vg->name))
+				return 1;
+			else
+				continue;
+		}
+		/* vgname/lvname */
+		if (dm_snprintf(path, sizeof(path), "%s/%s", lv->vg->name,
+				 lv->name) < 0) {
+			log_error("dm_snprintf error from %s/%s", lv->vg->name,
+				  lv->name);
+			continue;
+		}
+		if (!strcmp(path, str))
+			return 1;
+	}
+
+out:
+	log_verbose("No item supplied in %s configuration setting "
+		    "matches %s/%s", config_path, lv->vg->name, lv->name);
+
+	return 0;
+}
+
+int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	const struct dm_config_node *cn;
+
+	if (!(cn = find_config_tree_node(cmd, activation_auto_activation_volume_list_CFG, NULL))) {
+		log_verbose("activation/auto_activation_volume_list configuration setting "
+			    "not defined: All logical volumes will be auto-activated.");
+		return 1;
+	}
+
+	return _lv_passes_volumes_filter(cmd, lv, cn, activation_auto_activation_volume_list_CFG);
+}
+
 #ifndef DEVMAPPER_SUPPORT
 void set_activation(int act)
 {
@@ -223,33 +314,35 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 	return 1;
 }
 *******/
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive,
+			 struct logical_volume *ondisk_lv, struct logical_volume *incore_lv)
 {
 	return 1;
 }
-int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv)
 {
 	return 1;
 }
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive, unsigned revert)
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
+			unsigned exclusive, unsigned revert, struct logical_volume *lv)
 {
 	return 1;
 }
-int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
+int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv)
 {
 	return 1;
 }
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv)
+			 int *activate_lv, struct logical_volume *lv)
 {
 	return 1;
 }
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive)
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv)
 {
 	return 1;
 }
-int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive)
+int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive,
+			    struct logical_volume *lv)
 {
 	return 1;
 }
@@ -347,84 +440,6 @@ int activation(void)
 	return _activation;
 }
 
-static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
-				     const struct dm_config_node *cn, const int cfg_id)
-{
-	const struct dm_config_value *cv;
-	const char *str;
-	static char config_path[PATH_MAX];
-	static char path[PATH_MAX];
-
-	config_def_get_path(config_path, sizeof(config_path), cfg_id);
-	log_verbose("%s configuration setting defined: "
-		    "Checking the list to match %s/%s",
-		    config_path, lv->vg->name, lv->name);
-
-	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type == DM_CFG_EMPTY_ARRAY)
-			goto out;
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Ignoring invalid string in config file %s",
-				  config_path);
-			continue;
-		}
-		str = cv->v.str;
-		if (!*str) {
-			log_error("Ignoring empty string in config file %s",
-				  config_path);
-			continue;
-		}
-
-
-		/* Tag? */
-		if (*str == '@') {
-			str++;
-			if (!*str) {
-				log_error("Ignoring empty tag in config file "
-					  "%s", config_path);
-				continue;
-			}
-			/* If any host tag matches any LV or VG tag, activate */
-			if (!strcmp(str, "*")) {
-				if (str_list_match_list(&cmd->tags, &lv->tags, NULL)
-				    || str_list_match_list(&cmd->tags,
-							   &lv->vg->tags, NULL))
-					    return 1;
-				else
-					continue;
-			}
-			/* If supplied tag matches LV or VG tag, activate */
-			if (str_list_match_item(&lv->tags, str) ||
-			    str_list_match_item(&lv->vg->tags, str))
-				return 1;
-			else
-				continue;
-		}
-		if (!strchr(str, '/')) {
-			/* vgname supplied */
-			if (!strcmp(str, lv->vg->name))
-				return 1;
-			else
-				continue;
-		}
-		/* vgname/lvname */
-		if (dm_snprintf(path, sizeof(path), "%s/%s", lv->vg->name,
-				 lv->name) < 0) {
-			log_error("dm_snprintf error from %s/%s", lv->vg->name,
-				  lv->name);
-			continue;
-		}
-		if (!strcmp(path, str))
-			return 1;
-	}
-
-out:
-	log_verbose("No item supplied in %s configuration setting "
-		    "matches %s/%s", config_path, lv->vg->name, lv->name);
-
-	return 0;
-}
-
 static int _passes_activation_filter(struct cmd_context *cmd,
 				     struct logical_volume *lv)
 {
@@ -465,20 +480,6 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 	return _lv_passes_volumes_filter(cmd, lv, cn, activation_read_only_volume_list_CFG);
 }
 
-
-int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	const struct dm_config_node *cn;
-
-	if (!(cn = find_config_tree_node(cmd, activation_auto_activation_volume_list_CFG, NULL))) {
-		log_verbose("activation/auto_activation_volume_list configuration setting "
-			    "not defined: All logical volumes will be auto-activated.");
-		return 1;
-	}
-
-	return _lv_passes_volumes_filter(cmd, lv, cn, activation_auto_activation_volume_list_CFG);
-}
-
 int library_version(char *version, size_t size)
 {
 	if (!activation())
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5aacea1..cd3b5f9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -137,13 +137,14 @@
 
 #ifdef DEVMAPPER_SUPPORT
 #  define DEFAULT_ACTIVATION 1
-#  define DEFAULT_RESERVED_MEMORY 8192
-#  define DEFAULT_RESERVED_STACK 64 /* KB */
-#  define DEFAULT_PROCESS_PRIORITY -18
 #else
 #  define DEFAULT_ACTIVATION 0
 #endif
 
+# define DEFAULT_RESERVED_MEMORY 8192
+#  define DEFAULT_RESERVED_STACK 64 /* KB */
+#  define DEFAULT_PROCESS_PRIORITY -18
+
 #define DEFAULT_AUTO_SET_ACTIVATION_SKIP 1
 #define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 6d627fe..20e8c1a 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -264,6 +264,46 @@ static int _raid_target_status_compatible(const char *type)
 	return (strstr(type, "raid") != NULL);
 }
 
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
+static void _raid_destroy(struct segment_type *segtype)
+{
+	dm_free((void *) segtype);
+}
+
+#ifdef DEVMAPPER_SUPPORT
+#ifdef DMEVENTD
+static const char *_get_raid_dso_path(struct cmd_context *cmd)
+{
+	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
+	return get_monitor_dso_path(cmd, config_str);
+}
+
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
 static int _raid_target_percent(void **target_state,
 				percent_t *percent,
 				struct dm_pool *mem,
@@ -306,47 +346,6 @@ static int _raid_target_percent(void **target_state,
 	return 1;
 }
 
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
-static void _raid_destroy(struct segment_type *segtype)
-{
-	dm_free((void *) segtype);
-}
-
-#ifdef DEVMAPPER_SUPPORT
-#ifdef DMEVENTD
-static const char *_get_raid_dso_path(struct cmd_context *cmd)
-{
-	const char *config_str = find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL);
-	return get_monitor_dso_path(cmd, config_str);
-}
-
 static int _raid_target_monitored(struct lv_segment *seg, int *pending)
 {
 	struct cmd_context *cmd = seg->lv->vg->cmd;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d559219..531e546 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -41,10 +41,6 @@ static const char _thin_module[] = "thin";
 /* TODO: using static field here, maybe should be a part of segment_type */
 static unsigned _feature_mask;
 
-static int _thin_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg,
-				unsigned *attributes);
-
 static const char *_thin_pool_name(const struct lv_segment *seg)
 {
 	return seg->segtype->name;
@@ -224,6 +220,10 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 }
 
 #ifdef DEVMAPPER_SUPPORT
+static int _thin_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg,
+				unsigned *attributes);
+
 static int _thin_pool_add_target_line(struct dev_manager *dm,
 				      struct dm_pool *mem,
 				      struct cmd_context *cmd,
@@ -381,18 +381,6 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 	return 1;
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
 #  ifdef DMEVENTD
 static const char *_get_thin_dso_path(struct cmd_context *cmd)
 {
@@ -427,6 +415,33 @@ static int _target_unregister_events(struct lv_segment *seg,
 {
 	return _target_set_events(seg, events, 0);
 }
+
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
 #  endif /* DMEVENTD */
 #endif /* DEVMAPPER_SUPPORT */
 
@@ -652,21 +667,6 @@ static int _thin_target_present(struct cmd_context *cmd,
 }
 #endif
 
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
-
 static void _thin_destroy(struct segment_type *segtype)
 {
 	dm_free(segtype);
@@ -687,7 +687,9 @@ static struct segtype_handler _thin_pool_ops = {
 	.target_unmonitor_events = _target_unregister_events,
 #  endif /* DMEVENTD */
 #endif
+#ifdef DEVMAPPER_SUPPORT
 	.modules_needed = _thin_pool_modules_needed,
+#endif
 	.destroy = _thin_destroy,
 };
 
@@ -699,8 +701,8 @@ static struct segtype_handler _thin_ops = {
 	.add_target_line = _thin_add_target_line,
 	.target_percent = _thin_target_percent,
 	.target_present = _thin_target_present,
-#endif
 	.modules_needed = _thin_modules_needed,
+#endif
 	.destroy = _thin_destroy,
 };
 


