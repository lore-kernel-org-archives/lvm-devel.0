From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Sep 2014 11:32:15 +0000 (UTC)
Subject: master - refactor: make it possible to select what to check exactly when calling device_is_usable fn
Message-ID: <20140930113215.546CF60E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00d8ab84923af87191110b1cb77b13a483659ef1
Commit:        00d8ab84923af87191110b1cb77b13a483659ef1
Parent:        fbc28cc7adb453122b83a18361809152bdee263f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 23 12:47:11 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 30 13:11:58 2014 +0200

refactor: make it possible to select what to check exactly when calling device_is_usable fn

Currently, there are 5 things that device_is_usable function checks
(for DM devices only, of course):
  - is device empty?
  - is device blocked? (mirror)
  - is device suspended?
  - is device composed of an error target?
  - is device name/uuid reserved?

If answer to any of these questions is "yes", then the device is not usable.
This patch just adds possibility to choose what to check for exactly - the
device_is_usable function now accepts struct dev_usable_check_params make
this selection possible. This is going to be used by subsequent patches.
---
 lib/activate/activate.c         |    2 +-
 lib/activate/activate.h         |   17 +++++++++--------
 lib/activate/dev_manager.c      |   35 ++++++++++++++---------------------
 lib/filters/filter-persistent.c |    7 ++++++-
 liblvm/lvm_base.c               |    2 +-
 tools/lvmcmdline.c              |    2 +-
 6 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 58e847e..6ba4712 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -411,7 +411,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 {
         return 0;
 }
-int device_is_usable(struct device *dev)
+int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 {
         return 0;
 }
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 4f32bca..4c170c1 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -172,18 +172,19 @@ int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size,
 int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg);
 
+struct dev_usable_check_params {
+	unsigned int check_empty:1;
+	unsigned int check_blocked:1;
+	unsigned int check_suspended:1;
+	unsigned int check_error_target:1;
+	unsigned int check_reserved:1;
+};
+
 /*
  * Returns 1 if mapped device is not suspended, blocked or
  * is using a reserved name.
  */
-int device_is_usable(struct device *dev);
-
-/*
- * Returns 1 if the device is suspended or blocking.
- * (Does not perform check on the LV name of the device.)
- * N.B.  This is !device_is_usable() without the name check.
- */
-int device_is_suspended_or_blocking(struct device *dev);
+int device_is_usable(struct device *dev, struct dev_usable_check_params check);
 
 /*
  * Declaration moved here from fs.h to keep header fs.h hidden
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 0437c69..9956fd4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -279,7 +279,12 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 				goto_out;
 
 			tmp_dev->dev = log_dev;
-			if (device_is_suspended_or_blocking(tmp_dev))
+			if (device_is_usable(tmp_dev, (struct dev_usable_check_params)
+					     { .check_empty = 1,
+					       .check_blocked = 1,
+					       .check_suspended = ignore_suspended_devices(),
+					       .check_error_target = 1,
+					       .check_reserved = 0 }))
 				goto_out;
 		}
 	}
@@ -334,7 +339,7 @@ out:
 }
 
 /*
- * _device_is_usable
+ * device_is_usable
  * @dev
  * @check_lv_names
  *
@@ -345,12 +350,11 @@ out:
  *        a) the device is suspended
  *        b) it is a snapshot origin
  *     4) an error target
- * And optionally, if 'check_lv_names' is set
  *     5) the LV name is a reserved name.
  *
  * Returns: 1 if usable, 0 otherwise
  */
-static int _device_is_usable(struct device *dev, int check_lv_names)
+int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -385,18 +389,18 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 	name = dm_task_get_name(dmt);
 	uuid = dm_task_get_uuid(dmt);
 
-	if (!info.target_count) {
+	if (check.check_empty && !info.target_count) {
 		log_debug_activation("%s: Empty device %s not usable.", dev_name(dev), name);
 		goto out;
 	}
 
-	if (info.suspended && ignore_suspended_devices()) {
+	if (check.check_suspended && info.suspended) {
 		log_debug_activation("%s: Suspended device %s not usable.", dev_name(dev), name);
 		goto out;
 	}
 
 	/* Check internal lvm devices */
-	if (check_lv_names &&
+	if (check.check_reserved &&
 	    uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
 		if (strlen(uuid) > (sizeof(UUID_PREFIX) + 2 * ID_LEN)) { /* 68 */
 			log_debug_activation("%s: Reserved uuid %s on internal LV device %s not usable.",
@@ -421,7 +425,7 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 
-		if (target_type && !strcmp(target_type, "mirror")) {
+		if (check.check_blocked && target_type && !strcmp(target_type, "mirror")) {
 			if (ignore_lvm_mirrors()) {
 				log_debug_activation("%s: Scanning mirror devices is disabled.", dev_name(dev));
 				goto out;
@@ -442,8 +446,7 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 		 * FIXME: rather than skipping origin, check if mirror is
 		 * underneath and if the mirror is blocking I/O.
 		 */
-		if (target_type && !strcmp(target_type, "snapshot-origin") &&
-		    ignore_suspended_devices()) {
+		if (check.check_suspended && target_type && !strcmp(target_type, "snapshot-origin")) {
 			log_debug_activation("%s: Snapshot-origin device %s not usable.",
 					     dev_name(dev), name);
 			goto out;
@@ -455,7 +458,7 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 
 	/* Skip devices consisting entirely of error targets. */
 	/* FIXME Deal with device stacked above error targets? */
-	if (only_error_target) {
+	if (check.check_error_target && only_error_target) {
 		log_debug_activation("%s: Error device %s not usable.",
 				     dev_name(dev), name);
 		goto out;
@@ -471,16 +474,6 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 	return r;
 }
 
-int device_is_usable(struct device *dev)
-{
-	return _device_is_usable(dev, 1);
-}
-
-int device_is_suspended_or_blocking(struct device *dev)
-{
-	return !_device_is_usable(dev, 0);
-}
-
 static int _info(const char *dlid, int with_open_count, int with_read_ahead,
 		 struct dm_info *info, uint32_t *read_ahead)
 {
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 6d406c7..ca3ad37 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -288,7 +288,12 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 					log_error("Failed to hash device to filter.");
 					return 0;
 				}
-		if (!device_is_usable(dev)) {
+		if (!device_is_usable(dev, (struct dev_usable_check_params)
+				      { .check_empty = 1,
+					.check_blocked = 1,
+					.check_suspended = ignore_suspended_devices(),
+					.check_error_target = 1,
+					.check_reserved = 1 })) {
 			log_debug_devs("%s: Skipping unusable device", dev_name(dev));
 			return 0;
 		}
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 80d8dbb..31fc0bb 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -38,7 +38,7 @@ static lvm_t _lvm_init(const char *system_dir)
 	/*
 	 * It's not necessary to use name mangling for LVM:
 	 *   - the character set used for VG-LV names is subset of udev character set
-	 *   - when we check other devices (e.g. _device_is_usable fn), we use major:minor, not dm names
+	 *   - when we check other devices (e.g. device_is_usable fn), we use major:minor, not dm names
 	 */
 	dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e56a57a..bb496d0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1588,7 +1588,7 @@ struct cmd_context *init_lvm(void)
 	/*
 	 * It's not necessary to use name mangling for LVM:
 	 *   - the character set used for LV names is subset of udev character set
-	 *   - when we check other devices (e.g. _device_is_usable fn), we use major:minor, not dm names
+	 *   - when we check other devices (e.g. device_is_usable fn), we use major:minor, not dm names
 	 */
 	dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 


