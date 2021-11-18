From: David Teigland <teigland@sourceware.org>
Date: Thu, 18 Nov 2021 23:41:08 +0000 (GMT)
Subject: main - devices: exclude multipath components based on matching wwid
Message-ID: <20211118234108.5D16F3858422@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=212b1fc529a7d550c49f32cb7cbecb017ceb35b0
Commit:        212b1fc529a7d550c49f32cb7cbecb017ceb35b0
Parent:        b8f4ec846d8f4f5256b2737a6d6127482ef7b44e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 17 17:10:45 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 18 17:41:00 2021 -0600

devices: exclude multipath components based on matching wwid

If multipath component devices get through the filter and
cause lvm to see duplicate PVs, then check the wwid of the
devs and drop the component devices as if they had been
filtered.  If a dm mpath device was found among the duplicates
then use that as the PV, otherwise do not use any of the
components as the PV.

"duplicate PVs" associated with multipath configs will no
longer stop commands from working.
---
 lib/cache/lvmcache.c                  | 186 ++++++++++++++++++++++++++++++++--
 lib/device/dev-mpath.c                |  71 +++++++++++++
 lib/device/dev-type.h                 |   2 +
 lib/device/device_id.c                |  13 ++-
 lib/device/device_id.h                |   2 +
 test/shell/duplicate-pvs-multipath.sh |  67 ++++++++++++
 6 files changed, 330 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 81b9b0ec9..b3a4b5a71 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -635,6 +635,102 @@ static void _warn_unused_duplicates(struct cmd_context *cmd)
 	}
 }
 
+static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_info *info, const char *pvid,
+				     struct dm_list *altdevs, struct device **dev_mpath)
+{
+	struct device_list *devl;
+	struct device *dev_mp = NULL;
+	struct device *dev1 = NULL;
+	struct device *dev;
+	const char *wwid1 = NULL;
+	const char *wwid;
+	int diff_wwid = 0;
+	int same_wwid = 0;
+	int dev_is_mp;
+
+	*dev_mpath = NULL;
+
+	/* This function only makes sense with more than one dev. */
+	if ((info && dm_list_empty(altdevs)) || (!info && (dm_list_size(altdevs) == 1))) {
+		log_debug("Skip multipath component checks with single device for PVID %s", pvid);
+		return 0;
+	}
+
+	log_debug("Checking for multipath components for duplicate PVID %s", pvid);
+
+	if (info) {
+		dev = info->dev;
+		dev_is_mp = (cmd->dev_types->device_mapper_major == MAJOR(dev->dev)) && dev_has_mpath_uuid(cmd, dev, NULL);
+
+		if (dev_is_mp) {
+			if ((wwid1 = dev_mpath_component_wwid(cmd, dev))) {
+				dev_mp = dev;
+				dev1 = dev;
+			}
+		} else {
+			if ((wwid1 = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID)))
+				dev1 = dev;
+		}
+	}
+
+	dm_list_iterate_items(devl, altdevs) {
+		dev = devl->dev;
+		dev_is_mp = (cmd->dev_types->device_mapper_major == MAJOR(dev->dev)) && dev_has_mpath_uuid(cmd, dev, NULL);
+
+		if (dev_is_mp)
+			wwid = dev_mpath_component_wwid(cmd, dev);
+		else
+			wwid = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID);
+
+		if (!wwid && wwid1) {
+			log_print("Different wwids for duplicate PVs %s %s %s none",
+				  dev_name(dev1), wwid1, dev_name(dev));
+			diff_wwid++;
+			continue;
+		}
+
+		if (!wwid)
+			continue;
+
+		if (!wwid1) {
+			wwid1 = wwid;
+			dev1 = dev;
+			continue;
+		}
+
+		/* Different wwids indicates these are not multipath components. */
+		if (strcmp(wwid1, wwid)) {
+			log_print("Different wwids for duplicate PVs %s %s %s %s",
+				  dev_name(dev1), wwid1, dev_name(dev), wwid);
+			diff_wwid++;
+			continue;
+		}
+
+		/* Different mpath devs with the same wwid shouldn't happen. */
+		if (dev_is_mp && dev_mp) {
+			log_print("Found multiple multipath devices for PVID %s WWID %s: %s %s",
+				   pvid, wwid1, dev_name(dev_mp), dev_name(dev));
+			continue;
+		}
+
+		log_debug("Same wwids for duplicate PVs %s %s", dev_name(dev1), dev_name(dev));
+		same_wwid++;
+
+		/* Save the mpath device so it can be used as the PV. */
+		if (dev_is_mp)
+			dev_mp = dev;
+	}
+
+	if (diff_wwid || !same_wwid)
+		return 0;
+
+	if (dev_mp)
+		log_debug("Found multipath device %s for PVID %s WWID %s.", dev_name(dev_mp), pvid, wwid1);
+
+	*dev_mpath = dev_mp;
+	return 1;
+}
+
 /*
  * If we've found devices with the same PVID, decide which one
  * to use.
@@ -690,6 +786,8 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	struct device_list *devl, *devl_safe, *devl_add, *devl_del;
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
+	struct device *dev_mpath;
+	struct device *dev_drop;
 	const char *device_id = NULL, *device_id_type = NULL;
 	const char *idname1 = NULL, *idname2 = NULL;
 	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
@@ -712,6 +810,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 next:
 	dm_list_init(&altdevs);
 	pvid = NULL;
+	dev_mpath = NULL;
 
 	dm_list_iterate_items_safe(devl, devl_safe, &_initial_duplicates) {
 		if (!pvid) {
@@ -730,23 +829,97 @@ next:
 		return;
 	}
 
+	info = lvmcache_info_from_pvid(pvid, NULL, 0);
+
 	/*
-	 * Get rid of any md components before comparing alternatives.
-	 * (Since an md component can never be used, it's not an
-	 * option to use like other kinds of alternatives.)
+	 * Usually and ideally, components of md and multipath devs should have
+	 * been excluded by filters, and not scanned for a PV.  In some unusual
+	 * cases the components can get through the filters, and a PV can be
+	 * found on them.  Detecting the same PVID on both the component and
+	 * the md/mpath device gives us a last chance to drop the component.
+	 * An md/mpath component device is completely ignored, as if it had
+	 * been filtered, and not kept in the list unused duplicates.
 	 */
 
-	info = lvmcache_info_from_pvid(pvid, NULL, 0);
+	/*
+	 * Get rid of multipath components based on matching wwids.
+	 */
+	if (_all_multipath_components(cmd, info, pvid, &altdevs, &dev_mpath)) {
+		if (info && dev_mpath && (info->dev != dev_mpath)) {
+			/*
+			 * info should be dropped from lvmcache and info->dev
+			 * should be treated as if it had been excluded by a filter.
+			 * dev_mpath should be added to lvmcache by the caller.
+			 */
+			dev_drop = info->dev;
+
+			/* Have caller add dev_mpath to lvmcache. */
+			log_debug("Using multipath device %s for PVID %s.", dev_name(dev_mpath), pvid);
+			if ((devl_add = zalloc(sizeof(*devl_add)))) {
+				devl_add->dev = dev_mpath;
+				dm_list_add(add_cache_devs, &devl_add->list);
+			}
+
+			/* Remove dev_mpath from altdevs. */
+			if ((devl = _get_devl_in_device_list(dev_mpath, &altdevs)))
+				dm_list_del(&devl->list);
+
+			/* Remove info from lvmcache that came from the component dev. */
+			log_debug("Ignoring multipath component %s with PVID %s (dropping info)", dev_name(dev_drop), pvid);
+			lvmcache_del(info);
+			info = NULL;
+
+			/* Make the component dev look like it was filtered. */
+			cmd->filter->wipe(cmd, cmd->filter, dev_drop, NULL);
+			dev_drop->flags &= ~DEV_SCAN_FOUND_LABEL;
+		}
+
+		if (info && !dev_mpath) {
+			/*
+			 * Only mpath component devs were found and no actual
+			 * multipath dev, so drop the component from lvmcache.
+			 */
+			dev_drop = info->dev;
+
+			log_debug("Ignoring multipath component %s with PVID %s (dropping info)", dev_name(dev_drop), pvid);
+			lvmcache_del(info);
+			info = NULL;
+
+			/* Make the component dev look like it was filtered. */
+			cmd->filter->wipe(cmd, cmd->filter, dev_drop, NULL);
+			dev_drop->flags &= ~DEV_SCAN_FOUND_LABEL;
+		}
+
+		dm_list_iterate_items_safe(devl, devl_safe, &altdevs) {
+			/*
+			 * The altdevs are all mpath components that should look
+			 * like they were filtered, they are not in lvmcache.
+			 */
+			dev_drop = devl->dev;
+
+			log_debug("Ignoring multipath component %s with PVID %s (dropping duplicate)", dev_name(dev_drop), pvid);
+			dm_list_del(&devl->list);
+
+			cmd->filter->wipe(cmd, cmd->filter, dev_drop, NULL);
+			dev_drop->flags &= ~DEV_SCAN_FOUND_LABEL;
+		}
+		goto next;
+	}
+
+	/*
+	 * Get rid of any md components.
+	 * FIXME: use a function like _all_multipath_components to pick the actual md device.
+	 */
 	if (info && dev_is_md_component(cmd, info->dev, NULL, 1)) {
 		/* does not go in del_cache_devs which become unused_duplicates */
-		log_debug_cache("PV %s drop MD component from scan selection %s", pvid, dev_name(info->dev));
+		log_debug("Ignoring md component %s with PVID %s (dropping info)", dev_name(info->dev), pvid);
 		lvmcache_del(info);
 		info = NULL;
 	}
 
 	dm_list_iterate_items_safe(devl, devl_safe, &altdevs) {
 		if (dev_is_md_component(cmd, devl->dev, NULL, 1)) {
-			log_debug_cache("PV %s drop MD component from scan duplicates %s", pvid, dev_name(devl->dev));
+			log_debug("Ignoring md component %s with PVID %s (dropping duplicate)", dev_name(devl->dev), pvid);
 			dm_list_del(&devl->list);
 		}
 	}
@@ -754,7 +927,6 @@ next:
 	if (dm_list_empty(&altdevs))
 		goto next;
 
-
 	/*
 	 * Find the device for the pvid that's currently in lvmcache.
 	 */
diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index ba7bf9740..cbbad9dc9 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -482,3 +482,74 @@ found:
 	return 1;
 }
 
+const char *dev_mpath_component_wwid(struct cmd_context *cmd, struct device *dev)
+{
+	char slaves_path[PATH_MAX];
+	char wwid_path[PATH_MAX];
+	char sysbuf[PATH_MAX] = { 0 };
+	char *slave_name;
+	const char *wwid = NULL;
+	struct stat info;
+	DIR *dr;
+	struct dirent *de;
+
+	/* /sys/dev/block/253:7/slaves/sda/device/wwid */
+
+	if (dm_snprintf(slaves_path, sizeof(slaves_path), "%s/dev/block/%d:%d/slaves",
+			dm_sysfs_dir(), (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
+		log_warn("Sysfs path to check mpath components is too long.");
+		return NULL;
+	}
+
+	if (stat(slaves_path, &info))
+		return NULL;
+
+	if (!S_ISDIR(info.st_mode)) {
+		log_warn("Path %s is not a directory.", slaves_path);
+		return NULL;
+	}
+
+	/* Get wwid from first component */
+
+	if (!(dr = opendir(slaves_path))) {
+		log_debug("Device %s has no slaves dir", dev_name(dev));
+		return NULL;
+	}
+
+	while ((de = readdir(dr))) {
+		if (!strcmp(de->d_name, ".") || !strcmp(de->d_name, ".."))
+			continue;
+
+		/* slave_name "sda" */
+		slave_name = de->d_name;
+
+		/* read /sys/block/sda/device/wwid */
+
+		if (dm_snprintf(wwid_path, sizeof(wwid_path), "%s/block/%s/device/wwid",
+       				dm_sysfs_dir(), slave_name) < 0) {
+			log_warn("Failed to create sysfs wwid path for %s", slave_name);
+			continue;
+		}
+
+		get_sysfs_value(wwid_path, sysbuf, sizeof(sysbuf), 0);
+		if (!sysbuf[0])
+			continue;
+
+		if (strstr(sysbuf, "scsi_debug")) {
+			int i;
+			for (i = 0; i < strlen(sysbuf); i++) {
+				if (sysbuf[i] == ' ')
+					sysbuf[i] = '_';
+			}
+		}
+
+		if ((wwid = dm_pool_strdup(cmd->mem, sysbuf)))
+			break;
+	}
+	if (closedir(dr))
+		stack;
+
+	return wwid;
+}
+
+
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index f3521c6e0..36fb8f258 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -63,6 +63,8 @@ int dev_is_swap(struct cmd_context *cmd, struct device *dev, uint64_t *signature
 int dev_is_luks(struct cmd_context *cmd, struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
 
+const char *dev_mpath_component_wwid(struct cmd_context *cmd, struct device *dev);
+
 int dev_is_lvm1(struct device *dev, char *buf, int buflen);
 int dev_is_pool(struct device *dev, char *buf, int buflen);
 
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index b6e31d0e7..06d64a494 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -243,7 +243,7 @@ static int _dm_uuid_has_prefix(char *sysbuf, const char *prefix)
 }
 
 /* the dm uuid uses the wwid of the underlying dev */
-static int _dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out)
+int dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out)
 {
 	char sysbuf[PATH_MAX] = { 0 };
 	const char *idname;
@@ -312,8 +312,13 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 			read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
 
 		/* scsi_debug wwid begins "t10.Linux   scsi_debug ..." */
-		if (strstr(sysbuf, "scsi_debug"))
-			sysbuf[0] = '\0';
+		if (strstr(sysbuf, "scsi_debug")) {
+                        int i;
+                        for (i = 0; i < strlen(sysbuf); i++) {
+                                if (sysbuf[i] == ' ')
+                                        sysbuf[i] = '_';
+                        }
+		}
 
 		/* qemu wwid begins "t10.ATA     QEMU HARDDISK ..." */
 		if (strstr(sysbuf, "QEMU HARDDISK"))
@@ -982,7 +987,7 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 	}
 
 	if (MAJOR(dev->dev) == cmd->dev_types->device_mapper_major) {
-		if (_dev_has_mpath_uuid(cmd, dev, &idname)) {
+		if (dev_has_mpath_uuid(cmd, dev, &idname)) {
 			idtype = DEV_ID_TYPE_MPATH_UUID;
 			goto id_done;
 		}
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 0ada35c94..a53db12e0 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -56,4 +56,6 @@ void unlink_searched_devnames(struct cmd_context *cmd);
 
 int read_sys_block(struct cmd_context *cmd, struct device *dev, const char *suffix, char *sysbuf, int sysbufsize);
 
+int dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out);
+
 #endif
diff --git a/test/shell/duplicate-pvs-multipath.sh b/test/shell/duplicate-pvs-multipath.sh
new file mode 100644
index 000000000..a145e4afb
--- /dev/null
+++ b/test/shell/duplicate-pvs-multipath.sh
@@ -0,0 +1,67 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='udev rule and systemd unit run vgchange'
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+# FIXME: skip until mpath/scsi_debug cleanup works after a failure
+skip
+
+modprobe --dry-run scsi_debug || skip
+multipath -l || skip
+multipath -l | grep scsi_debug && skip
+
+# Turn off multipath_component_detection so that the duplicate
+# resolution of mpath components is used.
+aux lvmconf 'devices/multipath_component_detection = 0'
+# Prevent wwids from being used for filtering.
+aux lvmconf 'devices/multipath_wwids_file = "/dev/null"'
+# Need to use /dev/mapper/mpath
+aux lvmconf 'devices/dir = "/dev"'
+aux lvmconf 'devices/scan = "/dev"'
+# Could set filter to $MP and the component /dev/sd devs
+aux lvmconf "devices/filter = [ \"a|.*|\" ]"
+aux lvmconf "devices/global_filter = [ \"a|.*|\" ]"
+
+modprobe scsi_debug dev_size_mb=100 num_tgts=1 vpd_use_hostno=0 add_host=4 delay=20 max_luns=2 no_lun_0=1
+sleep 2
+
+multipath -r
+sleep 2
+
+MPB=$(multipath -l | grep scsi_debug | cut -f1 -d ' ')
+echo $MPB
+MP=/dev/mapper/$MPB
+echo $MP
+
+pvcreate $MP
+vgcreate $vg1 $MP
+lvcreate -l1 $vg1
+vgchange -an $vg1
+
+pvs |tee out
+grep $MP out
+for i in $(grep -H scsi_debug /sys/block/sd*/device/model | cut -f4 -d /); do
+	not grep /dev/$i out;
+done
+
+vgchange -an $vg1
+vgremove -y $vg1
+
+sleep 2
+multipath -f $MP
+sleep 1
+rmmod scsi_debug


