From: David Teigland <teigland@sourceware.org>
Date: Fri, 15 Jun 2018 13:26:18 -0400
Subject: master - scan: use full md filter when md 1.0 devices are present
Message-ID: <201806151726.w5FHQIev000417@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3fd75d1bcd714b02fb2b843d1928b2a875402f37
Commit:        3fd75d1bcd714b02fb2b843d1928b2a875402f37
Parent:        8eab37593eccbbb8c6d03a9bae2f6852c17a00a5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 15 11:42:10 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 15 12:21:25 2018 -0500

scan: use full md filter when md 1.0 devices are present

The md filter can operate in two native modes:
- normal: reads only the start of each device
- full: reads both the start and end of each device

md 1.0 devices place the superblock at the end of the device,
so components of this version will only be identified and
excluded when lvm uses the full md filter.

Previously, the full md filter was only used in commands
that could write to the device.  Now, the full md filter
is also applied when there is an md 1.0 device present
on the system.  This means the 'pvs' command can avoid
displaying md 1.0 components (at the cost of doubling
the i/o to every device on the system.)

(The md filter can operate in a third mode, using udev,
but this is disabled by default because there have been
problems with reliability of the info returned from udev.)
---
 lib/cache/lvmcache.c               |    2 +-
 lib/device/dev-md.c                |   27 +++++++++---
 lib/device/dev-type.h              |    1 +
 lib/filters/filter-md.c            |   81 ++++++++++++++++-------------------
 lib/label/label.c                  |   14 ++++++
 test/shell/pvcreate-md-fake-hdr.sh |    3 +-
 6 files changed, 75 insertions(+), 53 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c7e3903..f15b352 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -452,7 +452,7 @@ int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
  * unused_duplicate_devs list, and restrict what we allow done with it.
  *
  * In the case of md components, we usually filter these out in filter-md,
- * but in the special case of md superblocks <= 1.0 where the superblock
+ * but in the special case of md superblock version 1.0 where the superblock
  * is@the end of the device, filter-md doesn't always eliminate them
  * first, so we eliminate them here.
  *
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 8284c4d..ac99f42 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -142,13 +142,6 @@ static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int ful
 	 * command if it should do a full check (cmd->use_full_md_check),
 	 * and set it for commands that could possibly write to an md dev
 	 * (pvcreate/vgcreate/vgextend).
-	 *
-	 * For old md versions with magic numbers at the end of devices,
-	 * the md dev components won't be filtered out here when full is 0,
-	 * so they will be scanned, and appear as duplicate PVs in lvmcache.
-	 * The md device itself will be chosen as the primary duplicate,
-	 * and the components are dropped from the list of duplicates in,
-	 * i.e. a kind of post-scan filtering.
 	 */
 	if (!full) {
 		sb_offset = 0;
@@ -414,6 +407,26 @@ unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev)
 	return stripe_width_sectors;
 }
 
