From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Feb 2022 23:01:43 +0000 (GMT)
Subject: main - lvmdevices: make deldev work for missing device
Message-ID: <20220203230143.485E63858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3fce6a81f82f2b2b1f75e5d49dbffc77bd637b3c
Commit:        3fce6a81f82f2b2b1f75e5d49dbffc77bd637b3c
Parent:        f0cd54a873880286e0932c5cb38a9572677bee25
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 3 16:56:03 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 3 16:56:03 2022 -0600

lvmdevices: make deldev work for missing device

---
 lib/device/device_id.c |  6 +++---
 lib/device/device_id.h |  1 +
 tools/lvmdevices.c     | 33 ++++++++++++++++-----------------
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 84f9f87ce..4618247ba 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -909,7 +909,7 @@ struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid)
 	return NULL;
 }
 
-static struct dev_use *_get_du_for_devname(struct cmd_context *cmd, const char *devname)
+struct dev_use *get_du_for_devname(struct cmd_context *cmd, const char *devname)
 {
 	struct dev_use *du;
 
@@ -1108,7 +1108,7 @@ id_done:
 	du_pvid = get_du_for_pvid(cmd, pvid);
 
 	/* Is there already an entry using this device's name? */
-	du_devname = _get_du_for_devname(cmd, dev_name(dev));
+	du_devname = get_du_for_devname(cmd, dev_name(dev));
 
 	/* Is there already an entry using the device_id for this device? */
 	du_devid = _get_du_for_device_id(cmd, id->idtype, id->idname);
@@ -1529,7 +1529,7 @@ int device_ids_match_dev(struct cmd_context *cmd, struct device *dev)
 	struct dev_use *du;
 
 	/* First check the du entry with matching devname since it's likely correct. */
-	if ((du = _get_du_for_devname(cmd, dev_name(dev)))) {
+	if ((du = get_du_for_devname(cmd, dev_name(dev)))) {
 		if (_match_du_to_dev(cmd, du, dev))
 			return 1;
 	}
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index a53db12e0..5d352cd81 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -41,6 +41,7 @@ void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg,
 
 struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev);
 struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid);
+struct dev_use *get_du_for_devname(struct cmd_context *cmd, const char *devname);
 
 char *devices_file_version(void);
 int devices_file_exists(struct cmd_context *cmd);
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index c50c09f90..662b35f9a 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -383,28 +383,27 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * No filter because we always want to allow removing a device
 		 * by name from the devices file.
 		 */
-		if (!(dev = dev_cache_get(cmd, devname, NULL))) {
-			log_error("No device found for %s.", devname);
-			goto bad;
-		}
-
-		/*
-		 * dev_cache_scan uses sysfs to check if an LV is using each dev
-		 * and sets this flag is so.
-		 */
-		if (dev_is_used_by_active_lv(cmd, dev, NULL, NULL, NULL, NULL)) {
-			if (!arg_count(cmd, yes_ARG) &&
-			    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", devname) == 'n') {
-				log_error("Device not removed.");
-				goto bad;
+		if ((dev = dev_cache_get(cmd, devname, NULL))) {
+			/*
+			 * dev_cache_scan uses sysfs to check if an LV is using each dev
+			 * and sets this flag is so.
+			 */
+			if (dev_is_used_by_active_lv(cmd, dev, NULL, NULL, NULL, NULL)) {
+				if (!arg_count(cmd, yes_ARG) &&
+			    	    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", devname) == 'n') {
+					log_error("Device not removed.");
+					goto bad;
+				}
 			}
+			if ((du = get_du_for_dev(cmd, dev)))
+				goto dev_del;
 		}
 
-		if (!(du = get_du_for_dev(cmd, dev))) {
-			log_error("Device not found in devices file.");
+		if (!(du = get_du_for_devname(cmd, devname))) {
+			log_error("No devices file entry for %s.", devname);
 			goto bad;
 		}
-
+ dev_del:
 		dm_list_del(&du->list);
 		free_du(du);
 		device_ids_write(cmd);


