From: David Teigland <teigland@sourceware.org>
Date: Mon,  7 Nov 2022 17:43:16 +0000 (GMT)
Subject: main - devices: factor common list functions
Message-ID: <20221107174316.046F33858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c98617c593a84e32ff8ee32ecf2382d4e1369c16
Commit:        c98617c593a84e32ff8ee32ecf2382d4e1369c16
Parent:        761b922178c8522fd9abb207ba31bd27f9fa9dc4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 7 11:38:46 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 7 11:38:46 2022 -0600

devices: factor common list functions

which were duplicated in various places
---
 lib/Makefile.in                  |  1 +
 lib/cache/lvmcache.c             | 48 ++++++++---------------------
 lib/cache/lvmcache.h             |  2 --
 lib/device/dev_util.c            | 66 ++++++++++++++++++++++++++++++++++++++++
 lib/device/device.h              | 12 ++++++++
 lib/device/device_id.c           | 17 ++---------
 lib/metadata/metadata-exported.h |  6 ----
 tools/pvscan.c                   |  2 +-
 tools/toollib.c                  | 34 +++------------------
 tools/vgimportclone.c            | 15 ++-------
 10 files changed, 102 insertions(+), 101 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 3380b28fb..50c7a1fd2 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -43,6 +43,7 @@ SOURCES =\
 	device/filesystem.c \
 	device/online.c \
 	device/parse_vpd.c \
+	device/dev_util.c \
 	display/display.c \
 	error/errseg.c \
 	unknown/unknown.c \
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1aa699c83..1ae63b3fc 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -144,28 +144,6 @@ int lvmcache_found_duplicate_vgnames(void)
 	return _found_duplicate_vgnames;
 }
 
-static struct device_list *_get_devl_in_device_list(struct device *dev, struct dm_list *head)
-{
-	struct device_list *devl;
-
-	dm_list_iterate_items(devl, head) {
-		if (devl->dev == dev)
-			return devl;
-	}
-	return NULL;
-}
-
-int dev_in_device_list(struct device *dev, struct dm_list *head)
-{
-	struct device_list *devl;
-
-	dm_list_iterate_items(devl, head) {
-		if (devl->dev == dev)
-			return 1;
-	}
-	return 0;
-}
-
 bool lvmcache_has_duplicate_devs(void)
 {
 	if (dm_list_empty(&_unused_duplicates) && dm_list_empty(&_initial_duplicates))
@@ -192,11 +170,11 @@ void lvmcache_del_dev_from_duplicates(struct device *dev)
 {
 	struct device_list *devl;
 
-	if ((devl = _get_devl_in_device_list(dev, &_initial_duplicates))) {
+	if ((devl = device_list_find_dev(&_initial_duplicates, dev))) {
 		log_debug_cache("delete dev from initial duplicates %s", dev_name(dev));
 		dm_list_del(&devl->list);
 	}
-	if ((devl = _get_devl_in_device_list(dev, &_unused_duplicates))) {
+	if ((devl = device_list_find_dev(&_unused_duplicates, dev))) {
 		log_debug_cache("delete dev from unused duplicates %s", dev_name(dev));
 		dm_list_del(&devl->list);
 	}
@@ -605,7 +583,7 @@ int vg_has_duplicate_pvs(struct volume_group *vg)
 
 bool lvmcache_dev_is_unused_duplicate(struct device *dev)
 {
-	return dev_in_device_list(dev, &_unused_duplicates) ? true : false;
+	return device_list_find_dev(&_unused_duplicates, dev) ? true : false;
 }
 
 static void _warn_unused_duplicates(struct cmd_context *cmd)
@@ -934,7 +912,7 @@ next:
 			}
 
 			/* Remove dev_mpath from altdevs. */
-			if ((devl = _get_devl_in_device_list(dev_mpath, &altdevs)))
+			if ((devl = device_list_find_dev(&altdevs, dev_mpath)))
 				dm_list_del(&devl->list);
 
 			/* Remove info from lvmcache that came from the component dev. */
@@ -1001,7 +979,7 @@ next:
 			}
 
 			/* Remove dev_md from altdevs. */
-			if ((devl = _get_devl_in_device_list(dev_md, &altdevs)))
+			if ((devl = device_list_find_dev(&altdevs, dev_md)))
 				dm_list_del(&devl->list);
 
 			/* Remove info from lvmcache that came from the component dev. */
@@ -1029,7 +1007,7 @@ next:
 			}
 
 			/* Remove dev_md from altdevs. */
-			if ((devl = _get_devl_in_device_list(dev_md, &altdevs)))
+			if ((devl = device_list_find_dev(&altdevs, dev_md)))
 				dm_list_del(&devl->list);
 		}
 
