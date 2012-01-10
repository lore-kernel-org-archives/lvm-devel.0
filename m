From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2012 02:03:33 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/commands/toolcontext.c ...
Message-ID: <20120110020333.11906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-10 02:03:32

Modified files:
	.              : WHATS_NEW_DM 
	lib/commands   : toolcontext.c 
	lib/locking    : locking.c 
	libdm          : libdevmapper.h libdm-common.c libdm-deptree.c 

Log message:
	Add dm_uuid_prefix/dm_set_uuid_prefix for non-lvm users to override hard-coded
	LVM- prefix.
	
	Try harder not to leave stray empty devices around (locally or remotely) when
	reverting changes after failures while there are inactive tables.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.528&r2=1.529
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/WHATS_NEW_DM	2012/01/09 12:28:47	1.528
+++ LVM2/WHATS_NEW_DM	2012/01/10 02:03:31	1.529
@@ -1,11 +1,13 @@
 Version 1.02.68 -
 ==================================
+  Remove empty devices when clearing left-over inactive tables in deptree.
+  Add dm_uuid_prefix/dm_set_uuid_prefix to override hard-coded LVM- prefix.
   Improve dmsetup man page about readahead parameter.
   Use sysfs to set/get of read-ahead setting if possible.
   Fix lvm2-monitor init script to use normalized output when using vgs.
   Add test for max length (DM_MAX_TYPE_NAME) of target type name.
   Include a copy of kernel DM documentation in doc/kernel.
-  Improve man page style for dmsetup.
+  Improve man page style for dmsetup and mention more targets.
   Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
   Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
   Add dm_config_tree_find_str_allow_empty and dm_config_find_str_allow_empty.
--- LVM2/lib/commands/toolcontext.c	2011/12/18 21:56:03	1.144
+++ LVM2/lib/commands/toolcontext.c	2012/01/10 02:03:31	1.145
@@ -246,6 +246,9 @@
 	}
 #ifdef DEVMAPPER_SUPPORT
 	dm_set_dev_dir(cmd->dev_dir);
+
+	if (!dm_set_uuid_prefix("LVM-"))
+		return_0;
 #endif
 
 	/* proc dir */
--- LVM2/lib/locking/locking.c	2011/09/27 22:43:41	1.100
+++ LVM2/lib/locking/locking.c	2012/01/10 02:03:32	1.101
@@ -515,7 +515,6 @@
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
 		struct volume_group *vg_to_revert)
 {
-	struct dm_list *lvh;
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs) {
@@ -523,11 +522,15 @@
 			log_error("Failed to suspend %s", lvl->lv->name);
 			if (vg_to_revert)
 				vg_revert(vg_to_revert);
-			dm_list_uniterate(lvh, lvs, &lvl->list) {
-				lvl = dm_list_item(lvh, struct lv_list);
+			/*
+			 * FIXME Should be
+			 * 	dm_list_uniterate(lvh, lvs, &lvl->list) {
+			 *	lvl = dm_list_item(lvh, struct lv_list);
+			 * but revert would need fixing to use identical tree deps first.
+			 */
+			dm_list_iterate_items(lvl, lvs)
 				if (!revert_lv(cmd, lvl->lv))
 					stack;
-			}
 
 			return 0;
 		}
--- LVM2/libdm/libdevmapper.h	2011/12/21 12:52:38	1.173
+++ LVM2/libdm/libdevmapper.h	2012/01/10 02:03:32	1.174
@@ -285,6 +285,16 @@
 const char *dm_sysfs_dir(void);
 
 /*
+ * Configure default UUID prefix string.
+ * Conventionally this is a short capitalised prefix indicating the subsystem
+ * that is managing the devices, e.g. "LVM-" or "MPATH-".
+ * To support stacks of devices from different subsystems, recursive functions
+ * stop recursing if they reach a device with a different prefix.
+ */
+int dm_set_uuid_prefix(const char *uuid_prefix);
+const char *dm_uuid_prefix(void);
+
+/*
  * Determine whether a major number belongs to device-mapper or not.
  */
 int dm_is_dm_major(uint32_t major);
--- LVM2/libdm/libdm-common.c	2012/01/09 12:26:15	1.130
+++ LVM2/libdm/libdm-common.c	2012/01/10 02:03:32	1.131
@@ -61,6 +61,9 @@
 static char _sysfs_dir[PATH_MAX] = "/sys/";
 static char _path0[PATH_MAX];           /* path buffer, safe 4kB on stack */
 
+#define DM_MAX_UUID_PREFIX_LEN	15
+static char _default_uuid_prefix[DM_MAX_UUID_PREFIX_LEN + 1] = "LVM-";
+
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
 
