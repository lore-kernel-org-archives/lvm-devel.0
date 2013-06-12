From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:17:00 +0000 (UTC)
Subject: master - filter-mpath: detect partitions of mpath components
Message-ID: <20130612111700.1A01060FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=966d4f36d7fb29734c6176e21a139375c431eeac
Commit:        966d4f36d7fb29734c6176e21a139375c431eeac
Parent:        65d0089c6477e6bc30ef64ce9fd79e8c855c4529
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 12:20:10 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 13:13:38 2013 +0200

filter-mpath: detect partitions of mpath components

We use mpath filtering (enabled by devices/multipath_component_detection=1
lvm.conf setting) to avoid a situation in which we could end up with
duplicate PVs found. We need to filter out the mpath components and
use only the top-level multipath mapping instead for PV scans.

However, if the there are partitions on multipath components, we need
to filter out these partitions. This patch fixes it so those
partitions found on multipath components are filtered as well.

For example, let's consider following configuration:
The sda and sdb are mpath components, sda1 and sdb1 the partitions
on these components, mpath-test the mpath mapping and mpath-test1
the partition mapping - created automatically by kpartx right
after mpath-test creation. The PV resides on top.

       (LVM PV)
          |
      mpath-test1
          |
      mpath-test
          |
sda1 ---------- sdb1
   \ |        |/
    sda      sdb

E.g. for sda1 and sdb1, the code will detect this and it skips
the partition that belongs to the multipath component:
  <snippet from the log>
    #filters/filter-mpath.c:156         /dev/sda1: Device is a partition, using primary device /dev/sda for mpath component detection
    130 #ioctl/libdm-iface.c:1724         dm status   (253:2) OF[16384](*1)
    131 #filters/filter-mpath.c:196         /dev/sda1: Skipping mpath component device
  </snippet from the log>

Othewise, we'd see the same PV label on sda1/sdb1 and mpath-test1
at the same time ending up with "Duplicate PV found...".
---
 WHATS_NEW                  |    1 +
 lib/filters/filter-mpath.c |   30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aecf227..36ad365 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Also filter partitions on mpath components if multipath_component_detection=1.
   Add lvresize support for online thin pool metadata volume resize.
   Add helper functions find_pool_lv() and pool_can_resize_metadata().
   Add detection for thin pool metadata resize kernel support.
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 0e88e65..16e2105 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -123,11 +123,41 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 	const char *sysfs_dir = dm_sysfs_dir();
 	int major = MAJOR(dev->dev);
 	int minor = MINOR(dev->dev);
+	dev_t primary_dev;
 
 	/* Limit this filter only to SCSI devices */
 	if (!major_is_scsi_device(dt, MAJOR(dev->dev)))
 		return 0;
 
+	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
+		case -1:
+			/* Error. */
+			log_error("Failed to get primary device for %d:%d.", major, minor);
+			return 0;
+		case 0:
+			/* The dev is already a primary dev. Just continue with the dev. */
+			break;
+		case 1:
+			/* The dev is partition. */
+			name = dev_name(dev); /* name of original dev for log_debug msg */
+
+			/* Get primary dev from cache. */
+			if (!(dev = dev_cache_get_by_devt(primary_dev, NULL))) {
+				log_error("dev_is_mpath: failed to get device for %d:%d",
+					  major, minor);
+				return 0;
+			}
+
+			major = (int) MAJOR(primary_dev);
+			minor = (int) MINOR(primary_dev);
+
+			log_debug_devs("%s: Device is a partition, using primary "
+				       "device %s for mpath component detection",
+					name, dev_name(dev));
+
+			break;
+	}
+
 	if (!(name = get_sysfs_name(dev)))
 		return_0;
 