+int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev)
+{
+	char version_string[MD_MAX_SYSFS_SIZE];
+	const char *attribute = "metadata_version";
+
+	if (MAJOR(dev->dev) != dt->md_major)
+		return 0;
+
+	if (_md_sysfs_attribute_scanf(dt, dev, attribute,
+				      "%s", &version_string) != 1)
+		return -1;
+
+	log_very_verbose("Device %s %s is %s.",
+			 dev_name(dev), attribute, version_string);
+
+	if (!strcmp(version_string, "1.0"))
+		return 1;
+	return 0;
+}
+
 #else
 
 int dev_is_md(struct device *dev __attribute__((unused)),
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 210a316..0e418d6 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -76,6 +76,7 @@ int wipe_known_signatures(struct cmd_context *cmd, struct device *dev, const cha
 
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
+int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev);
 
 /* Partitioning */
 int major_max_partitions(struct dev_types *dt, int major);
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 95e0aad..4c3f23d 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -30,50 +30,43 @@
  *
  * (This is assuming lvm.conf md_component_detection=1.)
  *
- * If lvm does *not* ignore the components, then lvm will read lvm
- * labels from the md dev and from the component devs, and will see
- * them all as duplicates of each other.  LVM duplicate resolution
- * will then kick in and keep the md dev around to use and ignore
- * the components.
- *
- * It is better to exclude the components as early as possible during
- * lvm processing, ideally before lvm even looks for labels on the
- * components, so that duplicate resolution can be avoided.  There are
- * a number of ways that md components can be excluded earlier than
- * the duplicate resolution phase:
- *
- * - When external_device_info_source="udev", lvm discovers a device is
- *   an md component by asking udev during the initial filtering phase.
- *   However, lvm's default is to not use udev for this.  The
- *   alternative is "native" detection in which lvm tries to detect
- *   md components itself.
- *
- * - When using native detection, lvm's md filter looks for the md
- *   superblock at the start of devices.  It will see the md superblock
- *   on the components, exclude them in the md filter, and avoid
- *   handling them later in duplicate resolution.
- *
- * - When using native detection, lvm's md filter will not detect
- *   components when the md device has an older superblock version that
- *   places the superblock at the end of the device.  This case will
- *   fall back to duplicate resolution to exclude components.
- *
- * A variation of the description above occurs for lvm commands that
- * intend to create new PVs on devices (pvcreate, vgcreate, vgextend).
- * For these commands, the native md filter also reads the end of all
- * devices to check for the odd md superblocks.
- *
- * (The reason that external_device_info_source is not set to udev by
- * default is that there have be issues with udev not being promptly
- * or reliably updated about md state changes, causing the udev info
- * that lvm uses to be occasionally wrong.)
- */
-
-/*
- * FIXME: for commands that want a full md check (pvcreate, vgcreate,
- * vgextend), we do an extra read at the end of every device that the
- * filter looks at.  This isn't necessary; we only need to do the full
- * md check on the PVs that these commands are trying to use.
+ * If lvm does *not* ignore the components, then lvm may read lvm
+ * labels from the component devs and potentially the md dev,
+ * which can trigger duplicate detection, and/or cause lvm to display
+ * md components as PVs rather than ignoring them.
+ *
+ * If scanning md componenents causes duplicates to be seen, then
+ * the lvm duplicate resolution will exclude the components.
+ *
+ * The lvm md filter has three modes:
+ *
+ * 1. look for md superblock at the start of the device
+ * 2. look for md superblock at the start and end of the device
+ * 3. use udev to detect components
+ *
+ * mode 1 will not detect and exclude components of md devices
+ * that use superblock version 1.0 which is at the end of the device.
+ *
+ * mode 2 will detect these, but mode 2 doubles the i/o done by label
+ * scan, since there's a read at both the start and end of every device.
+ *
+ * mode 3 is used when external_device_info_source="udev".  It does
+ * not require any io from lvm, but this mode is not used by default
+ * because there have been problems getting reliable info from udev.
+ *
+ * lvm uses mode 2 when:
+ *
+ * - the command is pvcreate/vgcreate/vgextend, which format new
+ *   devices, and if the user ran these commands on a component
+ *   device of an md device 1.0, then it would cause problems.
+ *   FIXME: this would only really need to scan the end of the
+ *   devices being formatted, not all devices.
+ *
+ * - it sees an md device on the system using version 1.0.
+ *   The point of this is just to avoid displaying md components
+ *   from the 'pvs' command.
+ *   FIXME: the cost (double i/o) may not be worth the benefit
+ *   (not showing md components).
  */
 
 /*
diff --git a/lib/label/label.c b/lib/label/label.c
index de5aa88..065c01f 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -847,6 +847,20 @@ int label_scan(struct cmd_context *cmd)
 			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
 			_scan_dev_close(dev);
 		}
+
+		/*
+		 * When md devices exist that use the old superblock at the
+		 * end of the device, then in order to detect and filter out
+		 * the component devices of those md devs, we need to enable
+		 * the full md filter which scans both the start and the end
+		 * of every device.  This doubles the amount of scanning i/o,
+		 * which we want to avoid.  FIXME: it may not be worth the
+		 * cost of double i/o just to avoid displaying md component
+		 * devs in 'pvs', which is a pretty harmless effect from a
+		 * pretty uncommon situation.
+		 */
+		if (dev_is_md_with_end_superblock(cmd->dev_types, dev))
+			cmd->use_full_md_check = 1;
 	};
 	dev_iter_destroy(iter);
 
diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index 13d810c..82dd8d4 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -95,6 +95,7 @@ sleep 1
 # (when mdadm supports repair)
 if mdadm --action=repair "$mddev" ; then
 	sleep 1
+	pvscan -vvvv
 	# should be showing correctly PV3 & PV4
-	pvs
+	pvs -vvvv "$dev3" "$dev4"
 fi


