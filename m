From: David Teigland <teigland@sourceware.org>
Date: Fri,  1 Apr 2022 18:38:39 +0000 (GMT)
Subject: main - change messages about filtered devices
Message-ID: <20220401183839.69E4E3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8db3b11e4ed94974bc25c26e2f1271c34f6ccf15
Commit:        8db3b11e4ed94974bc25c26e2f1271c34f6ccf15
Parent:        23a9bd549a27cba63c525e7b3042a67e428c798f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 31 11:38:08 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 1 13:38:21 2022 -0500

change messages about filtered devices

Change messages that refer to devices being "excluded by filters"
to say just "excluded".  This will avoid mistaking the word
"filters" with the lvm.conf filter setting.
---
 lib/device/device_id.c | 6 +++---
 lib/label/label.c      | 4 ++--
 tools/lvmdevices.c     | 4 ++--
 tools/pvscan.c         | 4 ++--
 tools/vgimportclone.c  | 4 ++--
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index fa71874d0..0f7c42f79 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1777,7 +1777,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 * probably wants to do something about it.
 		 */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent")) {
-			log_warn("Devices file %s is excluded by filter: %s.",
+			log_warn("Devices file %s is excluded: %s.",
 				 dev_name(dev), dev_filtered_reason(dev));
 			continue;
 		}
@@ -1863,7 +1863,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			continue;
 
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent")) {
-			log_warn("Devices file %s is excluded by filter: %s.",
+			log_warn("Devices file %s is excluded: %s.",
 				 dev_name(dev), dev_filtered_reason(dev));
 			/* FIXME: what if this dev is wrongly matched and should be checked below? */
 			continue;
@@ -2305,7 +2305,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
 			/* I don't think this would happen */
-			log_warn("WARNING: new device %s for PVID %s does not pass filter %s.",
+			log_warn("WARNING: new device %s for PVID %s is excluded: %s.",
 				 dev_name(dev), dil->pvid, dev_filtered_reason(dev));
 			if (du) /* Should not happen 'du' is NULL */
 				du->dev = NULL;
diff --git a/lib/label/label.c b/lib/label/label.c
index e6bc791a7..711edb6f4 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1103,7 +1103,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print("%s excluded by filters: %s.",
+			log_print("%s excluded: %s.",
 				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 			dm_list_add(&devs_drop, &devl->list);
@@ -1169,7 +1169,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 		/* Applies all filters, including those that need data from dev. */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print("%s excluded by filters: %s.",
+			log_print("%s excluded: %s.",
 				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 			dm_list_add(&devs_drop, &devl->list);
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index d30f86b75..b03411b8b 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -113,7 +113,7 @@ static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *sear
 		dev = devl->dev;
 		cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
-			log_warn("WARNING: PVID %s found on %s which is excluded by filter: %s",
+			log_warn("WARNING: PVID %s found on %s which is excluded: %s",
 			 	  dev->pvid, dev_name(dev), dev_filtered_reason(dev));
 			dm_list_del(&devl->list);
 		}
@@ -353,7 +353,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		cmd->filter_deviceid_skip = 1;
 
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
-			log_warn("WARNING: adding device %s that is excluded by filter: %s.",
+			log_warn("WARNING: adding device %s that is excluded: %s.",
 				 dev_name(dev), dev_filtered_reason(dev));
 		}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index db6709a5a..cf1772165 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1542,7 +1542,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print_pvscan(cmd, "%s excluded by filters: %s.",
+			log_print_pvscan(cmd, "%s excluded: %s.",
 					 dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 		}
@@ -1599,7 +1599,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 		/* Applies all filters, including those that need data from dev. */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print_pvscan(cmd, "%s excluded by filters: %s.",
+			log_print_pvscan(cmd, "%s excluded: %s.",
 					 dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 		}
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 23bb6271f..cab501619 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -311,8 +311,8 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	dm_list_iterate_items(devl, &vp.new_devs) {
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, "persistent")) {
-			/* FIXME: print which filter */
-			log_error("Device %s was excluded by filters.", dev_name(devl->dev));
+			log_error("Device %s is excluded: %s.",
+				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			goto out;
 		}
 	}