@@ -1139,6 +1142,29 @@
 	return _sysfs_dir;
 }
 
+/*
+ * Replace existing uuid_prefix provided it isn't too long.
+ */
+int dm_set_uuid_prefix(const char *uuid_prefix)
+{
+	if (!uuid_prefix)
+		return_0;
+
+	if (strlen(uuid_prefix) > DM_MAX_UUID_PREFIX_LEN) {
+		log_error("New uuid prefix %s too long.", uuid_prefix);
+		return 0;
+	}
+
+	strcpy(_default_uuid_prefix, uuid_prefix);
+
+	return 1;
+}
+
+const char *dm_uuid_prefix(void)
+{
+	return _default_uuid_prefix;
+}
+
 int dm_device_has_holders(uint32_t major, uint32_t minor)
 {
 	char sysfs_path[PATH_MAX];
--- LVM2/libdm/libdm-deptree.c	2011/12/21 12:52:38	1.147
+++ LVM2/libdm/libdm-deptree.c	2012/01/10 02:03:32	1.148
@@ -24,9 +24,6 @@
 
 #define MAX_TARGET_PARAMSIZE 500000
 
-/* FIXME Fix interface so this is used only by LVM */
-#define UUID_PREFIX "LVM-"
-
 #define REPLICATOR_LOCAL_SITE 0
 
 /* Supported segment types */
@@ -488,25 +485,32 @@
 						       const char *uuid)
 {
 	struct dm_tree_node *node;
+	const char *default_uuid_prefix;
+	size_t default_uuid_prefix_len;
 
 	if ((node = dm_hash_lookup(dtree->uuids, uuid)))
 		return node;
 
-	if (strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1))
+	default_uuid_prefix = dm_uuid_prefix();
+	default_uuid_prefix_len = strlen(default_uuid_prefix);
+
+	if (strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
 		return NULL;
 
-	return dm_hash_lookup(dtree->uuids, uuid + sizeof(UUID_PREFIX) - 1);
+	return dm_hash_lookup(dtree->uuids, uuid + default_uuid_prefix_len);
 }
 
 static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint32_t minor,
-		 const char **name, const char **uuid,
+		 const char **name, const char **uuid, unsigned inactive_table,
 		 struct dm_info *info, struct dm_deps **deps)
 {
 	memset(info, 0, sizeof(*info));
 
 	if (!dm_is_dm_major(major)) {
-		*name = "";
-		*uuid = "";
+		if (name)
+			*name = "";
+		if (uuid)
+			*uuid = "";
 		*deps = NULL;
 		info->major = major;
 		info->minor = minor;
@@ -534,6 +538,12 @@
 		goto failed;
 	}
 
+	if (inactive_table && !dm_task_query_inactive_table(*dmt)) {
+		log_error("_deps: failed to set inactive table for (%" PRIu32 ":%" PRIu32 ")",
+			  major, minor);
+		goto failed;
+	}
+
 	if (!dm_task_run(*dmt)) {
 		log_error("_deps: task run failed for (%" PRIu32 ":%" PRIu32 ")",
 			  major, minor);
@@ -547,8 +557,10 @@
 	}
 
 	if (!info->exists) {
-		*name = "";
-		*uuid = "";
+		if (name)
+			*name = "";
+		if (uuid)
+			*uuid = "";
 		*deps = NULL;
 	} else {
 		if (info->major != major) {
@@ -561,11 +573,11 @@
 				  minor, info->minor);
 			goto failed;
 		}
-		if (!(*name = dm_pool_strdup(mem, dm_task_get_name(*dmt)))) {
+		if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(*dmt)))) {
 			log_error("name pool_strdup failed");
 			goto failed;
 		}
-		if (!(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(*dmt)))) {
+		if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(*dmt)))) {
 			log_error("uuid pool_strdup failed");
 			goto failed;
 		}