@@ -1107,8 +1085,8 @@ next:
 		if (dev1 == dev2)
 			continue;
 
-		prev_unchosen1 = dev_in_device_list(dev1, &_unused_duplicates);
-		prev_unchosen2 = dev_in_device_list(dev2, &_unused_duplicates);
+		prev_unchosen1 = device_list_find_dev(&_unused_duplicates, dev1) ? 1 :0;
+		prev_unchosen2 = device_list_find_dev(&_unused_duplicates, dev2) ? 1 :0;
 
 		if (!prev_unchosen1 && !prev_unchosen2) {
 			/*
@@ -1118,8 +1096,8 @@ next:
 			 * want the same duplicate preference to be preserved
 			 * in each instance of lvmcache for a single command.
 			 */
-			prev_unchosen1 = dev_in_device_list(dev1, &_prev_unused_duplicate_devs);
-			prev_unchosen2 = dev_in_device_list(dev2, &_prev_unused_duplicate_devs);
+			prev_unchosen1 = device_list_find_dev(&_prev_unused_duplicate_devs, dev1) ? 1 :0;
+			prev_unchosen2 = device_list_find_dev(&_prev_unused_duplicate_devs, dev2) ? 1 : 0;
 		}
 
 		dev1_major = MAJOR(dev1->dev);
