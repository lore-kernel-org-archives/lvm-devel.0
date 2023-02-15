From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Feb 2023 22:02:37 +0000 (GMT)
Subject: main - pvscan: filter does not need to be checked for symlink names
Message-ID: <20230215220237.D3DCE3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd05318ba2fc588be6339f5dc61f09195996b0e9
Commit:        bd05318ba2fc588be6339f5dc61f09195996b0e9
Parent:        07cd341bd87a7559f33862a5a7480687b30e5f9c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 10:08:25 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 10:19:57 2023 -0600

pvscan: filter does not need to be checked for symlink names

With the recent use of DEVLINKS, there is no longer any real
point in checking the filter for symlink names.  Removing
this check should not change behavior with or without symlinks
in the filter.
---
 lib/filters/filter-regex.c | 45 ---------------------------------------------
 lib/filters/filter.h       |  2 --
 lib/label/label.c          |  5 +----
 tools/pvscan.c             |  3 +--
 4 files changed, 2 insertions(+), 53 deletions(-)

diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index ecc32914b..5f348674d 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -253,48 +253,3 @@ struct dev_filter *regex_filter_create(const struct dm_config_value *patterns, i
 	dm_pool_destroy(mem);
 	return NULL;
 }
-
-static int _filter_contains_symlink(struct cmd_context *cmd, int filter_cfg)
-{
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
-	const char *fname;
-		
-	if ((cn = find_config_tree_array(cmd, filter_cfg, NULL))) {
-		for (cv = cn->v; cv; cv = cv->next) {
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
-			if (strstr(fname, "pci-"))
-				return 1;
-		}
-	}
-
-	return 0;
-}
-
-int regex_filter_contains_symlink(struct cmd_context *cmd)
-{
-	return _filter_contains_symlink(cmd, devices_filter_CFG) ||
-	       _filter_contains_symlink(cmd, devices_global_filter_CFG);
-}
-
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 0678e5e11..4cdfa2c9b 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -64,6 +64,4 @@ struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_type
 #define DEV_FILTERED_DEVICES_LIST	0x00001000
 #define DEV_FILTERED_IS_LV		0x00002000
 
-int regex_filter_contains_symlink(struct cmd_context *cmd);
-
 #endif 	/* _LVM_FILTER_H */
diff --git a/lib/label/label.c b/lib/label/label.c
index 42d7b6709..c122a4ebb 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1109,10 +1109,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	 * filter.  We get devs from the pvs_online files, so we inherit the
 	 * regex filtering from pvscan and don't have to do it ourself.
 	 */
-	if (!cmd->enable_devices_file &&
-	    !cmd->enable_devices_list &&
-	    regex_filter_contains_symlink(cmd))
-		cmd->filter_regex_skip = 1;
+	cmd->filter_regex_skip = 1;
 
 	cmd->filter_nodata_only = 1;
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 8f60b2522..b834dfd4c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1502,8 +1502,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 */
 	if ((dm_list_size(&pvscan_devs) == 1) &&
 	    !cmd->enable_devices_file &&
-	    !cmd->enable_devices_list &&
-	    regex_filter_contains_symlink(cmd)) {
+	    !cmd->enable_devices_list) {
 		char *env_str;
 		struct dm_list *env_aliases;
 		devl = dm_list_item(dm_list_first(&pvscan_devs), struct device_list);

