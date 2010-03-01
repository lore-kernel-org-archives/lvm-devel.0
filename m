From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 01 Mar 2010 09:43:25 +0100
Subject: [PATCH] Make use of new DM_UEVENT_GENERATED_FLAG in dm ioctl
Message-ID: <4B8B7E2D.4060704@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is user space part related to:

[dm-devel][PATCH] dm_ioctl: Introduce DM_UEVENT_GENERATED_FLAG
(initiated by: [dm-devel] [PATCH] dm_ioctl: Only send a change uevent when a resume ioctl changes the device.)

We need to know whether we should wait for any uevent or not when
using udev_sync. A patch was posted recently that changed the way
uevents are sent on dm device resume - it is sent only if the device
has been suspended before.

We have two options - either we get the state of the device before
being processed or have a possibility to get the information back in
the ioctl return saying whether uevent was generated or not. If the
uevent was not generated (e.g. the situation where the device is
*not* suspended and we call a resume), we just call dm_udev_complete
explicitly from withing libdevmapper itself.

This is quite important to prevent infinite waiting for any
non-existent notifications.

Peter

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 4efb684..ace6d96 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1505,18 +1505,28 @@ static int _mknodes_v4(struct dm_task *dmt)
  */
 static int _udev_complete(struct dm_task *dmt)
 {
-	uint32_t cookie;
+	uint16_t base;
 
-	if (dmt->cookie_set) {
+	if (dmt->cookie_set &&
+	    (base = dmt->event_nr & ~DM_UDEV_FLAGS_MASK))
 		/* strip flags from the cookie and use cookie magic instead */
-		cookie = (dmt->event_nr & ~DM_UDEV_FLAGS_MASK) |
-			  (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
-		return dm_udev_complete(cookie);
-	}
+		return dm_udev_complete(base | (DM_COOKIE_MAGIC <<
+						DM_UDEV_FLAGS_SHIFT));
 
 	return 1;
 }
 
+static int _check_uevent_generated(struct dm_ioctl *dmi)
+{
+	if (!dm_check_version() ||
+	    _dm_version < 4 ||
+	    _dm_version_minor < 17)
+		/* can't check, assume uevent is generated */
+		return 1;
+
+	return dmi->flags & DM_UEVENT_GENERATED_FLAG;
+}
+
 static int _create_and_load_v4(struct dm_task *dmt)
 {
 	struct dm_task *task;
@@ -1691,6 +1701,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				     unsigned repeat_count)
 {
 	struct dm_ioctl *dmi;
+	int ioctl_with_uevent;
 
 	dmi = _flatten(dmt, repeat_count);
 	if (!dmi) {
@@ -1706,6 +1717,10 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	if (dmt->no_open_count)
 		dmi->flags |= DM_SKIP_BDGET_FLAG;
 
+	ioctl_with_uevent = dmt->type == DM_DEVICE_RESUME ||
+			    dmt->type == DM_DEVICE_REMOVE ||
+			    dmt->type == DM_DEVICE_RENAME;
+
 	/*
 	 * Prevent udev vs. libdevmapper race when processing nodes and
 	 * symlinks. This can happen when the udev rules are installed and
@@ -1715,10 +1730,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	 * to be applied at all in this situation so we can gracefully fallback
 	 * to libdevmapper's node and symlink creation code.
 	 */
-	if (dm_udev_get_sync_support() && !dmt->cookie_set &&
-	    (dmt->type == DM_DEVICE_RESUME ||
-	     dmt->type == DM_DEVICE_REMOVE ||
-	     dmt->type == DM_DEVICE_RENAME)) {
+	if (dm_udev_get_sync_support() && !dmt->cookie_set && ioctl_with_uevent) {
 		log_debug("Cookie value is not set while trying to call "
 			  "DM_DEVICE_RESUME, DM_DEVICE_REMOVE or DM_DEVICE_RENAME "
 			  "ioctl. Please, consider using libdevmapper's udev "
@@ -1774,6 +1786,10 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			return NULL;
 		}
 	}
+
+	if (ioctl_with_uevent && !_check_uevent_generated(dmi))
+		_udev_complete(dmt);
+
 #else /* Userspace alternative for testing */
 #endif
 	return dmi;
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 7797984..64d0e1e 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -268,9 +268,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	16
+#define DM_VERSION_MINOR	17
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2009-11-05)"
+#define DM_VERSION_EXTRA	"-ioctl (2010-03-01)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -318,4 +318,9 @@ enum {
  */
 #define DM_QUERY_INACTIVE_TABLE_FLAG	(1 << 12) /* In */
 
+/*
+ * Indicates whether a uevent was generated.
+ */
+#define DM_UEVENT_GENERATED_FLAG	(1 << 13) /* Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */


