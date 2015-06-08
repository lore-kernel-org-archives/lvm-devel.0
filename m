From: Lidong Zhong <lzhong@suse.com>
Date: Mon,  8 Jun 2015 15:48:32 +0800
Subject: [RFC 6/6] lvconvert: implement the wait policy
In-Reply-To: <1433749712-11837-1-git-send-email-lzhong@suse.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
Message-ID: <1433749712-11837-7-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Based on udev, we wait for the missing device in a fixed time, otherwise
it will work according to the original policy set.
---
 tools/lvconvert.c | 282 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 271 insertions(+), 11 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8fcbefd..47564de 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -16,6 +16,9 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
+#include "lvm-wrappers.h"
+#include <blkid/blkid.h>
+#include <libudev.h>
 
 struct lvconvert_params {
 	int cache;
@@ -925,6 +928,13 @@ static struct logical_volume *_original_lv(struct logical_volume *lv)
 	return next_lv;
 }
 
+/*
+ * replace_log/replace_mirrors value
+ * 0: remove
+ * 1: replace
+ * 2: wait+remove
+ * 3: wait+replace
+ */
 static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 					  int failed_log, int failed_mirrors,
 					  int *replace_log, int *replace_mirrors)
@@ -932,12 +942,20 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 	const char *leg_policy, *log_policy;
 	int force = arg_count(cmd, force_ARG);
 	int yes = arg_count(cmd, yes_ARG);
+	int keep_log = 0;
 
 	if (arg_count(cmd, use_policies_ARG)) {
 		leg_policy = find_config_tree_str(cmd, activation_mirror_image_fault_policy_CFG, NULL);
 		log_policy = find_config_tree_str(cmd, activation_mirror_log_fault_policy_CFG, NULL);
 		*replace_mirrors = strcmp(leg_policy, "remove");
 		*replace_log = strcmp(log_policy, "remove");
+		keep_log = find_config_tree_int(cmd, activation_mirror_keep_log_CFG, NULL);
+		*replace_mirrors = !!strcmp(leg_policy, "remove");
+		*replace_log = !!strcmp(log_policy, "remove");
+		if (keep_log) {
+			*replace_mirrors += 2;
+			*replace_log += 2;
+		}
 		return;
 	}
 
@@ -1004,6 +1022,193 @@ static int remove_device_from_waiting_dir(struct physical_volume *pv)
 	return r;
 }
 
