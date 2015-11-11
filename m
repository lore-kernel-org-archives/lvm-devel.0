From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Nov 2015 12:30:30 +0000 (UTC)
Subject: master - dev-ext: issue error if external_device_info_source=udev and udev db record incomplete
Message-ID: <20151111123030.E31F460556@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f82e0210b7cb9f3926ef5051ca34a4ad383ba271
Commit:        f82e0210b7cb9f3926ef5051ca34a4ad383ba271
Parent:        6d0db97163125b6f4c7e07b6aba2f27dd050d14b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 11 13:13:54 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 11 13:14:07 2015 +0100

dev-ext: issue error if external_device_info_source=udev and udev db record incomplete

Udev db records are marked as not initialized (incomplete) on timeout.
Issue an error message whenever LVM finds such records so users are
aware that something's going wrong with udev db.

This is important in case we use devices/external_device_info_source="udev"
where udev database records are used to do various filtering decisions.

For example:

udev log of timed out worker:

Nov 11 13:02:25 raw.virt systemd-udevd[607]: seq 1997 '/devices/virtual/block/dm-2' is taking a long time
Nov 11 13:04:25 raw.virt systemd-udevd[607]: seq 1997 '/devices/virtual/block/dm-2' killed
Nov 11 13:04:25 raw.virt systemd-udevd[607]: worker [11221] terminated by signal 9 (Killed)
Nov 11 13:04:25 raw.virt systemd-udevd[607]: worker [11221] failed while handling '/devices/virtual/block/dm-2'
...

LVM also issues error message visibly if incomplete udev db record is found,
devices/external_device_info_source="udev" is set:

$ pvs
  Udev database has incomplete information about device /dev/dm-2.
  Failed to get external handle for device /dev/dm-2 [udev].
  ...
---
 WHATS_NEW            |    1 +
 lib/device/dev-ext.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5938a99..2dea99c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Issue error if external_device_info_source=udev and udev db record incomplete.
   Fix passing of 32bit values through daemons (mostly lvmlockd).
   Use local memory pool for whole alloc_handle manipulation.
   Add missing pointer validation after dm_get_next_target().
diff --git a/lib/device/dev-ext.c b/lib/device/dev-ext.c
index 8f2024e..22e9a6d 100644
--- a/lib/device/dev-ext.c
+++ b/lib/device/dev-ext.c
@@ -60,6 +60,12 @@ static struct dev_ext *_dev_ext_get_udev(struct device *dev)
 	if (!(udev_device = udev_device_new_from_devnum(udev, 'b', dev->dev)))
 		return_NULL;
 
+	if (!udev_device_get_is_initialized(udev_device)) {
+		/* Timeout or some other udev db inconsistency! */
+		log_error("Udev database has incomplete information about device %s.", dev_name(dev));
+		return NULL;
+	}
+
 	dev->ext.handle = (void *) udev_device;
 	return &dev->ext;
 #else


