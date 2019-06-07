From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 15:25:25 -0400
Subject: master - Additional MD component checking
Message-ID: <201906071925.x57JPP0x016075@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db98a6e3629aaf6bf42d0e840273b4328f930c89
Commit:        db98a6e3629aaf6bf42d0e840273b4328f930c89
Parent:        24bd35b4ce77a5111ee234f554ca139df4b7dd99
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 12:06:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 13:27:16 2019 -0500

Additional MD component checking

If udev info is missing for a device, (which would indicate
if it's an MD component), then do an end-of-device read to
check if a PV is an MD component.  (This is skipped when
using hints since we already know devs in hints are good.)

A new config setting md_component_checks can be used to
disable the additional end-of-device MD checks, or to
always enable end-of-device MD checks.

When both hints and udev info are disabled/unavailable,
the end of PVs will now be scanned by default.  If md
devices with end-of-device superblocks are not being
used, the extra I/O overhead can be avoided by setting
md_component_checks="start".
---
 lib/cache/lvmcache.c         |    7 +++-
 lib/commands/toolcontext.h   |    2 +
 lib/config/config_settings.h |   25 +++++++++++++-
 lib/config/defaults.h        |    2 +
 lib/device/dev-md.c          |    5 ++-
 lib/device/dev-type.c        |    5 ++-
 lib/device/device.h          |    1 +
 lib/label/label.c            |   27 +++++++++++++++
 test/shell/lvm-on-md.sh      |   75 +++++++++++++++++++++++++++++------------
 tools/lvmcmdline.c           |   55 ++++++++++++++++++++++++------
 10 files changed, 166 insertions(+), 38 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8a29bf4..b62e5e2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -555,8 +555,11 @@ next:
 	 */
 
 	if (!(info = lvmcache_info_from_pvid(alt->dev->pvid, NULL, 0))) {
-		/* This shouldn't happen */
-		log_warn("WARNING: PV %s on duplicate device %s not found in cache.",
+		/*
+		 * This will happen if a duplicate dev has been dropped already,
+		 * e.g. it was found to be an md component.
+		 */
+		log_debug("PVID %s on duplicate device %s not found in cache.",
 			 alt->dev->pvid, dev_name(alt->dev));
 		goto next;
 	}
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 0ea2132..7d373ab 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -172,6 +172,7 @@ struct cmd_context {
 	unsigned pvscan_cache_single:1;
 	unsigned can_use_one_scan:1;
 	unsigned is_clvmd:1;
+	unsigned md_component_detection:1;
 	unsigned use_full_md_check:1;
 	unsigned is_activating:1;
 	unsigned enable_hints:1;		/* hints are enabled for cmds in general */
@@ -184,6 +185,7 @@ struct cmd_context {
 	 */
 	struct dev_filter *filter;
 	struct dm_list hints;
+	const char *md_component_checks;
 
 	/*
 	 * Configuration.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index efa86e7..e718dec 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -368,7 +368,30 @@ cfg(devices_multipath_component_detection_CFG, "multipath_component_detection",
 	"Ignore devices that are components of DM multipath devices.\n")
 
 cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL, 0, NULL,
-	"Ignore devices that are components of software RAID (md) devices.\n")
+	"Enable detection and exclusion of MD component devices.\n"
+	"An MD component device is a block device that MD uses as part\n"
+	"of a software RAID virtual device. When an LVM PV is created\n"
+	"on an MD device, LVM must only use the top level MD device as\n"
+	"the PV, and should ignore the underlying component devices.\n"
+	"In cases where the MD superblock is located at the end of the\n"
+	"component devices, it is more difficult for LVM to consistently\n"
+	"identify an MD component, see the md_component_checks setting.\n")
+
+cfg(devices_md_component_checks_CFG, "md_component_checks", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_MD_COMPONENT_CHECKS, vsn(2, 3, 2), NULL, 0, NULL,
+	"The checks LVM should use to detect MD component devices.\n"
+	"MD component devices are block devices used by MD software RAID.\n"
+	"#\n"
+	"Accepted values:\n"
+	"  auto\n"
+	"    LVM will skip scanning the end of devices when it has other\n"
+	"    indications that the device is not an MD component.\n"
+	"  start\n"
+	"    LVM will only scan the start of devices for MD superblocks.\n"
+	"    This does not incur extra I/O by LVM.\n"
+	"  full\n"
+	"    LVM will scan the start and end of devices for MD superblocks.\n"
+	"    This requires an extra read at the end of devices.\n"
+	"#\n")
 
 cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL, 0, NULL,
 	"Ignore devices that are components of firmware RAID devices.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index fac5b75..6a0d686 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -318,4 +318,6 @@
 
 #define DEFAULT_IO_MEMORY_SIZE_KB 8192
 
+#define DEFAULT_MD_COMPONENT_CHECKS "auto"
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 261f3f1..08143b7 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -110,14 +110,17 @@ static int _udev_dev_is_md_component(struct device *dev)
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE)))
+	if (!(value = udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_TYPE))) {
+		dev->flags |= DEV_UDEV_INFO_MISSING;
 		return 0;
+	}
 
 	return !strcmp(value, DEV_EXT_UDEV_BLKID_TYPE_SW_RAID);
 }
 #else
 static int _udev_dev_is_md_component(struct device *dev)
 {
+	dev->flags |= DEV_UDEV_INFO_MISSING;
 	return 0;
 }
 #endif
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 73e55ca..4e35220 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1170,8 +1170,10 @@ int udev_dev_is_md_component(struct device *dev)
 	const char *value;
 	int ret = 0;
 
-	if (!obtain_device_list_from_udev())
+	if (!obtain_device_list_from_udev()) {
+		dev->flags |= DEV_UDEV_INFO_MISSING;
 		return 0;
+	}
 
 	if (!(udev_device = _udev_get_dev(dev)))
 		return 0;
@@ -1198,6 +1200,7 @@ int udev_dev_is_mpath_component(struct device *dev)
 
 int udev_dev_is_md_component(struct device *dev)
 {
+	dev->flags |= DEV_UDEV_INFO_MISSING;
 	return 0;
 }
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 395405a..30e1e79 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -37,6 +37,7 @@
 #define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
 #define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
+#define DEV_UDEV_INFO_MISSING   0x00040000	/* we have no udev info for this device */
 
 /*
  * Support for external device info.
diff --git a/lib/label/label.c b/lib/label/label.c
index 10c1c4c..f6ba2d8 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1022,6 +1022,33 @@ int label_scan(struct cmd_context *cmd)
 		}
 	}
 
+	/*
+	 * Stronger exclusion of md components that might have been
+	 * misidentified as PVs due to having an end-of-device md superblock.
+	 * If we're not using hints, and are not already doing a full md check
+	 * on devs being scanned, then if udev info is missing for a PV, scan
+	 * the end of the PV to verify it's not an md component.  The full
+	 * dev_is_md_component call will do new reads at the end of the dev.
+	 */
+	if (cmd->md_component_detection && !cmd->use_full_md_check && !using_hints &&
+	    !strcmp(cmd->md_component_checks, "auto")) {
+		int once = 0;
+		dm_list_iterate_items(devl, &scan_devs) {
+			if (!(devl->dev->flags & DEV_SCAN_FOUND_LABEL))
+				continue;
+			if (!(devl->dev->flags & DEV_UDEV_INFO_MISSING))
+				continue;
+			if (!once++)
+				log_debug_devs("Scanning end of PVs with no udev info for MD components");
+
+			if (dev_is_md_component(devl->dev, NULL, 1)) {
+				log_debug_devs("Drop PV from MD component %s", dev_name(devl->dev));
+				devl->dev->flags &= ~DEV_SCAN_FOUND_LABEL;
+				lvmcache_del_dev(devl->dev);
+			}
+		}
+	}
+
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
 		free(devl);
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 41649be..22cbee8 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -31,6 +31,10 @@ test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 
 aux lvmconf 'devices/md_component_detection = 1'
 
+# This stops lvm from taking advantage of hints which
+# will have already excluded md components.
+aux lvmconf 'devices/hints = "none"'
+
 # This stops lvm from asking udev if a dev is an md component.
 # LVM will ask udev if a dev is an md component, but we don't
 # want to rely on that ability in this test.
@@ -61,6 +65,10 @@ check lv_field $vg/$lv1 lv_active "active"
 pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
+pvs > out
+not grep "$dev1" out
+not grep "$dev2" out
+
 sleep 1
 
 vgchange -an $vg
@@ -72,12 +80,14 @@ sleep 1
 mdadm --stop "$mddev"
 aux udev_wait
 
-# with md superblock 1.0 this pvs will report duplicates
-# for the two md legs since the md device itself is not
-# started
-pvs 2>&1 |tee out
-cat out
-grep "prefers device" out
+# The md components should still be detected and excluded.
+not pvs "$dev1"
+not pvs "$dev2"
+pvs > out
+not grep "$dev1" out
+not grep "$dev2" out
+
+pvs -vvvv
 
 # should not activate from the md legs
 not vgchange -ay $vg
@@ -104,16 +114,20 @@ not grep "active" out
 mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
 
-# Now that the md dev is online, pvs can see it and
-# ignore the two legs, so there's no duplicate warning
+# Now that the md dev is online, pvs can see it
+# and check for components even if
+# md_component_checks is "start" (which disables
+# most default end-of-device scans)
+aux lvmconf 'devices/md_component_checks = "start"'
 
-pvs 2>&1 |tee out
-cat out
-not grep "prefers device" out
+not pvs "$dev1"
+not pvs "$dev2"
+pvs > out
+not grep "$dev1" out
+not grep "$dev2" out
 
-vgchange -ay $vg 2>&1 |tee out
-cat out
-not grep "prefers device" out
+
+vgchange -ay $vg
 
 check lv_field $vg/$lv1 lv_active "active"
 
@@ -124,6 +138,9 @@ vgremove -f $vg
 
 aux cleanup_md_dev
 
+# Put this setting back to the default
+aux lvmconf 'devices/md_component_checks = "auto"'
+
 # create 2 disk MD raid0 array
 # by default using metadata format 1.0 with data at the end of device
 # When a raid0 md array is stopped, the components will not look like
@@ -149,6 +166,10 @@ check lv_field $vg/$lv1 lv_active "active"
 pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
+pvs > out
+not grep "$dev1" out
+not grep "$dev2" out
+
 sleep 1
 
 vgchange -an $vg
@@ -160,7 +181,14 @@ sleep 1
 mdadm --stop "$mddev"
 aux udev_wait
 
-pvs 2>&1 |tee pvs.out
+# The md components should still be detected and excluded.
+not pvs "$dev1"
+not pvs "$dev2"
+pvs > out
+not grep "$dev1" out
+not grep "$dev2" out
+
+pvs -vvvv
 
 # should not activate from the md legs
 not vgchange -ay $vg
@@ -187,16 +215,19 @@ not grep "active" out
 mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
 
-# Now that the md dev is online, pvs can see it and
-# ignore the two legs, so there's no duplicate warning
+# Now that the md dev is online, pvs can see it
+# and check for components even if
+# md_component_checks is "start" (which disables
+# most default end-of-device scans)
+aux lvmconf 'devices/md_component_checks = "start"'
 
-pvs 2>&1 |tee out
-cat out
-not grep "prefers device" out
+not pvs "$dev1"
+not pvs "$dev2"
+pvs > out
+not grep "$dev1" out
+not grep "$dev2" out
 
 vgchange -ay $vg 2>&1 |tee out
-cat out
-not grep "prefers device" out
 
 check lv_field $vg/$lv1 lv_active "active"
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 79de85b..30f54e6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2766,20 +2766,53 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	return 1;
 }
 
+/*
+ * md_component_check full: always set use_full_md_check
+ * which causes filter-md to read the start+end of every
+ * device on the system (this could be optimized to only
+ * read the end of PVs.)
+ *
+ * md_component_check start: the end of devices will
+ * not generally be read to check for an md superblock
+ * (lvm may still scan for end-of-device md superblocks
+ * if it knows that some exists.)
+ *
+ * md_component_check auto: lvm will use some built-in
+ * heuristics to decide when it should scan the end of
+ * devices to look for md superblocks, e.g. commands
+ * like pvcreate that could clobber a component, or if
+ * udev info is not available and hints are not available.
+ */
 static void _init_md_checks(struct cmd_context *cmd)
 {
-	/*
-	 * use_full_md_check can also be set later.
-	 * These commands are chosen to always perform
-	 * a full md component check because they initialize
-	 * a new device that could be an md component,
-	 * and they are not run frequently during normal
-	 * operation.
-	 */
-	if (!strcmp(cmd->name, "pvcreate") ||
-	    !strcmp(cmd->name, "vgcreate") ||
-	    !strcmp(cmd->name, "vgextend"))
+	const char *md_check;
+
+	cmd->md_component_detection = find_config_tree_bool(cmd, devices_md_component_detection_CFG, NULL);
+
+	md_check = find_config_tree_str(cmd, devices_md_component_checks_CFG, NULL);
+	if (!md_check)
+		cmd->md_component_checks = "auto";
+	else if (!strcmp(md_check, "auto") ||
+	         !strcmp(md_check, "start") ||
+	         !strcmp(md_check, "full"))
+		cmd->md_component_checks = md_check;
+	else {
+		log_warn("Ignoring unknown md_component_checks setting, using auto.");
+		cmd->md_component_checks = "auto";
+	}
+
+	if (!strcmp(cmd->md_component_checks, "full"))
 		cmd->use_full_md_check = 1;
+	else if (!strcmp(cmd->md_component_checks, "auto")) {
+		/* use_full_md_check can also be set later */
+		if (!strcmp(cmd->name, "pvcreate") ||
+		    !strcmp(cmd->name, "vgcreate") ||
+		    !strcmp(cmd->name, "vgextend"))
+			cmd->use_full_md_check = 1;
+	}
+
+	log_debug("Using md_component_checks %s use_full_md_check %d",
+		  cmd->md_component_checks, cmd->use_full_md_check);
 }
 
 static int _cmd_no_meta_proc(struct cmd_context *cmd)


