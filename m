From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:11 +0000 (GMT)
Subject: main - activate: device_is_usable
Message-ID: <20211220151411.B6E6F3858016@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65236ee7226930bcbabac0d2dc1979a90bcf2d19
Commit:        65236ee7226930bcbabac0d2dc1979a90bcf2d19
Parent:        5a78979b68c4ae822c3f9bcc7ba662c7aa727b40
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 15 11:26:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

activate: device_is_usable

Move checking of usable uuid into separate function
and pass in also cmd context.
---
 lib/activate/activate.c     |   2 +-
 lib/activate/activate.h     |   2 +-
 lib/activate/dev_manager.c  | 113 ++++++++++++++++++++++++--------------------
 lib/filters/filter-usable.c |   2 +-
 4 files changed, 66 insertions(+), 53 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 52ec02e2c..9d1fe8ebe 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -413,7 +413,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 {
         return 0;
 }
-int device_is_usable(struct device *dev, struct dev_usable_check_params check, int *is_lv)
+int device_is_usable(struct cmd_context *cmd, struct device *dev, struct dev_usable_check_params check, int *is_lv)
 {
         return 0;
 }
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index edd385aef..6133e6d97 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -254,7 +254,7 @@ struct dev_usable_check_params {
  * Returns 1 if mapped device is not suspended, blocked or
  * is using a reserved name.
  */
-int device_is_usable(struct device *dev, struct dev_usable_check_params check, int *is_lv);
+int device_is_usable(struct cmd_context *cmd, struct device *dev, struct dev_usable_check_params check, int *is_lv);
 
 /*
  * Declaration moved here from fs.h to keep header fs.h hidden
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a73a556b2..56575fa85 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -359,7 +359,8 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
  *
  * Returns: 1 if mirror should be ignored, 0 if safe to use
  */
-static int _ignore_blocked_mirror_devices(struct device *dev,
+static int _ignore_blocked_mirror_devices(struct cmd_context *cmd,
+					  struct device *dev,
 					  uint64_t start, uint64_t length,
 					  char *mirror_status_str)
 {
@@ -402,7 +403,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 				goto_out;
 
 			tmp_dev->dev = MKDEV(sm->logs[0].major, sm->logs[0].minor);
-			if (device_is_usable(tmp_dev, (struct dev_usable_check_params)
+			if (device_is_usable(cmd, tmp_dev, (struct dev_usable_check_params)
 					     { .check_empty = 1,
 					       .check_blocked = 1,
 					       .check_suspended = ignore_suspended_devices(),
@@ -606,6 +607,60 @@ static int _ignore_frozen_raid(struct device *dev, const char *params)
 	return r;
 }
 
+static int _is_usable_uuid(const struct device *dev, const char *name, const char *uuid, int check_reserved, int check_lv, int *is_lv)
+{
+	char *vgname, *lvname, *layer;
+	char vg_name[NAME_LEN];
+
+	if (!check_reserved && !check_lv)
+		return 1;
+
+	if (!strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) { /* with LVM- prefix */
+		if (check_reserved) {
+			/* Check internal lvm devices */
+			if (strlen(uuid) > (sizeof(UUID_PREFIX) + 2 * ID_LEN)) { /* 68 with suffix */
+				log_debug_activation("%s: Reserved uuid %s on internal LV device %s not usable.",
+						     dev_name(dev), uuid, name);
+				return 0;
+			}
+
+			/* Recognize some older reserved LVs just from the LV name (snapshot, pvmove...) */
+			vgname = vg_name;
+			if (!dm_strncpy(vg_name, name, sizeof(vg_name)) ||
+			    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
+				return_0;
+
+			/* FIXME: fails to handle dev aliases i.e. /dev/dm-5, replace with UUID suffix */
+			if (lvname && (is_reserved_lvname(lvname) || *layer)) {
+				log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
+						     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
+				return 0;
+			}
+		}
+
+		if (check_lv) {
+			/* Skip LVs */
+			if (is_lv)
+				*is_lv = 1;
+			return 0;
+		}
+	}
+
+	if (check_reserved &&
+	    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
+	     !strncmp(uuid, CRYPT_SUBDEV, sizeof(CRYPT_SUBDEV) - 1) ||
+	     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
+		/* Skip private crypto devices */
+		log_debug_activation("%s: Reserved uuid %s on %s device %s not usable.",
+				     dev_name(dev), uuid,
+				     uuid[0] == 'C' ? "crypto" : "stratis",
+				     name);
+		return 0;
+	}
+
+        return 1;
+}
+
 /*
  * device_is_usable
  * @dev
@@ -622,15 +677,14 @@ static int _ignore_frozen_raid(struct device *dev, const char *params)
  *
  * Returns: 1 if usable, 0 otherwise
  */
-int device_is_usable(struct device *dev, struct dev_usable_check_params check, int *is_lv)
+int device_is_usable(struct cmd_context *cmd, struct device *dev, struct dev_usable_check_params check, int *is_lv)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
 	const char *name, *uuid;
 	uint64_t start, length;
 	char *target_type = NULL;
-	char *params, *vgname, *lvname, *layer;
-	char vg_name[NAME_LEN];
+	char *params;
 	void *next = NULL;
 	int only_error_or_zero_target = 1;
 	int r = 0;
@@ -655,50 +709,9 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 		goto out;
 	}
 
-	if (uuid && (check.check_reserved || check.check_lv)) {
-		if (!strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) { /* with LVM- prefix */
-			if (check.check_reserved) {
-				/* Check internal lvm devices */
-				if (strlen(uuid) > (sizeof(UUID_PREFIX) + 2 * ID_LEN)) { /* 68 with suffix */
-					log_debug_activation("%s: Reserved uuid %s on internal LV device %s not usable.",
-							     dev_name(dev), uuid, name);
-					goto out;
-				}
-
-				/* Recognize some older reserved LVs just from the LV name (snapshot, pvmove...) */
-				vgname = vg_name;
-				if (!dm_strncpy(vg_name, name, sizeof(vg_name)) ||
-				    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
-					goto_out;
-
-				/* FIXME: fails to handle dev aliases i.e. /dev/dm-5, replace with UUID suffix */
-				if (lvname && (is_reserved_lvname(lvname) || *layer)) {
-					log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
-							     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
-					goto out;
-				}
-			}
-
-			if (check.check_lv) {
-				/* Skip LVs */
-				if (is_lv)
-					*is_lv = 1;
-				goto out;
-			}
-		}
-
-		if (check.check_reserved &&
-		    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
-		     !strncmp(uuid, CRYPT_SUBDEV, sizeof(CRYPT_SUBDEV) - 1) ||
-		     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
-			/* Skip private crypto devices */
-			log_debug_activation("%s: Reserved uuid %s on %s device %s not usable.",
-					     dev_name(dev), uuid,
-					     uuid[0] == 'C' ? "crypto" : "stratis",
-					     name);
-			goto out;
-		}
-	}
+	if (uuid &&
+	    !_is_usable_uuid(dev, name, uuid, check.check_reserved, check.check_lv, is_lv))
+		goto out;
 
 	/* FIXME Also check for mpath no paths */
 	do {
@@ -713,7 +726,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 				log_debug_activation("%s: Scanning mirror devices is disabled.", dev_name(dev));
 				goto out;
 			}
-			if (!_ignore_blocked_mirror_devices(dev, start,
+			if (!_ignore_blocked_mirror_devices(cmd, dev, start,
 							    length, params)) {
 				log_debug_activation("%s: Mirror device %s not usable.",
 						     dev_name(dev), name);
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 062fb6c74..d7bdf115e 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -87,7 +87,7 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			break;
 		}
 
-		if (!(r = device_is_usable(dev, ucp, &is_lv))) {
+		if (!(r = device_is_usable(cmd, dev, ucp, &is_lv))) {
 			if (is_lv)
 				dev->filtered_flags |= DEV_FILTERED_IS_LV;
 			else


