From: David Teigland <teigland@sourceware.org>
Date: Mon,  7 Nov 2022 14:56:46 +0000 (GMT)
Subject: main - device_id: handle duplicate serial numbers
Message-ID: <20221107145646.D43073856949@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=761b922178c8522fd9abb207ba31bd27f9fa9dc4
Commit:        761b922178c8522fd9abb207ba31bd27f9fa9dc4
Parent:        bdab36cf3f059e597371bb504646f4dfb7a89f50
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 31 16:14:01 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 7 08:56:02 2022 -0600

device_id: handle duplicate serial numbers

Handle multiple devices using the same serial number as
their device id.  After matching devices to devices file
entries, if there is a discrepency between the ondisk PVID
and the devices file PVID, then rematch devices to
devices file entries using PVID, looking at all disks
on the system with the same serial number.
---
 lib/cache/lvmcache.c             |  16 +
 lib/commands/toolcontext.h       |   1 +
 lib/device/device.h              |   5 +
 lib/device/device_id.c           | 377 +++++++++++++++++++
 lib/device/device_id.h           |   1 +
 test/shell/devicesfile-serial.sh | 777 +++++++++++++++++++++++++++++++++++++++
 tools/lvmdevices.c               |  10 +-
 7 files changed, 1185 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2cb904fd4..1aa699c83 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1634,6 +1634,22 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	if (!label_scan(cmd))
 		return_0;
 
+	/*
+	 * device_ids_validate() found devices using a sys_serial device id
+	 * which had a PVID on disk that did not match the PVID in the devices
+	 * file.  Serial numbers may not always be unique, so any device with
+	 * the same serial number is found and searched for the correct PVID.
+	 * If the PVID is found on a device that has not been scanned, then
+	 * it needs to be scanned so it can be used.
+	 */
+	if (!dm_list_empty(&cmd->device_ids_check_serial)) {
+		struct dm_list scan_devs;
+		dm_list_init(&scan_devs);
+		device_ids_check_serial(cmd, &scan_devs, NULL, 0);
+		if (!dm_list_empty(&scan_devs))
+			label_scan_devs(cmd, cmd->filter, &scan_devs);
+	}
+
 	/*
 	 * When devnames are used as device ids (which is dispreferred),
 	 * changing/unstable devnames can lead to entries in the devices file
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 32bfda57a..7f5fd12fc 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -215,6 +215,7 @@ struct cmd_context {
 	struct dm_list use_devices;		/* struct dev_use for each entry in devices file */
 	const char *md_component_checks;
 	const char *search_for_devnames;	/* config file setting */
+	struct dm_list device_ids_check_serial;
 	const char *devicesfile;                /* from --devicesfile option */
 	struct dm_list deviceslist;             /* from --devices option, struct dm_str_list */
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 519754e41..a047158d8 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -118,6 +118,11 @@ struct dev_use {
 	char *pvid;
 };
 
