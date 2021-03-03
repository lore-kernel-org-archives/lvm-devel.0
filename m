From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 Mar 2021 19:28:43 +0000 (GMT)
Subject: main - filters: better message for excluding LV
Message-ID: <20210303192843.58568386102D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9d10f371199055e9ed0c2715b5353491cb759b0
Commit:        e9d10f371199055e9ed0c2715b5353491cb759b0
Parent:        d0b0c20077affbd9671f89c7eab685ee3315e8d8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 3 12:07:57 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 3 12:07:57 2021 -0600

filters: better message for excluding LV

Make the generic "device is not usable" message from filter-usable
more specific in case the device is not usable because it's an LV.
(i.e. when scan_lvs=0)
---
 lib/activate/activate.c     | 2 +-
 lib/activate/activate.h     | 2 +-
 lib/activate/dev_manager.c  | 6 ++++--
 lib/cache/lvmcache.c        | 2 ++
 lib/filters/filter-usable.c | 8 ++++++--
 lib/filters/filter.h        | 1 +
 6 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index de866fb6c..75248aa63 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -392,7 +392,7 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 {
         return 0;
 }
-int device_is_usable(struct device *dev, struct dev_usable_check_params check)
+int device_is_usable(struct device *dev, struct dev_usable_check_params check, int *is_lv)
 {
         return 0;
 }
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 53c8631b4..4c9328a66 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -253,7 +253,7 @@ struct dev_usable_check_params {
  * Returns 1 if mapped device is not suspended, blocked or
  * is using a reserved name.
  */
-int device_is_usable(struct device *dev, struct dev_usable_check_params check);
+int device_is_usable(struct device *dev, struct dev_usable_check_params check, int *is_lv);
 
 /*
  * Declaration moved here from fs.h to keep header fs.h hidden
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9a2548213..1a8f848ac 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -405,7 +405,7 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 					       .check_blocked = 1,
 					       .check_suspended = ignore_suspended_devices(),
 					       .check_error_target = 1,
-					       .check_reserved = 0 }))
+					       .check_reserved = 0 }, NULL))
 				goto out; /* safe to use */
 			stack;
 		}
@@ -620,7 +620,7 @@ static int _ignore_frozen_raid(struct device *dev, const char *params)
  *
  * Returns: 1 if usable, 0 otherwise
  */
-int device_is_usable(struct device *dev, struct dev_usable_check_params check)
+int device_is_usable(struct device *dev, struct dev_usable_check_params check, int *is_lv)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
@@ -675,6 +675,8 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 
 	if (check.check_lv && uuid && !strncmp(uuid, "LVM-", 4)) {
 		/* Skip LVs */
+		if (is_lv)
+			*is_lv = 1;
 		goto out;
 	}
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 04f6fe0a5..b78262b65 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2909,6 +2909,8 @@ const char *dev_filtered_reason(struct device *dev)
 		return "device is not in devices file";
 	if (dev->filtered_flags & DEV_FILTERED_DEVICES_LIST)
 		return "device is not in devices list";
+	if (dev->filtered_flags & DEV_FILTERED_IS_LV)
+		return "device is an LV";
 
 	/* flag has not been added here */
 	if (dev->filtered_flags)
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 8a5b0d828..43a37afd0 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -111,6 +111,7 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 	filter_mode_t mode = data->mode;
 	int skip_lvs = data->skip_lvs;
 	struct dev_usable_check_params ucp = {0};
+	int is_lv = 0;
 	int r = 1;
 
 	dev->filtered_flags &= ~DEV_FILTERED_MINSIZE;
@@ -145,8 +146,11 @@ static int _passes_usable_filter(struct cmd_context *cmd, struct dev_filter *f,
 			break;
 		}
 
-		if (!(r = device_is_usable(dev, ucp))) {
-			dev->filtered_flags |= DEV_FILTERED_UNUSABLE;
+		if (!(r = device_is_usable(dev, ucp, &is_lv))) {
+			if (is_lv)
+				dev->filtered_flags |= DEV_FILTERED_IS_LV;
+			else
+				dev->filtered_flags |= DEV_FILTERED_UNUSABLE;
 			log_debug_devs("%s: Skipping unusable device.", dev_name(dev));
 		}
 	}
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index bd4293090..40fbdeabb 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -66,5 +66,6 @@ struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_type
 #define DEV_FILTERED_UNUSABLE		0x00000400
 #define DEV_FILTERED_DEVICES_FILE	0x00000800
 #define DEV_FILTERED_DEVICES_LIST	0x00001000
+#define DEV_FILTERED_IS_LV		0x00002000
 
 #endif 	/* _LVM_FILTER_H */