@@ -595,7 +607,7 @@
 
 	/* Already in tree? */
 	if (!(node = _find_dm_tree_node(dtree, major, minor))) {
-		if (!_deps(&dmt, dtree->mem, major, minor, &name, &uuid, &info, &deps))
+		if (!_deps(&dmt, dtree->mem, major, minor, &name, &uuid, 0, &info, &deps))
 			return_NULL;
 
 		if (!(node = _create_dm_tree_node(dtree, name, uuid, &info,
@@ -637,12 +649,22 @@
 	return node;
 }
 
-static int _node_clear_table(struct dm_tree_node *dnode)
+// FIXME Move fn group down.
+static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
+			struct dm_info *info, struct dm_pool *mem,
+			const char **name, const char **uuid);
+static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
+			    uint32_t *cookie, uint16_t udev_flags, int retry);
+static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 {
-	struct dm_task *dmt;
-	struct dm_info *info;
-	const char *name;
-	int r;
+	struct dm_task *dmt = NULL, *deps_dmt = NULL;
+	struct dm_info *info, deps_info;
+	struct dm_deps *deps = NULL;
+	const char *name, *uuid;
+	const char *default_uuid_prefix;
+	size_t default_uuid_prefix_len;
+	uint32_t i;
+	int r = 0;
 
 	if (!(info = &dnode->info)) {
 		log_error("_node_clear_table failed: missing info");
@@ -658,21 +680,24 @@
 	if (!info->exists || !info->inactive_table)
 		return 1;
 
-// FIXME Get inactive deps.  If any dev referenced has 1 opener and no live table, remove it after the clear.
+	/* Get devices used by inactive table that's about to be deleted. */
+	if (!_deps(&deps_dmt, dnode->dtree->mem, info->major, info->minor, NULL, NULL, 1, info, &deps)) {
+		log_error("Failed to obtain dependencies for %s before clearing table.", name);
+		return 0;
+	}
 
 	log_verbose("Clearing inactive table %s (%" PRIu32 ":%" PRIu32 ")",
 		    name, info->major, info->minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CLEAR))) {
 		log_error("Table clear dm_task creation failed for %s", name);
-		return 0;
+		goto_out;
 	}
 
 	if (!dm_task_set_major(dmt, info->major) ||
 	    !dm_task_set_minor(dmt, info->minor)) {
 		log_error("Failed to set device number for %s table clear", name);
-		dm_task_destroy(dmt);
-		return 0;
+		goto_out;
 	}
 
 	r = dm_task_run(dmt);
@@ -682,18 +707,60 @@
 		r = 0;
 	}
 
-	dm_task_destroy(dmt);
+	if (!r || !deps)
+		goto_out;
+
+	/*
+	 * Remove (incomplete) devices that the inactive table referred to but
+	 * which are not in the tree, no longer referenced and don't have a live
+	 * table.
+	 */
+	default_uuid_prefix = dm_uuid_prefix();
+	default_uuid_prefix_len = strlen(default_uuid_prefix);
+
+	for (i = 0; i < deps->count; i++) {
+		/* If already in tree, assume it's under control */
+		if (_find_dm_tree_node(dnode->dtree, MAJOR(deps->device[i]), MINOR(deps->device[i])))
+			continue;
+
+		if (!_info_by_dev(MAJOR(deps->device[i]), MINOR(deps->device[i]), 1,
+				  &deps_info, dnode->dtree->mem, &name, &uuid))
+			continue;
+
+		/* Proceed if device is an 'orphan' - unreferenced and without a live table. */
+		if (!deps_info.exists || deps_info.live_table || deps_info.open_count)
+			continue;
+
+		if (strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
+			continue;
+
+		/* Remove device. */
+		if (!_deactivate_node(name, deps_info.major, deps_info.minor, &dnode->dtree->cookie, udev_flags, 0)) {
+			log_error("Failed to deactivate no-longer-used device %s (%"
+				  PRIu32 ":%" PRIu32 ")", name, deps_info.major, deps_info.minor);
+		} else if (deps_info.suspended)
+			dec_suspended();
+	}
+
+out:
+	if (dmt)
+		dm_task_destroy(dmt);
+
+	if (deps_dmt)
+		dm_task_destroy(deps_dmt);
 
 	return r;
 }
 
-struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree,
-					    const char *name,
-					    const char *uuid,
-					    uint32_t major, uint32_t minor,
-					    int read_only,
-					    int clear_inactive,
-					    void *context)
+struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
+							 const char *name,
+							 const char *uuid,
+							 uint32_t major,
+							 uint32_t minor,
+							 int read_only,
+							 int clear_inactive,
+							 void *context,
+							 uint16_t udev_flags)
 {
 	struct dm_tree_node *dnode;
 	struct dm_info info;
@@ -734,7 +801,7 @@
 		/* Do we need to rename node? */
 		if (!(dnode->props.new_name = dm_pool_strdup(dtree->mem, name))) {
 			log_error("name pool_strdup failed");
-			return 0;
+			return NULL;
 		}
 	}
 
@@ -742,32 +809,21 @@
 	dnode->props.read_ahead = DM_READ_AHEAD_AUTO;
 	dnode->props.read_ahead_flags = 0;
 
-	if (clear_inactive && !_node_clear_table(dnode))
+	if (clear_inactive && !_node_clear_table(dnode, udev_flags))
 		return_NULL;
 
 	dnode->context = context;