+struct dev_use_list {
+	struct dm_list list;
+	struct dev_use *du;
+};
+
 /*
  * All devices in LVM will be represented by one of these.
  * pointer comparisons are valid.
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 15b34a158..599e357be 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -22,6 +22,8 @@
 #include "lib/metadata/metadata.h"
 #include "lib/format_text/layout.h"
 #include "lib/cache/lvmcache.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/metadata/metadata-exported.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -752,6 +754,35 @@ const char *dev_idname_for_metadata(struct cmd_context *cmd, struct device *dev)
 	return dev->id->idname;
 }
 
+static const char *_dev_idname(struct device *dev, uint16_t idtype)
+{
+	struct dev_id *id;
+
+	dm_list_iterate_items(id, &dev->ids) {
+		if (id->idtype != idtype)
+			continue;
+		if (!id->idname)
+			continue;
+		return id->idname;
+	}
+	return NULL;
+}
+
+static int _dev_has_id(struct device *dev, uint16_t idtype, const char *idname)
+{
+	struct dev_id *id;
+
+	dm_list_iterate_items(id, &dev->ids) {
+		if (id->idtype != idtype)
+			continue;
+		if (!id->idname)
+			continue;
+		if (!strcmp(idname, id->idname))
+			return 1;
+	}
+	return 0;
+}
+
 static void _copy_idline_str(char *src, char *dst, int len)
 {
 	char *s, *d = dst;
@@ -2077,6 +2108,62 @@ void device_ids_match(struct cmd_context *cmd)
 	}
 }
 
+static void _get_devs_with_serial_numbers(struct cmd_context *cmd, struct dm_list *serial_str_list, struct dm_list *devs)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+	struct device_list *devl;
+	struct dev_id *id;
+	const char *idname;
+
+	if (!(iter = dev_iter_create(NULL, 0)))
+		return;
+	while ((dev = dev_iter_get(cmd, iter))) {
+		/* if serial has already been read for this dev then use it */
+		dm_list_iterate_items(id, &dev->ids) {
+			if (id->idtype == DEV_ID_TYPE_SYS_SERIAL) {
+				if (str_list_match_item(serial_str_list, id->idname)) {
+					if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+						goto next_dev;
+					devl->dev = dev;
+					dm_list_add(devs, &devl->list);
+				}
+				goto next_dev;
+			}
+		}
+
+		/* just copying the no-data filters in similar device_ids_find_renamed_devs */
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "sysfs"))
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "type"))
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "usable"))
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "mpath"))
+			continue;
+
+		if ((idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_SERIAL))) {
+			if (str_list_match_item(serial_str_list, idname)) {
+				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+					goto next_dev;
+				if (!(id = zalloc(sizeof(struct dev_id))))
+					goto next_dev;
+				id->idtype = DEV_ID_TYPE_SYS_SERIAL;
+				id->idname = (char *)idname;
+				id->dev = dev;
+				dm_list_add(&dev->ids, &id->list);
+				devl->dev = dev;
+				dm_list_add(devs, &devl->list);
+			} else {
+				free((char *)idname);
+			}
+		}
+ next_dev:
+		continue;
+	}
+	dev_iter_destroy(iter);
+}
+
 /*
  * This is called after devices are scanned to compare what was found on disks
  * vs what's in the devices file.  The devices file could be outdated and need
@@ -2145,6 +2232,19 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 
 		checked++;
 
+		/*
+		 * If the PVID doesn't match, don't assume that the serial
+		 * number is correct, since serial numbers may not be unique.
+		 * Search for the PVID on other devs in device_ids_check_serial.
+		 */
+		if ((du->idtype == DEV_ID_TYPE_SYS_SERIAL) &&
+		    (!du->pvid || memcmp(dev->pvid, du->pvid, ID_LEN))) {
+			log_debug("suspect device id serial %s for %s", du->idname, dev_name(dev));
+			str_list_add(cmd->mem, &cmd->device_ids_check_serial, dm_pool_strdup(cmd->mem, du->idname));
+			*device_ids_invalid = 1;
+			continue;
+		}
+
 		/*
 		 * If the du pvid from the devices file does not match the
 		 * pvid read from disk, replace the du pvid with the pvid from
@@ -2362,6 +2462,282 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	}
 }
 
+static struct device_id_list *_device_id_list_find_dev(struct dm_list *list, struct device *dev)
+{
+	struct device_id_list *dil;
+
+	dm_list_iterate_items(dil, list) {
+		if (dil->dev == dev)
+			return dil;
+	}
+	return NULL;
+}
+
+/*
+ * Validate entries with suspect sys_serial values.  A sys_serial du (devices
+ * file entry) matched a device with the same serial number, but the PVID did
+ * not match.  Check if multiple devices have the same serial number, and if so
+ * pair the devs to the du's based on PVID.  This requires searching all devs
+ * for the given serial number, and then reading the PVID from all those devs.
+ * This may involve reading labels from devs outside the devices file.
+ * (This could also be done for duplicate wwids if needed.)
+ */
+void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
+			     int *update_needed, int noupdate)
+{
+	struct dm_list dus_check; /* dev_use_list */
+	struct dm_list devs_check; /* device_list */
+	struct dm_list prev_devs; /* device_id_list */
+	struct dev_use_list *dul;
+	struct device_list *devl, *devl2;
+	struct device_id_list *dil;
+	struct device *dev;
+	struct dev_use *du;
+	char *tmpdup;
+	int update_file = 0;
+	int has_pvid;
+	int found;
+	int count;
+
+	dm_list_init(&dus_check);
+	dm_list_init(&devs_check);
+	dm_list_init(&prev_devs);
+
+	/*
+	 * Create list of du's with a suspect serial number.  These du's will
+	 * be rematched to a device using pvid.  The device_ids_check_serial
+	 * list was created by device_ids_validate() when it found that the
+	 * PVID on the dev did not match the PVID in the du that was paired
+	 * with the dev.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->dev && (du->idtype == DEV_ID_TYPE_SYS_SERIAL) &&
+		    str_list_match_item(&cmd->device_ids_check_serial, du->idname)) {
+			if (!(dul = dm_pool_zalloc(cmd->mem, sizeof(*dul))))
+				continue;
+			dul->du = du;
+			dm_list_add(&dus_check, &dul->list);
+		}
+	}
+
+	/*
+	 * Create list of devs on the system with suspect serial numbers.
+	 * Read the serial number of each dev in dev cache, and return
+	 * devs that match the suspect serial numbers.
+	 */
+	log_debug("Finding all devs with suspect serial numbers.");
+	_get_devs_with_serial_numbers(cmd, &cmd->device_ids_check_serial, &devs_check);
+
+	/*
+	 * Read the PVID from any devs_check entries that have not been scanned
+	 * yet (this is where some devs outside the devices file may be read.)
+	 * If the dev has no PVID or is excluded by filters, then there's no
+	 * point in trying to match it to one of the dus_check entries.
+	 */
+	log_debug("Reading and filtering %d devs with suspect serial numbers.", dm_list_size(&devs_check));
+	dm_list_iterate_items_safe(devl, devl2, &devs_check) {
+		const char *idname;
+		if (!(idname = _dev_idname(devl->dev, DEV_ID_TYPE_SYS_SERIAL))) {
+			log_debug("serial missing for %s", dev_name(devl->dev));
+			continue;
+		}
+		if (devl->dev->flags & DEV_SCAN_FOUND_LABEL) {
+			log_debug("serial %s pvid %s %s", idname, devl->dev->pvid, dev_name(devl->dev));
+			continue;
+		}
+		if (devl->dev->flags & DEV_SCAN_FOUND_NOLABEL) {
+			log_debug("serial %s nolabel %s", idname, dev_name(devl->dev));
+			continue;
+		}
+
+		dev = devl->dev;
+		has_pvid = 0;
+
+		label_read_pvid(dev, &has_pvid);
+		if (!has_pvid) {
+			log_debug("serial %s no pvid %s", idname, dev_name(devl->dev));
+			dm_list_del(&devl->list);
+			continue;
+		}
+
+		/* data-based filters use data read by label_read_pvid */
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "partitioned") ||
+		    !cmd->filter->passes_filter(cmd, cmd->filter, dev, "signature") ||
+		    !cmd->filter->passes_filter(cmd, cmd->filter, dev, "md") ||
+		    !cmd->filter->passes_filter(cmd, cmd->filter, dev, "fwraid")) {
+			log_debug("serial %s pvid %s filtered %s", idname, devl->dev->pvid, dev_name(devl->dev));
+			dm_list_del(&devl->list);
+		}
+	}
+
+	log_debug("Checking %d PVs with suspect serial numbers.", dm_list_size(&devs_check));
+
+	/*
+	 * Unpair du's and dev's that were matched using suspect serial numbers
+	 * so that things can be matched again using PVID.  If current pairings
+	 * are correct they will just be matched again.  Save the previous
+	 * pairings so that we can detect when a wrong pairing was corrected.
+	 */
+	dm_list_iterate_items(dul, &dus_check) {
+		if (!dul->du->dev)
+			continue;
+		/* save previously matched devs so they can be dropped from
+		   lvmcache at the end if they are no longer used */
+		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
+			continue;
+		du = dul->du;
+		dil->dev = du->dev;
+		memcpy(dil->pvid, du->pvid, ID_LEN);
+		dm_list_add(&prev_devs, &dil->list);
+		du->dev->flags &= ~DEV_MATCHED_USE_ID;
+		du->dev = NULL;
+	}
+
+	/*
+	 * Match du to a dev based on PVID.
+	 */
+	dm_list_iterate_items(dul, &dus_check) {
+		log_debug("Matching suspect serial device id %s PVID %s prev %s",
+			  dul->du->idname, dul->du->pvid, dul->du->devname);
+		found = 0;
+		dm_list_iterate_items(devl, &devs_check) {
+			if (!memcmp(dul->du->pvid, devl->dev->pvid, ID_LEN)) {
+				/* pair dev and du */
+				du = dul->du;
+				dev = devl->dev;
+				du->dev = dev;
+				dev->flags |= DEV_MATCHED_USE_ID;
+
+				log_debug("Match suspect serial device id %s PVID %s to %s",
+					  du->idname, du->pvid, dev_name(dev));
+
+				/* update file if this dev pairing is new or different */
+				if (!(dil = _device_id_list_find_dev(&prev_devs, dev)))
+					update_file = 1;
+				else if (memcmp(dil->pvid, du->pvid, ID_LEN))
+					update_file = 1;
+				found = 1;
+				break;
+			}
+		}
+		if (!found)
+			log_debug("Match PVID failed in %d devs checked.", dm_list_size(&devs_check));
+	}
+
+	/*
+	 * Handle du's with suspect serial numbers that did not have a match
+	 * based on PVID in the previous loop.  If the du matches a device
+	 * based on the serial number, and there is only one instance of that
+	 * serial number on the system, then assume that the PVID in the
+	 * devices file is outdated and pair the du and dev, and update the
+	 * PVID in the devices file.  (This is what's done for du and dev with
+	 * matching wwid but unmatching PVID.)
+	 */
+	dm_list_iterate_items(dul, &dus_check) {
+		du = dul->du;
+
+		/* matched in previous loop using pvid */
+		if (du->dev)
+			continue;
+
+		log_debug("Matching suspect serial device id %s unmatched PVID %s prev %s",
+			  du->idname, du->pvid, du->devname);
+		dev = NULL;
+		count = 0;
+		/* count the number of devs using this serial number */
+		dm_list_iterate_items(devl, &devs_check) {
+			if (_dev_has_id(devl->dev, DEV_ID_TYPE_SYS_SERIAL, du->idname)) {
+				dev = devl->dev;
+				count++;
+			}
+			if (count > 1)
+				break;
+		}
+		if (count != 1) {
+			log_warn("No device matches devices file PVID %s with duplicate serial number %s previously %s.",
+				 du->pvid, du->idname, du->devname);
+			continue;
+		}
+
+		log_warn("Device %s with serial number %s has PVID %s (devices file %s)",
+			 dev_name(dev), du->idname, dev->pvid, du->pvid ?: "none");
+		if (!(tmpdup = strdup(dev->pvid)))
+			continue;
+		free(du->pvid);
+		du->pvid = tmpdup;
+		du->dev = dev;
+		dev->flags |= DEV_MATCHED_USE_ID;
+		update_file = 1;
+	}
+
+	/*
+	 * label_scan() was done based on the original du/dev matches, so if
+	 * there were some changes made to the du/dev matches above, then we
+	 * may need to correct the results of the label_scan:
+	 *
+	 * . if some devices were scanned in label_scan, but those devs are no
+	 * longer matched to any du, then we need to clear the scanned info
+	 * from those devs from lvmcache.
+	 *
+	 * . if some devices were not scanned in label_scan, but those devs are
+	 * now matched to a du, then we need to run label_scan on those devs to
+	 * populate lvmcache with info from them (the caller does this.)
+	 */
+
+	/*
+	 * Find devs that were previously matched to a du but now are not.
+	 * Clear the filter state and lvmcache info for them.
+	 */
+	dm_list_iterate_items(dil, &prev_devs) {
+		if (!get_du_for_dev(cmd, dil->dev)) {
+			log_debug("Drop incorrectly matched serial %s", dev_name(dil->dev));
+			cmd->filter->wipe(cmd, cmd->filter, dil->dev, NULL);
+       			lvmcache_del_dev(dil->dev);
+		}
+	}
+
+	/*
+	 * Find devs that are now matched to a du but were not previously
+	 * scanned by label_scan (DEV_SCAN_FOUND_LABEL).  The caller will
+	 * call label_scan on the devs returned in the list.
+	 */
+	dm_list_iterate_items(dul, &dus_check) {
+		if (!(dev = dul->du->dev))
+			continue;
+		if (!(dev->flags & DEV_SCAN_FOUND_LABEL)) {
+			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+				continue;
+			devl->dev = dev;
+			dm_list_add(scan_devs, &devl->list);
+		}
+	}
+
+	/*
+	 * Look for dus_check entries that were originally matched to a dev
+	 * but now are not.  Warn about these like device_ids_match() would.
+	 */
+	dm_list_iterate_items(dul, &dus_check) {
+		if (!dul->du->dev) {
+			du = dul->du;
+			log_warn("Devices file %s %s PVID %s not found.",
+				 idtype_to_str(du->idtype),
+				 du->idname ?: "none",
+				 du->pvid ?: "none");
+			if (du->devname) {
+				free(du->devname);
+				du->devname = NULL;
+				update_file = 1;
+			}
+		}
+	}
+
+	if (update_file && update_needed)
+		*update_needed = 1;
+
+	if (update_file && !noupdate)
+		_device_ids_update_try(cmd);
+}
+
 /*
  * Devices with IDNAME=devname that are mistakenly included by filter-deviceid
  * due to a devname change are fully scanned and added to lvmcache.
@@ -2903,6 +3279,7 @@ void unlock_devices_file(struct cmd_context *cmd)
 void devices_file_init(struct cmd_context *cmd)
 {
 	dm_list_init(&cmd->use_devices);
+	dm_list_init(&cmd->device_ids_check_serial);
 }
 
 void devices_file_exit(struct cmd_context *cmd)
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 700176bb5..bc9292fea 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -35,6 +35,7 @@ int device_ids_match_dev(struct cmd_context *cmd, struct device *dev);
 void device_ids_match_device_list(struct cmd_context *cmd);
 void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int *device_ids_invalid, int noupdate);
 int device_ids_version_unchanged(struct cmd_context *cmd);
+void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs, int *update_needed, int noupdate);
 void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype);
 void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg, struct id *old_vg_id);
diff --git a/test/shell/devicesfile-serial.sh b/test/shell/devicesfile-serial.sh
new file mode 100644
index 000000000..b7bfce29e
--- /dev/null
+++ b/test/shell/devicesfile-serial.sh
@@ -0,0 +1,777 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='device id wwid from vpd_pg83'
+
+. lib/inittest
+
+test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"
+
+aux lvmconf 'devices/use_devicesfile = 1'
+# requires trailing / to match dm
+aux lvmconf 'devices/device_id_sysfs_dir = "/test/sys/"'
+SYS_DIR="/test/sys"
+
+
+# The string format of the serial numbers
+# encoded in the pg80 files
+SERIAL1=003dd33a331c183c2300e1d883604609
+SERIAL2=003dd33a441c183c2300e1d883604609
+SERIAL3=003dd33a551c183c2300e1d883604609
+SERIAL4=003dd33a661c183c2300e1d883604609
+
+create_base() {
+	mkdir -p $SYS_DIR/dev/block
+	mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+	mkdir -p $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device
+	mkdir -p $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device
+	mkdir -p $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device
+
+	# Create four different pg80 serial numbers that
+	# can be assigned to devs
+
+	echo -n "0080 0020 3030 3364 6433 3361 3333 3163 \
+	3138 3363 3233 3030 6531 6438 3833 3630 3436 3039" | xxd -r -p > pg80_1
+
+	echo -n "0080 0020 3030 3364 6433 3361 3434 3163 \
+	3138 3363 3233 3030 6531 6438 3833 3630 3436 3039" | xxd -r -p > pg80_2
+
+	echo -n "0080 0020 3030 3364 6433 3361 3535 3163 \
+	3138 3363 3233 3030 6531 6438 3833 3630 3436 3039" | xxd -r -p > pg80_3
+
+	echo -n "0080 0020 3030 3364 6433 3361 3636 3163 \
+	3138 3363 3233 3030 6531 6438 3833 3630 3436 3039" | xxd -r -p > pg80_4
+}
+
+remove_base() {
+	rm -rf $SYS_DIR
+}
+
+modprobe brd
+sleep 2
+remove_base
+
+dev1=/dev/ram0
+dev2=/dev/ram1
+dev3=/dev/ram2
+dev4=/dev/ram3
+
+DFDIR="$LVM_SYSTEM_DIR/devices"
+mkdir -p "$DFDIR" || true
+DF="$DFDIR/system.devices"
+ORIG="$DFDIR/orig.devices"
+touch $DF
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+vgcreate $vg1 "$dev1"
+MAJOR1=`pvs "$dev1" --noheading -o major | tr -d - | awk '{print $1}'`
+MINOR1=`pvs "$dev1" --noheading -o minor | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+vgcreate $vg2 "$dev2"
+MAJOR2=`pvs "$dev2" --noheading -o major | tr -d - | awk '{print $1}'`
+MINOR2=`pvs "$dev2" --noheading -o minor | tr -d - | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+vgcreate $vg3 "$dev3"
+MAJOR3=`pvs "$dev3" --noheading -o major | tr -d - | awk '{print $1}'`
+MINOR3=`pvs "$dev3" --noheading -o minor | tr -d - | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+vgcreate $vg4 "$dev4"
+MAJOR4=`pvs "$dev4" --noheading -o major | tr -d - | awk '{print $1}'`
+MINOR4=`pvs "$dev4" --noheading -o minor | tr -d - | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+create_base
+
+
+# get serial number from pg80
+cp pg80_1 $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg80
+cp pg80_2 $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/vpd_pg80
+cp pg80_3 $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/vpd_pg80
+cp pg80_4 $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/vpd_pg80
+
+rm $DF
+lvmdevices --adddev "$dev1"
+grep $SERIAL1 $DF
+lvmdevices --adddev "$dev2"
+grep $SERIAL2 $DF
+lvmdevices --adddev "$dev3"
+grep $SERIAL3 $DF
+lvmdevices --adddev "$dev4"
+grep $SERIAL4 $DF
+cat $DF
+cp $DF $ORIG
+pvs
+# run command to update metadata so deviceids are written to metadata
+vgchange --addtag x $vg1
+vgchange --addtag x $vg2
+vgchange --addtag x $vg3
+vgchange --addtag x $vg4
+pvs -o uuid,deviceidtype,deviceid "$dev1" |tee out
+grep $OPVID1 out
+grep sys_serial out
+grep $SERIAL1 out
+pvs -o uuid,deviceidtype,deviceid "$dev2" |tee out
+grep $OPVID2 out
+grep sys_serial out
+grep $SERIAL2 out
+
+# get serial number from device/serial
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg80
+rm $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/vpd_pg80
+rm $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/vpd_pg80
+rm $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/vpd_pg80
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL2 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL3 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL4 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+pvcreate $dev1
+pvcreate $dev2
+pvcreate $dev3
+pvcreate $dev4
+grep $SERIAL1 $DF
+grep $SERIAL2 $DF
+grep $SERIAL3 $DF
+grep $SERIAL4 $DF
+
+# all pvs have the same serial number
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcreate $vg3 $dev3
+vgcreate $vg4 $dev4
+cp $DF $ORIG
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID2 $DF |tee out
+grep $SERIAL1 out
+grep $dev2 out
+grep $PVID3 $DF |tee out
+grep $SERIAL1 out
+grep $dev3 out
+grep $PVID4 $DF |tee out
+grep $SERIAL1 out
+grep $dev4 out
+
+pvs -o+uuid,deviceidtype,deviceid |tee out
+grep $dev1 out
+grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+grep $OPVID1 out
+grep $OPVID2 out
+grep $OPVID3 out
+grep $OPVID4 out
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+grep $vg4 out
+grep sys_serial out
+grep $SERIAL1 out
+
+pvs -o+uuid,deviceid $dev1 |tee out
+grep $OPVID1 out
+grep $SERIAL1 out
+grep $vg1 out
+
+pvs -o+uuid,deviceid $dev2 |tee out
+grep $OPVID2 out
+grep $SERIAL1 out
+grep $vg2 out
+
+pvs -o+uuid,deviceid $dev3 |tee out
+grep $OPVID3 out
+grep $SERIAL1 out
+grep $vg3 out
+
+pvs -o+uuid,deviceid $dev4 |tee out
+grep $OPVID4 out
+grep $SERIAL1 out
+grep $vg4 out
+
+
+# all pvs have the same serial number, df devnames are stale
+# edit DF to make devnames stale
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpnm|" orig > tmp1
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1 > tmp2
+sed -e "s|DEVNAME=tmpnm|DEVNAME=$dev2|" tmp2 > tmp3
+sed -e "s|DEVNAME=$dev3|DEVNAME=tmpnm|" tmp3 > tmp4
+sed -e "s|DEVNAME=$dev4|DEVNAME=$dev3|" tmp4 > tmp5
+sed -e "s|DEVNAME=tmpnm|DEVNAME=$dev4|" tmp5 > "$DF"
+cat "$DF"
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $dev3 out |tee out3
+grep $dev4 out |tee out4
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+grep $OPVID4 out4
+grep $SERIAL1 out1
+grep $SERIAL1 out2
+grep $SERIAL1 out3
+grep $SERIAL1 out4
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID2 $DF |tee out
+grep $SERIAL1 out
+grep $dev2 out
+grep $PVID3 $DF |tee out
+grep $SERIAL1 out
+grep $dev3 out
+grep $PVID4 $DF |tee out
+grep $SERIAL1 out
+grep $dev4 out
+
+pvs -o+uuid,deviceid "$dev1"|tee out1
+pvs -o+uuid,deviceid "$dev2"|tee out2
+pvs -o+uuid,deviceid "$dev3"|tee out3
+pvs -o+uuid,deviceid "$dev4"|tee out4
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+grep $OPVID4 out4
+
+# all pvs have the same serial number,
+# dev1 and dev2 have devnames swapped,
+# dev3 has stale PVID in the DF.
+# lvm fixes the stale devnames but does not fix the stale PVID
+# because of the duplicate serial numbers, so dev3 is not found
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpnm|" orig > tmp1
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1 > tmp2
+sed -e "s|PVID=$PVID4|PVID=4SqT4onBxSiv4dot0GRDPtrWqOlrOPH1|" tmp2 > "$DF"
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+not grep $dev4 out
+not grep $OPVID4 out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $dev3 out |tee out3
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+
+not pvs "$dev4"
+
+# dev1&2 have same serial, dev3&4 have same serial
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL2 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL2 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcreate $vg3 $dev3
+vgcreate $vg4 $dev4
+cp $DF $ORIG
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID2 $DF |tee out
+grep $SERIAL1 out
+grep $dev2 out
+grep $PVID3 $DF |tee out
+grep $SERIAL2 out
+grep $dev3 out
+grep $PVID4 $DF |tee out
+grep $SERIAL2 out
+grep $dev4 out
+
+pvs -o+uuid,deviceidtype,deviceid |tee out
+grep $dev1 out
+grep $dev2 out
+grep $dev3 out
+grep $dev4 out
+grep $OPVID1 out
+grep $OPVID2 out
+grep $OPVID3 out
+grep $OPVID4 out
+grep $vg1 out
+grep $vg2 out
+grep $vg3 out
+grep $vg4 out
+grep sys_serial out
+grep $SERIAL1 out
+grep $SERIAL2 out
+
+pvs -o+uuid,deviceid $dev1 |tee out
+grep $OPVID1 out
+grep $SERIAL1 out
+grep $vg1 out
+
+pvs -o+uuid,deviceid $dev2 |tee out
+grep $OPVID2 out
+grep $SERIAL1 out
+grep $vg2 out
+
+pvs -o+uuid,deviceid $dev3 |tee out
+grep $OPVID3 out
+grep $SERIAL2 out
+grep $vg3 out
+
+pvs -o+uuid,deviceid $dev4 |tee out
+grep $OPVID4 out
+grep $SERIAL2 out
+grep $vg4 out
+
+# dev1&2 have serial1 and dev3&4 have serial2, swap devnames
+# edit DF to make devnames stale
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpnm|" orig > tmp1
+sed -e "s|DEVNAME=$dev3|DEVNAME=$dev1|" tmp1 > tmp2
+sed -e "s|DEVNAME=tmpnm|DEVNAME=$dev3|" tmp2 > tmp3
+sed -e "s|DEVNAME=$dev2|DEVNAME=tmpnm|" tmp3 > tmp4
+sed -e "s|DEVNAME=$dev4|DEVNAME=$dev2|" tmp4 > tmp5
+sed -e "s|DEVNAME=tmpnm|DEVNAME=$dev4|" tmp5 > "$DF"
+cat "$DF"
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $dev3 out |tee out3
+grep $dev4 out |tee out4
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+grep $OPVID4 out4
+grep $SERIAL1 out1
+grep $SERIAL1 out2
+grep $SERIAL2 out3
+grep $SERIAL2 out4
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID2 $DF |tee out
+grep $SERIAL1 out
+grep $dev2 out
+grep $PVID3 $DF |tee out
+grep $SERIAL2 out
+grep $dev3 out
+grep $PVID4 $DF |tee out
+grep $SERIAL2 out
+grep $dev4 out
+
+pvs -o+uuid,deviceid "$dev1"|tee out1
+pvs -o+uuid,deviceid "$dev2"|tee out2
+pvs -o+uuid,deviceid "$dev3"|tee out3
+pvs -o+uuid,deviceid "$dev4"|tee out4
+grep $OPVID1 out1
+grep $SERIAL1 out1
+grep $OPVID2 out2
+grep $SERIAL1 out2
+grep $OPVID3 out3
+grep $SERIAL2 out3
+grep $OPVID4 out4
+grep $SERIAL2 out4
+
+
+# all devs have same serial, dev1&4 are pvs, dev2&3 are not pvs
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1
+vgcreate $vg4 $dev4
+cp $DF $ORIG
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID4 $DF |tee out
+grep $SERIAL1 out
+grep $dev4 out
+
+pvs -o+uuid,deviceidtype,deviceid |tee out
+grep $dev1 out
+grep $dev4 out
+grep $OPVID1 out
+grep $OPVID4 out
+grep $vg1 out
+grep $vg4 out
+grep sys_serial out
+grep $SERIAL1 out
+
+pvs -o+uuid,deviceid $dev1 |tee out
+grep $OPVID1 out
+grep $SERIAL1 out
+grep $vg1 out
+
+not pvs -o+uuid,deviceid $dev2
+not pvs -o+uuid,deviceid $dev3
+
+pvs -o+uuid,deviceid $dev4 |tee out
+grep $OPVID4 out
+grep $SERIAL1 out
+grep $vg4 out
+
+# edit DF to make devnames stale
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev2|" orig > tmp1
+sed -e "s|DEVNAME=$dev4|DEVNAME=$dev3|" tmp1 > "$DF"
+cat "$DF"
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev4 out |tee out4
+grep $OPVID1 out1
+grep $OPVID4 out4
+grep $SERIAL1 out1
+grep $SERIAL1 out4
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID4 $DF |tee out
+grep $SERIAL1 out
+grep $dev4 out
+
+pvs -o+uuid,deviceid "$dev1"|tee out1
+pvs -o+uuid,deviceid "$dev4"|tee out4
+grep $OPVID1 out1
+grep $SERIAL1 out1
+grep $OPVID4 out4
+grep $SERIAL1 out4
+
+# one pv with serial, three other non-pvs with same serial
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg2 $dev2
+cp $DF $ORIG
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+
+grep $PVID2 $DF |tee out
+grep $SERIAL1 out
+grep $dev2 out
+
+pvs -o+uuid,deviceidtype,deviceid |tee out
+grep $dev2 out
+grep sys_serial out
+grep $SERIAL1 out
+not grep $dev1 out
+not grep $dev3 out
+not grep $dev4 out
+
+# edit DF to make devname stale
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev3|" orig > "$DF"
+cat "$DF"
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev2 out
+grep $OPVID2 out
+grep $SERIAL1 out
+grep $dev2 "$DF"
+
+# different serial numbers, stale pvid and devname in df,
+# lvm corrects pvid in df because serial number is unique
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL2 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL3 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL4 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcreate $vg3 $dev3
+vgcreate $vg4 $dev4
+cp $DF $ORIG
+grep $SERIAL1 $DF
+grep $SERIAL2 $DF
+grep $SERIAL3 $DF
+grep $SERIAL4 $DF
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+pvs -o+uuid,deviceid
+
+cp $ORIG orig
+sed -e "s|PVID=$PVID1|PVID=bad14onBxSiv4dot0GRDPtrWqOlr1bad|" orig > tmp1
+sed -e "s|PVID=$PVID3|PVID=bad24onBxSiv4dot0GRDPtrWqOlr2bad|" tmp1 > tmp2
+sed -e "s|DEVNAME=$dev1|DEVNAME=.|" tmp2 > "$DF"
+cat $DF
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $dev3 out |tee out3
+grep $dev4 out |tee out4
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+grep $OPVID4 out4
+grep $vg1 out1
+grep $vg2 out2
+grep $vg3 out3
+grep $vg4 out4
+grep $SERIAL1 out1
+grep $SERIAL2 out2
+grep $SERIAL3 out3
+grep $SERIAL4 out4
+
+grep $PVID1 $DF |tee out
+grep $SERIAL1 out
+grep $dev1 out
+grep $PVID2 $DF |tee out
+grep $SERIAL2 out
+grep $dev2 out
+grep $PVID3 $DF |tee out
+grep $SERIAL3 out
+grep $dev3 out
+grep $PVID4 $DF |tee out
+grep $SERIAL4 out
+grep $dev4 out
+
+# duplicate serial on two pvs, two pvs with devname type, all devnames stale
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo "" > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo "" > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcreate $vg3 $dev3
+vgcreate $vg4 $dev4
+cp $DF $ORIG
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+cat $DF
+
+pvs -o+uuid,deviceid
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmpnm|" orig > tmp1
+sed -e "s|DEVNAME=$dev3|DEVNAME=$dev1|" tmp1 > tmp2
+sed -e "s|DEVNAME=tmpnm|DEVNAME=$dev3|" tmp2 > tmp3
+sed -e "s|DEVNAME=$dev2|DEVNAME=tmpnm|" tmp3 > tmp4
+sed -e "s|DEVNAME=$dev4|DEVNAME=$dev2|" tmp4 > tmp5
+sed -e "s|DEVNAME=tmpnm|DEVNAME=$dev4|" tmp5 > "$DF"
+cat $DF
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $dev3 out |tee out3
+grep $dev4 out |tee out4
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+grep $OPVID4 out4
+grep $vg1 out1
+grep $vg2 out2
+grep $vg3 out3
+grep $vg4 out4
+grep $SERIAL1 out1
+grep $SERIAL1 out2
+
+cat $DF
+grep $PVID1 $DF |tee out1
+grep $PVID2 $DF |tee out2
+grep $PVID3 $DF |tee out3
+grep $PVID4 $DF |tee out4
+grep $dev1 out1
+grep $SERIAL1 out1
+grep $dev2 out2
+grep $SERIAL1 out2
+grep $dev3 out3
+grep $dev4 out4
+
+# two pvs with duplicate serial and stale devname, one pv with unique serial and stale pvid
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL3 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+vgcreate $vg3 $dev3
+cp $DF $ORIG
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+cat $DF
+
+pvs -o+uuid,deviceid
+
+cp $ORIG orig
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev4|" orig > tmp1
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1 > tmp2
+sed -e "s|PVID=$dev3|PVID=bad14onBxSiv4dot0GRDPtrWqOlr1bad|" tmp2 > $DF
+cat $DF
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $dev3 out |tee out3
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $OPVID3 out3
+grep $vg1 out1
+grep $vg2 out2
+grep $vg3 out3
+grep $SERIAL1 out1
+grep $SERIAL1 out2
+grep $SERIAL3 out3
+
+cat $DF
+grep $PVID1 $DF |tee out1
+grep $PVID2 $DF |tee out2
+grep $PVID3 $DF |tee out3
+grep $dev1 out1
+grep $SERIAL1 out1
+grep $dev2 out2
+grep $SERIAL1 out2
+grep $dev3 out3
+grep $SERIAL3 out3
+
+remove_base
+rmmod brd
+
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 5d9c0c7b7..e58ab4490 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -124,6 +124,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_list search_pvids;
 	struct dm_list found_devs;
+	struct dm_list scan_devs;
 	struct device_id_list *dil;
 	struct device_list *devl;
 	struct device *dev;
@@ -132,6 +133,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 
 	dm_list_init(&search_pvids);
 	dm_list_init(&found_devs);
+	dm_list_init(&scan_devs);
 
 	if (!setup_devices_file(cmd))
 		return ECMD_FAILED;
@@ -186,6 +188,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		int update_set = arg_is_set(cmd, update_ARG);
 		int search_count = 0;
 		int update_needed = 0;
+		int serial_update_needed = 0;
 		int invalid = 0;
 
 		unlink_searched_devnames(cmd);
@@ -273,6 +276,9 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 			}
 		}
 
+		if (!dm_list_empty(&cmd->device_ids_check_serial))
+			device_ids_check_serial(cmd, &scan_devs, &serial_update_needed, 1);
+
 		/*
 		 * Find and fix any devname entries that have moved to a
 		 * renamed device.
@@ -288,7 +294,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		}
 
 		if (arg_is_set(cmd, update_ARG)) {
-			if (update_needed || !dm_list_empty(&found_devs)) {
+			if (update_needed || serial_update_needed || !dm_list_empty(&found_devs)) {
 				if (!device_ids_write(cmd))
 					goto_bad;
 				log_print("Updated devices file to version %s", devices_file_version());
@@ -301,7 +307,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 			 * needs updates, i.e. running --update would make
 			 * changes.
 			 */
-			if (update_needed) {
+			if (update_needed || serial_update_needed) {
 				log_error("Updates needed for devices file.");
 				goto bad;
 			}

