From: David Teigland <teigland@sourceware.org>
Date: Tue,  6 Jul 2021 15:18:51 +0000 (GMT)
Subject: main - pvscan: skip indexing devices used by LVs
Message-ID: <20210706151851.02259388E822@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5a06f9a7df5a43b2e2311db62ff8d3011217d74
Commit:        d5a06f9a7df5a43b2e2311db62ff8d3011217d74
Parent:        b876dbfc245b8fe0a4c433b39d214652455c3f9e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 1 17:25:43 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 6 10:18:07 2021 -0500

pvscan: skip indexing devices used by LVs

dev_cache_index_devs() is taking a large amount of time
when there are many PVs.  The index keeps track of
devices that are currently in use by active LVs.  This
info is used to print warnings for users in some limited
cases.

The checks/warnings that are enabled by the index are not
needed by pvscan --cache, so disable it in this case.

This may be expanded to other cases in future commits.
dev_cache_index_devs should also be improved in another
commit to avoid the extreme delays with many devices.
---
 lib/commands/toolcontext.c | 1 +
 lib/commands/toolcontext.h | 1 +
 lib/device/dev-cache.c     | 9 +++++----
 lib/device/dev-cache.h     | 2 +-
 lib/metadata/metadata.c    | 3 ++-
 tools/lvmdevices.c         | 2 +-
 tools/pvscan.c             | 2 ++
 7 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e2be89d0f..b295a20ef 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1608,6 +1608,7 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
 	cmd->hosttags = 0;
+	cmd->check_devs_used = 1;
 	dm_list_init(&cmd->arg_value_groups);
 	dm_list_init(&cmd->formats);
 	dm_list_init(&cmd->segtypes);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index a47b7d760..34808ce46 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -192,6 +192,7 @@ struct cmd_context {
 	unsigned filter_nodata_only:1;          /* only use filters that do not require data from the dev */
 	unsigned run_by_dmeventd:1;		/* command is being run by dmeventd */
 	unsigned sysinit:1;			/* --sysinit is used */
+	unsigned check_devs_used:1;		/* check devs used by LVs */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d7fa93fd6..bb0d0f211 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1139,7 +1139,7 @@ static int _insert(const char *path, const struct stat *info,
 	return 1;
 }
 
-void dev_cache_scan(void)
+void dev_cache_scan(struct cmd_context *cmd)
 {
 	log_debug_devs("Creating list of system devices.");
 
@@ -1147,7 +1147,8 @@ void dev_cache_scan(void)
 
 	_insert_dirs(&_cache.dirs);
 
-	(void) dev_cache_index_devs();
+	if (cmd->check_devs_used)
+		(void) dev_cache_index_devs();
 }
 
 int dev_cache_has_scanned(void)
@@ -1583,7 +1584,7 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 
 		log_debug_devs("Device num not found in dev_cache repeat dev_cache_scan for %d:%d",
 				(int)MAJOR(dev), (int)MINOR(dev));
-		dev_cache_scan();
+		dev_cache_scan(cmd);
 		d = (struct device *) btree_lookup(_cache.devices, (uint32_t) dev);
 
 		if (!d)
@@ -1953,7 +1954,7 @@ int setup_devices(struct cmd_context *cmd)
 	 * This will not open or read any devices, but may look at sysfs properties.
 	 * This list of devs comes from looking /dev entries, or from asking libudev.
 	 */
-	dev_cache_scan();
+	dev_cache_scan(cmd);
 
 	/*
 	 * Match entries from cmd->use_devices with device structs in dev-cache.
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 9b7e39d33..c3f5eddda 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -48,7 +48,7 @@ int dev_cache_exit(void);
  */
 int dev_cache_check_for_open_devices(void);
 
-void dev_cache_scan(void);
+void dev_cache_scan(struct cmd_context *cmd);
 int dev_cache_has_scanned(void);
 
 int dev_cache_add_dir(const char *path);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d5b28a58f..0cbf67869 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5132,7 +5132,8 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	if (!check_pv_dev_sizes(vg))
 		log_warn("WARNING: One or more devices used as PVs in VG %s have changed sizes.", vg->name);
 
-	_check_devs_used_correspond_with_vg(vg);
+	if (cmd->check_devs_used)
+		_check_devs_used_correspond_with_vg(vg);
 
 	if (!_access_vg_lock_type(cmd, vg, lockd_state, &failure)) {
 		/* Either FAILED_LOCK_TYPE or FAILED_LOCK_MODE were set. */
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 3448bdd14..5117277a0 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -171,7 +171,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		log_error("Failed to read the devices file.");
 		return ECMD_FAILED;
 	}
-	dev_cache_scan();
+	dev_cache_scan(cmd);
 	device_ids_match(cmd);
 
 	if (arg_is_set(cmd, check_ARG) || arg_is_set(cmd, update_ARG)) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index f8d27372b..464501ad5 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1627,6 +1627,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	dm_list_init(&complete_vgnames);
 
+	cmd->check_devs_used = 0;
+
 	if (do_activate &&
 	    !find_config_tree_bool(cmd, global_event_activation_CFG, NULL)) {
 		log_verbose("Ignoring pvscan --cache -aay because event_activation is disabled.");


