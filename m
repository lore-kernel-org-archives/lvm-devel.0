From: David Teigland <teigland@sourceware.org>
Date: Tue, 31 Jan 2023 21:30:55 +0000 (GMT)
Subject: main - vgchange autoactivation: skip regex filter containing symlinks
Message-ID: <20230131213055.416CE3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9fdc828ff0504bc2e57f65862bc382f7663a8a2
Commit:        c9fdc828ff0504bc2e57f65862bc382f7663a8a2
Parent:        17a3585cbb55d9a15ced9775a18b50c53a50ee8e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 27 15:56:06 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 31 15:30:35 2023 -0600

vgchange autoactivation: skip regex filter containing symlinks

"vgchange -aay --autoactivation event" is called by our udev rule.
When the udev rule runs, symlinks for devices may not all be created
yet.  If the regex filter contains symlinks, it won't work correctly.
This command uses devices that already passed through pvscan.  Since
pvscan applies the regex filter correctly, this command inherits the
filtering from pvscan and can skip the regex filter itself.

See the previous commit
"pvscan: use alternate device names from DEVLINKS to check filter"
---
 lib/commands/toolcontext.h |  1 +
 lib/filters/filter-regex.c | 46 +++++++++++++++++++++++++++++++++++++++++++
 lib/filters/filter.h       |  2 ++
 lib/label/label.c          | 17 ++++++++++++++++
 tools/pvscan.c             | 49 +++-------------------------------------------
 tools/vgchange.c           |  1 +
 6 files changed, 70 insertions(+), 46 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4069b6116..b5c1d8a90 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -194,6 +194,7 @@ struct cmd_context {
 	unsigned create_edit_devices_file:1;	/* command expects to create and/or edit devices file */
 	unsigned edit_devices_file:1;		/* command expects to edit devices file */
 	unsigned filter_deviceid_skip:1;	/* don't use filter-deviceid */
+	unsigned filter_regex_skip:1;		/* don't use filter-regex */
 	unsigned filter_regex_with_devices_file:1; /* use filter-regex even when devices file is enabled */
 	unsigned filter_nodata_only:1;          /* only use filters that do not require data from the dev */
 	unsigned run_by_dmeventd:1;		/* command is being run by dmeventd */
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index d9ed0104c..40dc8aa1b 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -161,6 +161,9 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 	if (cmd->enable_devices_list)
 		return 1;
 
+	if (cmd->filter_regex_skip)
+		return 1;
+
 	if (cmd->enable_devices_file && !cmd->filter_regex_with_devices_file) {
 		/* can't warn in create_filter because enable_devices_file is set later */
 		if (rf->config_filter && !rf->warned_filter) {
@@ -250,3 +253,46 @@ struct dev_filter *regex_filter_create(const struct dm_config_value *patterns, i
 	dm_pool_destroy(mem);
 	return NULL;
 }
+
+static int _filter_contains_symlink(struct cmd_context *cmd, int filter_cfg)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *fname;
+		
+	if ((cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
+		for (cv = cn->v; cv; cv = cv->next) {
+			if (cv->type != DM_CFG_STRING)
+				continue;
+			if (!cv->v.str)
+				continue;
+			
+			fname = cv->v.str;
+		
+			if (fname[0] != 'a')
+				continue;
+	
+			if (strstr(fname, "/dev/disk/"))
+				return 1;
+			if (strstr(fname, "/dev/mapper/"))
+				return 1;
+		
+			/* In case /dev/disk/by was omitted */
+			if (strstr(fname, "lvm-pv-uuid"))
+				return 1;
+			if (strstr(fname, "dm-uuid"))
+				return 1;
+			if (strstr(fname, "wwn-"))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+int regex_filter_contains_symlink(struct cmd_context *cmd)
+{
+	return _filter_contains_symlink(cmd, devices_filter_CFG) ||
+	       _filter_contains_symlink(cmd, devices_global_filter_CFG);
+}
+
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 4cdfa2c9b..0678e5e11 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -64,4 +64,6 @@ struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_type
 #define DEV_FILTERED_DEVICES_LIST	0x00001000
 #define DEV_FILTERED_IS_LV		0x00002000
 
+int regex_filter_contains_symlink(struct cmd_context *cmd);
+
 #endif 	/* _LVM_FILTER_H */
diff --git a/lib/label/label.c b/lib/label/label.c
index f845abb96..42d7b6709 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -27,6 +27,7 @@
 #include "lib/format_text/layout.h"
 #include "lib/device/device_id.h"
 #include "lib/device/online.h"
+#include "lib/filters/filter.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -1099,6 +1100,20 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 		log_debug("Skipping device_id filtering due to devname ids.");
 	}
 
+	/*
+	 * See corresponding code in pvscan.  This function is used during
+	 * startup autoactivation when udev has not created all symlinks, so
+	 * regex filter containing symlinks doesn't work.  pvscan has code
+	 * to properly check devs against the filter using DEVLINKS.  The
+	 * pvscan will only create pvs_online files for devs that pass the
+	 * filter.  We get devs from the pvs_online files, so we inherit the
+	 * regex filtering from pvscan and don't have to do it ourself.
+	 */
+	if (!cmd->enable_devices_file &&
+	    !cmd->enable_devices_list &&
+	    regex_filter_contains_symlink(cmd))
+		cmd->filter_regex_skip = 1;
+
 	cmd->filter_nodata_only = 1;
 
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
@@ -1179,6 +1194,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	if (relax_deviceid_filter)
 		cmd->filter_deviceid_skip = 0;
 
+	cmd->filter_regex_skip = 0;
+
 	free_po_list(&pvs_online);
 
 	if (dm_list_empty(&devs)) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 71485610b..8f60b2522 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -803,49 +803,6 @@ out:
 	return ret;
 }
 
-/*
- * The optimization in which only the pvscan arg devname is added to dev-cache
- * does not work if there's an lvm.conf filter containing symlinks to the dev
- * like /dev/disk/by-id/lvm-pv-uuid-xyz entries.  A full dev_cache_scan will
- * associate the symlinks with the system dev name passed to pvscan, which lets
- * filter-regex match the devname with the symlink name in the filter.
- */
-static int _filter_uses_symlinks(struct cmd_context *cmd, int filter_cfg)
-{
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
-	const char *fname;
-
-	if ((cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
-        	for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING)
-				continue;
-			if (!cv->v.str)
-				continue;
-
-			fname = cv->v.str;
-
-			if (fname[0] != 'a')
-				continue;
-
-			if (strstr(fname, "/dev/disk/"))
-				return 1;
-			if (strstr(fname, "/dev/mapper/"))
-				return 1;
-
-			/* In case /dev/disk/by was omitted */
-			if (strstr(fname, "lvm-pv-uuid"))
-				return 1;
-			if (strstr(fname, "dm-uuid"))
-				return 1;
-			if (strstr(fname, "wwn-"))
-				return 1;
-		}
-	}
-
-	return 0;
-}
-
 struct pvscan_arg {
 	struct dm_list list;
 	const char *devname;
@@ -1544,9 +1501,9 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 * be usable by that symlink name yet.
 	 */
 	if ((dm_list_size(&pvscan_devs) == 1) &&
-	    !cmd->enable_devices_file && !cmd->enable_devices_list &&
-	    (_filter_uses_symlinks(cmd, devices_filter_CFG) ||
-	     _filter_uses_symlinks(cmd, devices_global_filter_CFG))) {
+	    !cmd->enable_devices_file &&
+	    !cmd->enable_devices_list &&
+	    regex_filter_contains_symlink(cmd)) {
 		char *env_str;
 		struct dm_list *env_aliases;
 		devl = dm_list_item(dm_list_first(&pvscan_devs), struct device_list);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 09ade96a6..7d1bbd70a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -16,6 +16,7 @@
 #include "tools.h"
 #include "lib/device/device_id.h"
 #include "lib/label/hints.h"
+#include "lib/filters/filter.h"
 
 struct vgchange_params {
 	int lock_start_count;

