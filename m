From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:29 +0000 (UTC)
Subject: master - libdm: introduce and use DEV_UUID macro
Message-ID: <20121010151829.72CBA2432@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=842167eb17b21e5fada08fd3a4beafd96a5b4021
Commit:        842167eb17b21e5fada08fd3a4beafd96a5b4021
Parent:        8dccbae35e6a26fbc736d215de8e0538773de5e0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:02:19 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:15 2012 +0200

libdm: introduce and use DEV_UUID macro

To automatically prefer mangled UUID over unmangled UUID. The same
logic that is already used for dm name mangling...
---
 libdm/ioctl/libdm-iface.c |   15 ++++++++-------
 libdm/libdm-common.h      |    1 +
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index ac3442e..3b6731d 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1083,7 +1083,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	}
 
 	/* Does driver support device number referencing? */
-	if (_dm_version_minor < 3 && !DEV_NAME(dmt) && !dmt->uuid && dmi->dev) {
+	if (_dm_version_minor < 3 && !DEV_NAME(dmt) && !DEV_UUID(dmt) && dmi->dev) {
 		if (!_lookup_dev_name(dmi->dev, dmi->name, sizeof(dmi->name))) {
 			log_error("Unable to find name for device (%" PRIu32
 				  ":%" PRIu32 ")", dmt->major, dmt->minor);
@@ -1099,8 +1099,8 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 			      dmt->major < 0))
 		strncpy(dmi->name, DEV_NAME(dmt), sizeof(dmi->name));
 
-	if (dmt->uuid)
-		strncpy(dmi->uuid, dmt->uuid, sizeof(dmi->uuid));
+	if (DEV_UUID(dmt))
+		strncpy(dmi->uuid, DEV_UUID(dmt), sizeof(dmi->uuid));
 
 	if (dmt->type == DM_DEVICE_SUSPEND)
 		dmi->flags |= DM_SUSPEND_FLAG;
@@ -1510,7 +1510,7 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 		else
 			log_error(INTERNAL_ERROR "Attempt to suspend device %s%s%s%.0d%s%.0d%s%s"
 				  "that uses already-suspended device (%u:%u)", 
-				  DEV_NAME(dmt) ? : "", dmt->uuid ? : "",
+				  DEV_NAME(dmt) ? : "", DEV_UUID(dmt) ? : "",
 				  dmt->major > 0 ? "(" : "",
 				  dmt->major > 0 ? dmt->major : 0,
 				  dmt->major > 0 ? ":" : "",
@@ -1792,6 +1792,7 @@ int dm_task_run(struct dm_task *dmt)
 	unsigned ioctl_retry = 1;
 	int retryable = 0;
 	const char *dev_name = DEV_NAME(dmt);
+	const char *dev_uuid = DEV_UUID(dmt);
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
@@ -1807,7 +1808,7 @@ int dm_task_run(struct dm_task *dmt)
 		return _create_and_load_v4(dmt);
 
 	if (dmt->type == DM_DEVICE_MKNODES && !dev_name &&
-	    !dmt->uuid && dmt->major <= 0)
+	    !dev_uuid && dmt->major <= 0)
 		return _mknodes_v4(dmt);
 
 	if ((dmt->type == DM_DEVICE_RELOAD) && dmt->suppress_identical_reload)
@@ -1828,8 +1829,8 @@ int dm_task_run(struct dm_task *dmt)
 			  "%s%s%s %s%.0d%s%.0d%s%s",
 			  suspended_counter,
 			  dev_name ? : "",
-			  dmt->uuid ? " UUID " : "",
-			  dmt->uuid ? : "",
+			  dev_uuid ? " UUID " : "",
+			  dev_uuid ? : "",
 			  dmt->major > 0 ? "(" : "",
 			  dmt->major > 0 ? dmt->major : 0,
 			  dmt->major > 0 ? ":" : "",
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index 75ee60e..4705a77 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -21,6 +21,7 @@
 #define DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME "DM_DEFAULT_NAME_MANGLING_MODE"
 
 #define DEV_NAME(dmt) (dmt->mangled_dev_name ? : dmt->dev_name)
+#define DEV_UUID(DMT) (dmt->mangled_uuid ? : dmt->uuid)
 
 int mangle_string(const char *str, const char *str_name, size_t len,
 		  char *buf, size_t buf_len, dm_string_mangling_t mode);