@@ -1296,7 +1274,7 @@ next:
 	if (!info) {
 		log_debug_cache("PV %s with duplicates will use %s.", pvid, dev_name(dev1));
 
-		if (!(devl_add = _get_devl_in_device_list(dev1, &altdevs))) {
+		if (!(devl_add = device_list_find_dev(&altdevs, dev1))) {
 			/* shouldn't happen */
 			log_error(INTERNAL_ERROR "PV %s with duplicates no alternate list entry for %s", pvid, dev_name(dev1));
 			dm_list_splice(&new_unused, &altdevs);
@@ -1315,7 +1293,7 @@ next:
 		 * for the current lvmcache device to drop.
 		 */
 
-		if (!(devl_add = _get_devl_in_device_list(dev1, &altdevs))) {
+		if (!(devl_add = device_list_find_dev(&altdevs, dev1))) {
 			/* shouldn't happen */
 			log_error(INTERNAL_ERROR "PV %s with duplicates no alternate list entry for %s", pvid, dev_name(dev1));
 			dm_list_splice(&new_unused, &altdevs);
@@ -2530,7 +2508,7 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 			memcpy(dev->pvid, pvid, ID_LEN);
 
 			/* shouldn't happen */
-			if (dev_in_device_list(dev, &_initial_duplicates))
+			if (device_list_find_dev(&_initial_duplicates, dev))
 				log_debug_cache("Initial duplicate already in list %s", dev_name(dev));
 			else {
 				/*
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 934246274..7dde3cda3 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -186,8 +186,6 @@ int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, const char *pvid_ar
 uint64_t lvmcache_max_metadata_size(void);
 void lvmcache_save_metadata_size(uint64_t val);
 
-int dev_in_device_list(struct device *dev, struct dm_list *head);
-
 bool lvmcache_has_bad_metadata(struct device *dev);
 
 bool lvmcache_has_old_metadata(struct cmd_context *cmd, const char *vgname, const char *vgid, struct device *dev);
diff --git a/lib/device/dev_util.c b/lib/device/dev_util.c
new file mode 100644
index 000000000..2302df462
--- /dev/null
+++ b/lib/device/dev_util.c
@@ -0,0 +1,66 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
+
+int device_id_list_remove(struct dm_list *list, struct device *dev)
+{
+	struct device_id_list *dil;
+
+	dm_list_iterate_items(dil, list) {
+		if (dil->dev == dev) {
+			dm_list_del(&dil->list);
+			return 1;
+		}
+	}
+	return 0;
+}
+
+struct device_id_list *device_id_list_find_dev(struct dm_list *list, struct device *dev)
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
+int device_list_remove(struct dm_list *list, struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, list) {
+		if (devl->dev == dev) {
+			dm_list_del(&devl->list);
+			return 1;
+		}
+	}
+	return 0;
+}
+
+struct device_list *device_list_find_dev(struct dm_list *list, struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, list) {
+		if (devl->dev == dev)
+			return devl;
+	}
+	return NULL;
+}
+
diff --git a/lib/device/device.h b/lib/device/device.h
index a047158d8..446104218 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -179,6 +179,12 @@ struct device_list {
 	struct device *dev;
 };
 
+struct device_id_list {
+	struct dm_list list;
+	struct device *dev;
+	char pvid[ID_LEN + 1];
+};
+
 struct device_area {
 	struct device *dev;
 	uint64_t start;		/* Bytes */
@@ -235,4 +241,10 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 int format_t10_id(const unsigned char *in, int in_bytes, unsigned char *out, int out_bytes);
 int parse_vpd_serial(const unsigned char *in, char *out, int outsize);
 
+/* dev_util */
+int device_id_list_remove(struct dm_list *devices, struct device *dev);
+struct device_id_list *device_id_list_find_dev(struct dm_list *devices, struct device *dev);
+int device_list_remove(struct dm_list *devices, struct device *dev);
+struct device_list *device_list_find_dev(struct dm_list *devices, struct device *dev);
+
 #endif
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 599e357be..aae875776 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2208,7 +2208,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 * scanned_devs are the devices that have been scanned,
 		 * so they are the only devs we can verify PVID for.
 		 */
-		if (scanned_devs && !dev_in_device_list(dev, scanned_devs))
+		if (scanned_devs && !device_list_find_dev(scanned_devs, dev))
 			continue;
 
 		/*
@@ -2310,7 +2310,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 * scanned_devs are the devices that have been scanned,
 		 * so they are the only devs we can verify PVID for.
 		 */
-		if (scanned_devs && !dev_in_device_list(dev, scanned_devs))
+		if (scanned_devs && !device_list_find_dev(scanned_devs, dev))
 			continue;
 
 		/*
@@ -2462,17 +2462,6 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	}
 }
 
-static struct device_id_list *_device_id_list_find_dev(struct dm_list *list, struct device *dev)
-{
-	struct device_id_list *dil;
-
-	dm_list_iterate_items(dil, list) {
-		if (dil->dev == dev)
-			return dil;
-	}
-	return NULL;
-}
-
 /*
  * Validate entries with suspect sys_serial values.  A sys_serial du (devices
  * file entry) matched a device with the same serial number, but the PVID did
@@ -2612,7 +2601,7 @@ void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
 					  du->idname, du->pvid, dev_name(dev));
 
 				/* update file if this dev pairing is new or different */
-				if (!(dil = _device_id_list_find_dev(&prev_devs, dev)))
+				if (!(dil = device_id_list_find_dev(&prev_devs, dev)))
 					update_file = 1;
 				else if (memcmp(dil->pvid, du->pvid, ID_LEN))
 					update_file = 1;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 04f32cace..c7eaa5233 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -590,12 +590,6 @@ struct vgnameid_list {
 	const char *vgid;
 };
 
-struct device_id_list {
-	struct dm_list list;
-	struct device *dev;
-	char pvid[ID_LEN + 1];
-};
-
 #define PV_PE_START_CALC ((uint64_t) -1) /* Calculate pe_start value */
 
 /*
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 1c58e4a5b..96935a43b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -703,7 +703,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	 * devices used by the VG we read.
 	 */
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (dev_in_device_list(pvl->pv->dev, &devs))
+		if (device_list_find_dev(&devs, pvl->pv->dev))
 			continue;
 		log_error_pvscan(cmd, "activation for VG %s found different devices.", vgname);
 		ret = ECMD_FAILED;
diff --git a/tools/toollib.c b/tools/toollib.c
index 5305e811b..ae6f311ba 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4133,32 +4133,6 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _device_list_remove(struct dm_list *devices, struct device *dev)
-{
-	struct device_id_list *dil;
-
-	dm_list_iterate_items(dil, devices) {
-		if (dil->dev == dev) {
-			dm_list_del(&dil->list);
-			return 1;
-		}
-	}
-
-	return 0;
-}
-
-static struct device_id_list *_device_list_find_dev(struct dm_list *devices, struct device *dev)
-{
-	struct device_id_list *dil;
-
-	dm_list_iterate_items(dil, devices) {
-		if (dil->dev == dev)
-			return dil;
-	}
-
-	return NULL;
-}
-
 /* Process devices that are not PVs. */
 
 static int _process_other_devices(struct cmd_context *cmd,
@@ -4263,8 +4237,8 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 	dm_list_iterate_items(devl, &unused_duplicate_devs) {
 		/* Duplicates are displayed if -a is used or the dev is named as an arg. */
 
-		if ((dil = _device_list_find_dev(arg_devices, devl->dev)))
-			_device_list_remove(arg_devices, devl->dev);
+		if ((dil = device_id_list_find_dev(arg_devices, devl->dev)))
+			device_id_list_remove(arg_devices, devl->dev);
 
 		if (!process_other_devices && !dil)
 			continue;
@@ -4384,8 +4358,8 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		/* Remove each arg_devices entry as it is processed. */
 
 		if (arg_devices && !dm_list_empty(arg_devices)) {
-			if ((dil = _device_list_find_dev(arg_devices, pv->dev)))
-				_device_list_remove(arg_devices, dil->dev);
+			if ((dil = device_id_list_find_dev(arg_devices, pv->dev)))
+				device_id_list_remove(arg_devices, dil->dev);
 		}
 
 		if (!process_pv && dil)
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 9e426c942..60ef20762 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -25,17 +25,6 @@ struct vgimportclone_params {
 	unsigned import_vg:1;
 };
 
-static struct device_list *_get_device_list(struct dm_list *list, struct device *dev)
-{
-	struct device_list *devl;
-
-	dm_list_iterate_items(devl, list) {
-		if (devl->dev == dev)
-			return devl;
-	}
-	return NULL;
-}
-
 static int _update_vg(struct cmd_context *cmd, struct volume_group *vg,
 		      struct vgimportclone_params *vp)
 {
@@ -82,7 +71,7 @@ static int _update_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 */
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if ((devl = _get_device_list(&vp->new_devs, pvl->pv->dev))) {
+		if ((devl = device_list_find_dev(&vp->new_devs, pvl->pv->dev))) {
 			dm_list_del(&devl->list);
 			dm_list_add(&tmp_devs, &devl->list);
 		} else {
@@ -192,7 +181,7 @@ static int _get_other_devs(struct cmd_context *cmd, struct dm_list *new_devs, st
 		return_0;
 
 	while ((dev = dev_iter_get(cmd, iter))) {
-		if (_get_device_list(new_devs, dev))
+		if (device_list_find_dev(new_devs, dev))
 			continue;
 		if (!(devl = zalloc(sizeof(*devl)))) {
 			r = 0;