+static int get_a_missing_device(struct logical_volume *lv, struct physical_volume **pv)
+{
+	struct lv_segment *lvseg;
+	unsigned s;
+	int r = 0;
+
+
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		for (s = 0; s < lvseg->area_count; s++) {
+			if (seg_type(lvseg, s) == AREA_LV) {
+				if (is_temporary_mirror_layer(seg_lv(lvseg, s)))
+					return get_a_missing_device(seg_lv(lvseg, s), pv);
+				else if (seg_lv(lvseg, s)->status & PARTIAL_LV)
+					return get_a_missing_device(seg_lv(lvseg, s), pv);
+			}
+			else if (seg_type(lvseg, s) == AREA_PV &&
+				 is_missing_pv(seg_pv(lvseg, s))) {
+				if (already_being_waited(seg_pv(lvseg, s)))
+						continue;
+				*pv = seg_pv(lvseg, s);
+				r = 1;
+				break;
+			}
+		}
+		if (r == 1)
+			break;
+	}
+	return r;
+}
+
+static int missing_device_return(struct logical_volume *lv, struct physical_volume **pv,
+	            	dev_t *old, dev_t *new, int wait_time)
+{
+	struct udev_monitor *mon;
+	struct udev_device *device;
+	const char *new_uuid, *dev_nod;
+	struct udev *udev;
+	char uuid[64] __attribute__((aligned(8)));
+	blkid_probe pr;
+	int fd;
+	fd_set fds;
+	struct timeval tv;
+	int r = 0;
+
+	r = get_a_missing_device(lv, pv);
+	if (!r) {
+		log_error("Failed to get the missing pv");
+		goto bad;
+	}
+	/*
+	 * How to get the missing device dev_t?
+	 */
+	*old = (*pv)->old_dev;
+	if (!*old) {
+		log_error("Failed to get the dev_t of missing pv");
+		goto bad;
+	}
+
+	if (!id_write_format((&(*pv)->id), uuid, sizeof(uuid))) {
+		stack;
+		r = 0;
+		goto bad;
+	}
+
+	if (!(udev = udev_new())) {
+		r = 0;
+		goto bad;
+	}
+
+	mon = udev_monitor_new_from_netlink(udev, "udev");
+	udev_monitor_filter_add_match_subsystem_devtype(mon, "block", NULL);
+	udev_monitor_enable_receiving(mon);
+	fd = udev_monitor_get_fd(mon);
+
+	tv.tv_sec = wait_time;
+	tv.tv_usec = 0;
+	FD_ZERO(&fds);
+	FD_SET(fd, &fds);
+	while(1) {
+		r = select(fd+1, &fds, NULL, NULL, &tv);
+		if (r > 0 && FD_ISSET(fd, &fds)) {
+			/*
+			 * check if it's the missing device
+			 */
+			device = udev_monitor_receive_device(mon);
+			if (device) {
+				dev_nod = udev_device_get_devnode(device);
+				if (NULL == dev_nod) {
+					continue;
+				}
+				pr = blkid_new_probe_from_filename(dev_nod);
+				if (!pr) {
+					log_error("Failed to open %s",dev_nod);
+					goto out;
+				}
+				blkid_do_probe(pr);
+				blkid_probe_lookup_value(pr, "UUID", &new_uuid, NULL);
+
+				if (!strncmp(new_uuid, uuid, sizeof(uuid))) {
+					*new = udev_device_get_devnum(device);
+					r = 1;
+					break;
+				}
+				blkid_free_probe(pr);
+				udev_device_unref(device);
+			} else {
+				log_error("No device from udev_monitor_receive_device.");
+				goto out;
+			}
+		}
+		/*
+		 * timeout while waiting the missing device
+		 */
+		else if (r == 0) {
+			break;
+		}
+	}
+
+out:
+	udev_unref(udev);
+bad:
+	if(*pv)
+		remove_device_from_waiting_dir(*pv);
+	return r;
+}
+
+static int start_sync_lv(struct logical_volume *lv)
+{
+	char target[70];
+	int r = 1;
+
+	sprintf(target,"%s-%s", lv->vg->name, lv->name);
+
+	if (!dm_lv_simple_suspend(target) ||
+			!dm_lv_simple_resume(target)) {
+		r = 0;
+		log_error("Failed to suspend/resume %s", lv->name);
+	}
+
+	return r;
+}
+
+static int lv_replace_table(struct cmd_context *cmd, struct logical_volume *lv,
+		         struct physical_volume *pv, dev_t old, dev_t new)
+{
+	struct logical_volume *sub_lv = NULL;
+	struct lv_segment *lvseg;
+	char target[70];
+	unsigned s;
+	int r = 0;
+
+	/*check which lv is on the missing pv*/
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		for (s = 0; s < lvseg->area_count; s++) {
+			if ((seg_type(lvseg, s) == AREA_LV) &&
+			     (seg_lv(lvseg, s)->status & PARTIAL_LV)) {
+				sub_lv = seg_lv(lvseg, s);
+				if (lv_is_on_pv(sub_lv, pv)) {
+					r = 1;
+					break;
+				}
+			}
+		}
+		if (1 == r) {
+			r = 0;
+			break;
+		}
+	}
+
+	if (!sub_lv)
+		goto fail;
+
+	sprintf(target,"%s-%s", sub_lv->vg->name, sub_lv->name);
+	if (!dm_lv_simple_suspend(target))
+		goto fail;
+
+	if (!dm_replace_mirror_table(target, old, new))
+		goto fail;
+
+	if (!dm_lv_simple_resume(target))
+		goto fail;
+	r = 1;
+fail:
+	return r;
+}
+
+
 /*
  * _get_log_count
  * @lv: the mirror LV
@@ -1510,6 +1715,10 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	int replace_logs = 0;
 	int replace_mimages = 0;
 	uint32_t log_count;
+	int wait_time = 0;
+	int daemon_mode = 0;
+	dev_t old, new;
+	struct physical_volume *pv = NULL;
 
 	uint32_t original_mimages = lv_mirror_count(lv);
 	uint32_t original_logs = _get_log_count(lv);
@@ -1525,28 +1734,79 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 		return 1;
 	}
 
+	/*
+	 * Count the failed log devices
+	 */
 	failed_mimages = _failed_mirrors_count(lv);
 	failed_logs = _failed_logs_count(lv);
 
