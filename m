From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  5 Sep 2016 11:19:36 +0000 (UTC)
Subject: master - lvmetad: use udev to ignore multipath components during scan
Message-ID: <20160905111936.DFCC860D8A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=939f5310b9e58a560247c44cbd8a8f8af86aae7c
Commit:        939f5310b9e58a560247c44cbd8a8f8af86aae7c
Parent:        3a4267ade462e9066fbe70076da0eff679b3cdb6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 31 13:05:53 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 31 13:19:57 2016 -0500

lvmetad: use udev to ignore multipath components during scan

When scanning devs to populate lvmetad during system startup,
filter-mpath with native sysfs multipath component detection
may not detect that a dev is multipath component.  This is
because the multipath devices may not be set up yet.

Because of this, pvscan will scan multipath components during
startup, will see them as duplicate PVs, and will disable
lvmetad.  This will leave lvmetad disabled on systems using
multipath, unless something or someone runs pvscan --cache
to rescan.

To avoid this problem, the code that is scanning devices to
populate lvmetad will now check the udev db to see if a
dev is a multipath component that should be skipped.

(This may not be perfect due to inherent udev races, but will
cover most cases and will be at least as good as it's ever
been.)
---
 lib/cache/lvmetad.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0503d91..c31219e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -24,6 +24,10 @@
 #include "lvm-signal.h"
 #include "lvmlockd.h"
 #include "str_list.h"
+#ifdef UDEV_SYNC_SUPPORT
+#include <libudev.h>
+#include "dev-ext-udev-constants.h"
+#endif
 
 #include <time.h>
 
@@ -2036,6 +2040,44 @@ out:
 	return vg_ret;
 }
 
+#ifdef UDEV_SYNC_SUPPORT
+static int _dev_is_mpath_component(struct udev *udev_context, struct device *dev)
+{
+	struct udev_device *udev_device;
+	const char *value;
+	int ret = 0;
+
+	if (!udev_context)
+		return_0;
+	
+	if (!(udev_device = udev_device_new_from_devnum(udev_context, 'b', dev->dev))) {
+		return_0;
+	}
+
+	if (!udev_device_get_is_initialized(udev_device)) {
+		ret = 0;
+		goto_out;
+	}
+
+	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_BLKID_TYPE);
+	if (value && !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_MPATH)) {
+		log_debug("Dev %s is mpath component (%s)", dev_name(dev), value);
+		ret = 1;
+		goto out;
+	}
+
+	value = udev_device_get_property_value(udev_device, DEV_EXT_UDEV_MPATH_DEVICE_PATH);
+	if (value && !strcmp(value, "1")) {
+		log_debug("Dev %s is mpath component (device path)", dev_name(dev));
+		ret = 1;
+		goto out;
+	}
+out:
+	udev_device_unref(udev_device);
+	return ret;
+}
+#endif
+
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  struct dm_list *found_vgnames,
 			  struct dm_list *changed_vgnames)
@@ -2051,6 +2093,15 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		return 0;
 	}
 
+#ifdef UDEV_SYNC_SUPPORT
+	struct udev *udev_context = udev_get_library_context();
+
+	if (_dev_is_mpath_component(udev_context, dev)) {
+		log_debug("Ignore multipath component for pvscan.");
+		return 1;
+	}
+#endif
+
 	if (!label_read(dev, &label, 0)) {
 		log_print_unless_silent("No PV label found on %s.", dev_name(dev));
 		if (!lvmetad_pv_gone_by_dev(dev))


