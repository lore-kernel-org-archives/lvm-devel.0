From: Milan Broz <mbroz@redhat.com>
Date: Wed, 04 Feb 2009 14:52:00 +0100
Subject: [PATCH] Workaround for problems with persistent device major number
Message-ID: <49899D80.5010103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Workaround for problems with persistent device major number.

We have support in LVM metadata for storing arbitrary major:minor
number for LV.

This used to work with LVM1 and 2.4 kernel.

Unfortunately, 2.6 kernel device-mapper have no support for arbitrary
major number for dm device (yet).
(One major number is allocated in dm_mod constructor now.)

 - the major number is ignored during device creation
 - but status query request that major:minor pair match

LVM2 need to check that requested persistent major:minor pair is not
used - but this check can fail now,  because used major number changed.

# lvcreate -n tst -My --major 200 --minor 33 -l 1 vg_test
  Volume tst (200:33) differs from already active device (254:33)

Until the major number setting is reinstated in kernel, the patch
uses this workaround:

 - it stores allocated major number from kernel device-mapper
 (parsing /proc/devices)

 - it replaces this major number in all ioctl calls if persistent
 number is requested

 - it removes validation for major number in LVM device_manager,
 (major:minor collision check still applies for non-LVM devices)

Patch fixes regression bug
https://bugzilla.redhat.com/show_bug.cgi?id=480838

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/dev_manager.c |    2 +-
 libdm/ioctl/libdm-iface.c  |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ef827ad..a0b3bbe 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -640,7 +640,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	 * requested major/minor and that major/minor pair is available for use
 	 */
 	if (!layer && lv->major != -1 && lv->minor != -1) {
-		if (info.exists && (info.major != lv->major || info.minor != lv->minor)) {
+		if (info.exists && (info.minor != lv->minor)) {
 			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
 				  " differs from already active device "
 				  "(%" PRIu32 ":%" PRIu32")",
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 0c5a730..96aceb1 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -69,6 +69,8 @@ static int _version_checked = 0;
 static int _version_ok = 1;
 static unsigned _ioctl_buffer_double_factor = 0;
 
+static uint32_t _dm_device_major = 0;
+
 /*
  * Support both old and new major numbers to ease the transition.
  * Clumsy, but only temporary.
@@ -255,6 +257,12 @@ static int _create_dm_bitset(void)
 	if (_dm_bitset)
 		return 1;
 
+	/* FIXME: when reinstated multiple major number support in kernel
+	 * if (_dm_version >= 4 && _dm_version_minor >= 20)
+	 */
+	if (!_get_proc_number(PROC_DEVICES, DM_NAME, &_dm_device_major))
+		return 0;
+
 	if (!(_dm_bitset = dm_bitset_create(NULL, NUMBER_OF_MAJORS)))
 		return 0;
 
@@ -1297,6 +1305,13 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 			log_error("Missing major number for persistent device.");
 			goto bad;
 		}
+
+		if (_dm_device_major && dmt->major != _dm_device_major) {
+			log_verbose("Fixing major number for persistent device to %u.",
+				    _dm_device_major);
+			dmt->major = _dm_device_major;
+		}
+
 		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
 		dmi->dev = MKDEV(dmt->major, dmt->minor);
 	}