-	dnode->udev_flags = 0;
+	dnode->udev_flags = udev_flags;
 
 	return dnode;
 }
 
-struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
-							 const char *name,
-							 const char *uuid,
-							 uint32_t major,
-							 uint32_t minor,
-							 int read_only,
-							 int clear_inactive,
-							 void *context,
-							 uint16_t udev_flags)
+struct dm_tree_node *dm_tree_add_new_dev(struct dm_tree *dtree, const char *name,
+					 const char *uuid, uint32_t major, uint32_t minor,
+					 int read_only, int clear_inactive, void *context)
 {
-	struct dm_tree_node *node;
-
-	if ((node = dm_tree_add_new_dev(dtree, name, uuid, major, minor, read_only,
-				       clear_inactive, context)))
-		node->udev_flags = udev_flags;
-
-	return node;
+	return dm_tree_add_new_dev_with_udev_flags(dtree, name, uuid, major, minor,
+						   read_only, clear_inactive, context, 0);
 }
 
 void dm_tree_node_set_udev_flags(struct dm_tree_node *dnode, uint16_t udev_flags)
@@ -852,6 +908,9 @@
  */
 static int _uuid_prefix_matches(const char *uuid, const char *uuid_prefix, size_t uuid_prefix_len)
 {
+	const char *default_uuid_prefix = dm_uuid_prefix();
+	size_t default_uuid_prefix_len = strlen(default_uuid_prefix);
+
 	if (!uuid_prefix)
 		return 1;
 
@@ -862,13 +921,13 @@
 	if (uuid_prefix_len <= 4)
 		return 0;
 
-	if (!strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1))
+	if (!strncmp(uuid, default_uuid_prefix, default_uuid_prefix_len))
 		return 0;
 
-	if (strncmp(uuid_prefix, UUID_PREFIX, sizeof(UUID_PREFIX) - 1))
+	if (strncmp(uuid_prefix, default_uuid_prefix, default_uuid_prefix_len))
 		return 0;
 
-	if (!strncmp(uuid, uuid_prefix + sizeof(UUID_PREFIX) - 1, uuid_prefix_len - (sizeof(UUID_PREFIX) - 1)))
+	if (!strncmp(uuid, uuid_prefix + default_uuid_prefix_len, uuid_prefix_len - default_uuid_prefix_len))
 		return 1;
 
 	return 0;
@@ -976,7 +1035,8 @@
  * Deactivate a device with its dependencies if the uuid prefix matches.
  */
 static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
-			struct dm_info *info)
+			struct dm_info *info, struct dm_pool *mem,
+			const char **name, const char **uuid)
 {
 	struct dm_task *dmt;
 	int r;
@@ -995,9 +1055,25 @@
 	if (!with_open_count && !dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if ((r = dm_task_run(dmt)))
-		r = dm_task_get_info(dmt, info);
+	if (!(r = dm_task_run(dmt)))
+		goto_out;
+
+	if (!(r = dm_task_get_info(dmt, info)))
+		goto_out;
 
+	if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(dmt)))) {
+		log_error("name pool_strdup failed");
+		r = 0;
+		goto_out;
+	}
+
+	if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(dmt)))) {
+		log_error("uuid pool_strdup failed");
+		r = 0;
+		goto_out;
+	}
+
+out:
 	dm_task_destroy(dmt);
 
 	return r;
@@ -1061,7 +1137,7 @@
 		}
 
 		/* Refresh open_count */
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
 		    !info.exists)
 			continue;
 
@@ -1096,9 +1172,9 @@
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
 
-	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
-		goto out;
-
+	if (cookie)
+		if (!dm_task_set_cookie(dmt, cookie, udev_flags))
+			goto out;
 
 	if (retry)
 		dm_task_retry_remove(dmt);
@@ -1107,7 +1183,7 @@
 
 	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
 	rm_dev_node(name, dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG),
-			  dmt->cookie_set && (udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
+		    dmt->cookie_set && (udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
 
 	/* FIXME Remove node from tree or mark invalid? */
 
@@ -1440,7 +1516,7 @@
 			continue;
 
 		/* Refresh open_count */
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
 		    !info.exists)
 			continue;
 
@@ -1564,7 +1640,7 @@
 		if (!_children_suspended(child, 1, uuid_prefix, uuid_prefix_len))
 			continue;
 
-		if (!_info_by_dev(dinfo->major, dinfo->minor, 0, &info) ||
+		if (!_info_by_dev(dinfo->major, dinfo->minor, 0, &info, NULL, NULL, NULL) ||
 		    !info.exists || info.suspended)
 			continue;
 