-	if (!mirror_remove_missing(cmd, lv, 0))
-		return_0;
+	/*
+	 * Find out our policies
+	 */
+	_lvconvert_mirrors_repair_ask(cmd, failed_logs, failed_mimages,
+					  &replace_logs, &replace_mimages);
+
 
 	if (failed_mimages)
 		log_print_unless_silent("Mirror status: %d of %d images failed.",
 					failed_mimages, original_mimages);
 
-	/*
-	 * Count the failed log devices
-	 */
-	if (failed_logs)
+	if (failed_logs) {
 		log_print_unless_silent("Mirror log status: %d of %d images failed.",
 					failed_logs, original_logs);
+		if (replace_logs >= 2) {
+			log_error("The log device failed, there is probably no meaning to keep the bitmap."
+					"We make keep_log doesn't work on log devices");
+			replace_logs -= 2;
+		}
+	}
 
-	/*
-	 * Find out our policies
-	 */
-	_lvconvert_mirrors_repair_ask(cmd, failed_logs, failed_mimages,
-				      &replace_logs, &replace_mimages);
+	if (replace_mimages >= 2) {
+		if (!udev_is_running()) {
+			log_error("Udev is not running!This feature need support by udev");
+			goto feature_fail;
+		}
+		/*
+		 *  Here we make it a daemon to wait
+		 */
+		daemon_mode = become_daemon(cmd, 0);
+		if (daemon_mode == 0)
+			return ECMD_PROCESSED; /*CHECK: safe for parent to return directly*/
+		else if (daemon_mode != 1) {
+			log_error("Failed to become daemon and disable this feature");
+			goto feature_fail;
+		}
+		wait_time = find_config_tree_int(cmd, activation_mirror_keep_log_timeout_CFG, NULL);
+		log_print_unless_silent("This mirror LV will wait %d secs before"
+				"adopting new policy", wait_time);
+		if (missing_device_return(lv, &pv, &old, &new, wait_time)) {
+			/* Remove the MISSING flag*/
+			pv->status &= ~MISSING_PV;
+	
+			if (!pv) {
+				log_error("Failed to get the missing device");
+				goto feature_fail;
+			}
+			if ((MAJOR(old) == MAJOR(new)) && (MINOR(old) == MINOR(new)))
+				goto skip_replace;
+			if (!lv_replace_table(cmd, lv, pv, old, new)) {
+				log_error("Failed to replace table since major/minor changed");
+				goto feature_fail;
+			}
+skip_replace:
+			/*Do sync now*/
+			if (!start_sync_lv(lv)) {
+				log_error("Failed to start do the inremental sync");
+				goto feature_fail;
+			}
+			return 1;
+		}
+feature_fail:
+		replace_mimages -= 2;
+	}
+
+	if (!mirror_remove_missing(cmd, lv, 0))
+		return_0;
 
 	/*
 	 * Second phase - replace faulty devices
-- 
1.8.1.4


