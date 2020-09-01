From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:33 +0000 (GMT)
Subject: master - gcc: avoid shadowing of dev_name and pvs
Message-ID: <20200901214133.D72043870874@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc13c7d2469d1c3fc1f8d76f9f93c9d594496bf0
Commit:        bc13c7d2469d1c3fc1f8d76f9f93c9d594496bf0
Parent:        672d5ad98b289663b51b2e34f5fb937c64222abb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 21:17:14 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

gcc: avoid shadowing of dev_name and pvs

Since we declare dev_name in lib/device/device.h
and pvs in commands.h
rename local dev_name to device_name
and pvs to pvs_list to prevent shadowing warning.

m
---
 tools/lvconvert.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 04ec1ee4f..0adc61e36 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4267,7 +4267,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 	char format[NAME_LEN];
 	struct dm_list *use_pvh;
 	struct pv_list *pvl;
-	char *dev_name;
+	char *device_name;
 	struct device *dev_fast;
 	char *dev_argv[MAX_CACHEDEVS];
 	int dev_argc = 0;
@@ -4301,10 +4301,10 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 		if (!grouped_arg_is_set(group->arg_values, cachedevice_ARG))
 			continue;
 
-		if (!(dev_name = (char *)grouped_arg_str_value(group->arg_values, cachedevice_ARG, NULL)))
+		if (!(device_name = (char *)grouped_arg_str_value(group->arg_values, cachedevice_ARG, NULL)))
 			break;
 
-		if (dev_name[0] == '@') {
+		if (device_name[0] == '@') {
 			if (!cache_size_sectors) {
 				log_error("With tag as cachedevice, --cachesize is required.");
 				return 0;
@@ -4312,13 +4312,13 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 			goto add_dev_arg;
 		}
 
-		if (!(dev_fast = dev_cache_get(cmd, dev_name, cmd->filter))) {
-			log_error("Device %s not found.", dev_name);
+		if (!(dev_fast = dev_cache_get(cmd, device_name, cmd->filter))) {
+			log_error("Device %s not found.", device_name);
 			return 0;
 		}
 
-		if (!(pvl = find_pv_in_vg(vg, dev_name))) {
-			log_error("PV %s not found in VG.", dev_name);
+		if (!(pvl = find_pv_in_vg(vg, device_name))) {
+			log_error("PV %s not found in VG.", device_name);
 			return 0;
 		}
 
@@ -4328,7 +4328,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 		 * entire dev should be used.
 		 */
 		if (!cache_size_sectors && pvl->pv->pe_alloc_count) {
-			log_error("PV %s is in use, --cachesize is required.", dev_name);
+			log_error("PV %s is in use, --cachesize is required.", device_name);
 			return 0;
 		}
 
@@ -4337,7 +4337,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 
 			if (!arg_is_set(cmd, yes_ARG) &&
 			    yes_no_prompt("Use all %s from %s for cache? [y/n]: ",
-					  display_size(cmd, pv_size_sectors), dev_name) == 'n') {
+					  display_size(cmd, pv_size_sectors), device_name) == 'n') {
 				log_print("Use --cachesize SizeMB to use a part of the cachedevice.");
 				log_error("Conversion aborted.");
 				return 0;
@@ -4350,7 +4350,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 			return 0;
 		}
 
-		dev_argv[dev_argc++] = dev_name;
+		dev_argv[dev_argc++] = device_name;
 	}
 
 	if (!cache_size_sectors)
@@ -4362,7 +4362,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 	}
 
 	if (!(use_pvh = create_pv_list(cmd->mem, vg, dev_argc, dev_argv, 1))) {
-		log_error("cachedevice not found in VG %s.", dev_name);
+		log_error("cachedevice not found in VG %s.", device_name);
 		return 0;
 	}
 
@@ -5607,7 +5607,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 {
 	char pathname[PATH_MAX];
 	struct device *fs_dev;
-	struct dm_list pvs;
+	struct dm_list pvs_list;
 	struct pv_list *pvl;
 	uint32_t fs_block_size = 0;
 	uint32_t block_size_setting = 0;
@@ -5620,14 +5620,14 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	if (*block_size_sectors)
 		block_size_setting = *block_size_sectors * 512;
 
-	dm_list_init(&pvs);
+	dm_list_init(&pvs_list);
 
-	if (!get_pv_list_for_lv(cmd->mem, lv, &pvs)) {
+	if (!get_pv_list_for_lv(cmd->mem, lv, &pvs_list)) {
 		log_error("Failed to build list of PVs for %s.", display_lvname(lv));
 		goto_bad;
 	}
 
-	dm_list_iterate_items(pvl, &pvs) {
+	dm_list_iterate_items(pvl, &pvs_list) {
 		unsigned int pbs = 0;
 		unsigned int lbs = 0;
 


