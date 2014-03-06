From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:20:59 +0000 (UTC)
Subject: master - config: runtime default for devices/cache, devices/cache_dir
Message-ID: <20140306112059.99C8660C21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6adef9825710ad93f96474a9719ef9fcf655721
Commit:        f6adef9825710ad93f96474a9719ef9fcf655721
Parent:        b53ec372864cea412505327012cc46dc06dec366
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 3 12:47:32 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 11:07:54 2014 +0100

config: runtime default for devices/cache, devices/cache_dir

The devices/cache and devices/cache_dir are evaluated in runtime this way:

  - if devices/cache is set, use it

  - if devices_cache/dir or devices/cache_file_prefix is set, make up a
    path out of that for devices/cache in runtime, taking into account
    the LVM_SYSTEM_DIR environment variable if set

  - otherwise make up the path out of default which is:
    <LVM_SYSTEM_DIR>/<cache_dir>/<cache_file_prefix>.cache

With the runtime defaults, we can encode this easily now. Also, the lvm
dumpconfig can show proper and exact information about this setting then
(the variant that shows default values).
---
 lib/commands/toolcontext.c   |   32 ++--------------------------
 lib/config/config.c          |   46 ++++++++++++++++++++++++++++++++++++++++++
 lib/config/config.h          |    7 ++++++
 lib/config/config_settings.h |    6 ++--
 4 files changed, 59 insertions(+), 32 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ce1f5af..4b3d265 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -893,8 +893,7 @@ bad:
 
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
-	static char cache_file[PATH_MAX];
-	const char *dev_cache = NULL, *cache_dir, *cache_file_prefix;
+	const char *dev_cache;
 	struct dev_filter *f3 = NULL, *f4 = NULL, *toplevel_components[2] = { 0 };
 	struct stat st;
 	const struct dm_config_node *cn;
@@ -907,33 +906,8 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG, NULL));
 	init_ignore_lvm_mirrors(find_config_tree_bool(cmd, devices_ignore_lvm_mirrors_CFG, NULL));
 
-	/*
-	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.
-	 */
-	cache_dir = find_config_tree_str(cmd, devices_cache_dir_CFG, NULL);
-	cache_file_prefix = find_config_tree_str(cmd, devices_cache_file_prefix_CFG, NULL);
-
-	if (cache_dir || cache_file_prefix) {
-		if (dm_snprintf(cache_file, sizeof(cache_file),
-		    "%s%s%s/%s.cache",
-		    cache_dir ? "" : cmd->system_dir,
-		    cache_dir ? "" : "/",
-		    cache_dir ? : DEFAULT_CACHE_SUBDIR,
-		    cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
-			log_error("Persistent cache filename too long.");
-			goto bad;
-		}
-	} else if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)) &&
-		   (dm_snprintf(cache_file, sizeof(cache_file),
-				"%s/%s/%s.cache",
-				cmd->system_dir, DEFAULT_CACHE_SUBDIR,
-				DEFAULT_CACHE_FILE_PREFIX) < 0)) {
-		log_error("Persistent cache filename too long.");
-		goto bad;
-	}
-
-	if (!dev_cache)
-		dev_cache = cache_file;
+	if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)))
+		goto_bad;
 
 	if (!(f4 = persistent_filter_create(cmd->dev_types, f3, dev_cache))) {
 		log_verbose("Failed to create persistent device filter.");
diff --git a/lib/config/config.c b/lib/config/config.c
index 5c6b5ba..65a2ba8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1602,3 +1602,49 @@ int load_pending_profiles(struct cmd_context *cmd)
 
 	return 1;
 }
+
+const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	static char buf[PATH_MAX];
+
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s/", cmd->system_dir, DEFAULT_CACHE_SUBDIR) < 0) {
+		log_error("Persistent cache directory name too long.");
+		return NULL;
+	}
+
+	return dm_pool_strdup(cmd->mem, buf);
+}
+
+const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	const char *cache_dir = NULL, *cache_file_prefix = NULL;
+	static char buf[PATH_MAX];
+
+	/*
+	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.
+	*/
+	if (find_config_tree_node(cmd, devices_cache_dir_CFG, profile))
+		cache_dir = find_config_tree_str(cmd, devices_cache_dir_CFG, profile);
+	if (find_config_tree_node(cmd, devices_cache_file_prefix_CFG, profile))
+		cache_file_prefix = find_config_tree_str_allow_empty(cmd, devices_cache_file_prefix_CFG, profile);
+
+	if (cache_dir || cache_file_prefix) {
+		if (dm_snprintf(buf, sizeof(buf),
+				"%s%s%s/%s.cache",
+				cache_dir ? "" : cmd->system_dir,
+				cache_dir ? "" : "/",
+				cache_dir ? : DEFAULT_CACHE_SUBDIR,
+				cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
+			log_error("Persistent cache filename too long.");
+			return NULL;
+		}
+		return dm_pool_strdup(cmd->mem, buf);
+	}
+
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s/%s.cache", cmd->system_dir,
+			DEFAULT_CACHE_SUBDIR, DEFAULT_CACHE_FILE_PREFIX) < 0) {
+		log_error("Persistent cache filename too long.");
+		return NULL;
+	}
+	return dm_pool_strdup(cmd->mem, buf);
+}
diff --git a/lib/config/config.h b/lib/config/config.h
index aec72a0..b7e0a16 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -226,4 +226,11 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile);
 
+/*
+ * Functions for individual configuration settings for
+ * which the default value is evaluated at runtime.
+ */
+const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profile *profile);
+
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8d3d304..fd59328 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -92,9 +92,9 @@ cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", de
 cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL)
-cfg(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
-cfg(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
-cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL)
+cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), NULL)
+cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), NULL)
+cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19), NULL)
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL)
 cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL)


