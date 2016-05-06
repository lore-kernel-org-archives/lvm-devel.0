From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:50 +0000 (UTC)
Subject: master - lvmcache: process duplicate PVs directly
Message-ID: <20160506140050.5C19760722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3d13e134af15611c3f12107aa1627b12110a974
Commit:        d3d13e134af15611c3f12107aa1627b12110a974
Parent:        8b7a78c728be3b9af698dae9344d01752c4cf615
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 11 12:37:36 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

lvmcache: process duplicate PVs directly

Previously, duplicate PVs were processed as a side effect
of processing the "chosen" PV in lvmcache.  The duplicate
PV would be hacked into lvmcache temporarily in place of
the chosen PV.

In the old way, we had to always process the "chosen" PV
device, even if a duplicate of it was named on the command
line.  This meant we were processing a different device than
was asked for.  This could be worked around by naming
multiple duplicate devs on the command line in which case
they were swapped in and out of lvmcache for processing.

Now, the duplicate devs are processed directly in their
own processing loop.  This means we can remove the old
hacks related to processing dups as a side effect of
processing the chosen device.  We can now simply process
the device that was named on the command line.

When the same PVID exists on two or more devices, one device
is preferred and used in the VG, and the others are duplicates
and are not used in the VG.  The preferred device exists in
lvmcache as usual.  The duplicates exist in a specical list
of unused duplicate devices.

The duplicate devs have the "d" attribute and the "duplicate"
reporting field displays "duplicate" for them.

'pvs' warns about duplicates, but the formal output only
includes the single preferred PV.

'pvs -a' has the same warnings, and the duplicate devs are
included in the output.

'pvs <path>' has the same warnings, and displays the named
device, whether it is preferred or a duplicate.
---
 lib/cache/lvmcache.c |   41 +++++-----
 lib/cache/lvmcache.h |    6 +-
 tools/commands.h     |    4 +-
 tools/pvchange.c     |   17 ++++
 tools/toollib.c      |  226 ++++++++++++++++++++++++++++----------------------
 tools/tools.h        |    2 +
 6 files changed, 172 insertions(+), 124 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 14ce68b..ba87312 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -444,6 +444,21 @@ int lvmcache_found_duplicate_pvs(void)
 	return _found_duplicate_pvs;
 }
 
+int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head)
+{
+	struct device_list *devl, *devl2;
+
+	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+		if (!(devl2 = dm_pool_alloc(cmd->mem, sizeof(*devl2)))) {
+			log_error("device_list element allocation failed");
+			return 0;
+		}
+		devl2->dev = devl->dev;
+		dm_list_add(head, &devl2->list);
+	}
+	return 1;
+}
+
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
@@ -683,6 +698,11 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only)
 	return info;
 }
 
+const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info)
+{
+	return info->fmt;
+}
+
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info)
 {
 	if (info->vginfo)
@@ -1868,27 +1888,6 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 }
 
 /*
- * Replace pv->dev with dev so that dev will appear for reporting.
- */
-
-void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
-			  struct device *dev)
-{
-	struct lvmcache_info *info;
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
-
-	strncpy(pvid_s, (char *) &pv->id, sizeof(pvid_s) - 1);
-	pvid_s[sizeof(pvid_s) - 1] = '\0';
-
-	if (!(info = lvmcache_info_from_pvid(pvid_s, 0)))
-		return;
-
-	info->dev = dev;
-	info->label->dev = dev;
-	pv->dev = dev;
-}
-
-/*
  * We can see multiple different devices with the
  * same pvid, i.e. duplicates.
  *
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index c964aec..9b3c67b 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -111,6 +111,7 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 				       const char *devname);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
+const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
 int lvmcache_vgs_locked(void);
 int lvmcache_vgname_is_locked(const char *vgname);
 
@@ -193,11 +194,10 @@ unsigned lvmcache_mda_count(struct lvmcache_info *info);
 int lvmcache_vgid_is_cached(const char *vgid);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
-void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
-			struct device *dev);
-
 int lvmcache_found_duplicate_pvs(void);
 
+int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head);
+
 int vg_has_duplicate_pvs(struct volume_group *vg);
 
 int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
diff --git a/tools/commands.h b/tools/commands.h
index f49e57f..7b32835 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -824,7 +824,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | LOCKD_VG_SH,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -933,7 +933,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | LOCKD_VG_SH,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH,
    "pvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
diff --git a/tools/pvchange.c b/tools/pvchange.c
index e103ebe..e100b80 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -40,6 +40,23 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		goto bad;
 	}
 
+	/*
+	 * The primary location of this check is in vg_write(), but it needs
+	 * to be copied here to prevent the pv_write() which is called before
+	 * the vg_write().
+	 */
+	if (vg && lvmcache_found_duplicate_pvs() && vg_has_duplicate_pvs(vg)) {
+	    	if (!find_config_tree_bool(vg->cmd, devices_allow_changes_with_duplicate_pvs_CFG, NULL)) {
+			log_error("Cannot update volume group %s with duplicate PV devices.",
+				  vg->name);
+			goto bad;
+		}
+		if (arg_count(cmd, uuid_ARG)) {
+			log_error("Resolve duplicate PV UUIDs with vgimportclone (or filters).");
+			goto bad;
+		}
+	}
+
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
 		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 9917a67..429ab91 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2928,18 +2928,6 @@ static struct device_id_list *_device_list_find_dev(struct dm_list *devices, str
 	return NULL;
 }
 
-static struct device_id_list *_device_list_find_pvid(struct dm_list *devices, struct physical_volume *pv)
-{
-	struct device_id_list *dil;
-
-	dm_list_iterate_items(dil, devices) {
-		if (id_equal((struct id *) dil->pvid, &pv->id))
-			return dil;
-	}
-
-	return NULL;
-}
-
 static int _device_list_copy(struct cmd_context *cmd, struct dm_list *src, struct dm_list *dst)
 {
 	struct device_id_list *dil;
@@ -3030,6 +3018,94 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 	return ECMD_PROCESSED;
 }
 
+static int _process_duplicate_pvs(struct cmd_context *cmd,
+				  struct dm_list *all_devices,
+				  struct dm_list *arg_devices,
+				  int process_all_devices,
+				  struct processing_handle *handle,
+				  process_single_pv_fn_t process_single_pv)
+{
+	struct physical_volume pv_dummy;
+	struct physical_volume *pv;
+	struct device_id_list *dil;
+	struct device_list *devl;
+	struct dm_list unused_duplicate_devs;
+	struct lvmcache_info *info;
+	struct volume_group *vg = NULL;
+	const char *vgname = NULL;
+	const char *vgid = NULL;
+	int ret_max = ECMD_PROCESSED;
+	int ret = 0;
+
+	dm_list_init(&unused_duplicate_devs);
+
+	if (!lvmcache_get_unused_duplicate_devs(cmd, &unused_duplicate_devs))
+		return_ECMD_FAILED;
+
+	dm_list_iterate_items(devl, &unused_duplicate_devs) {
+		/* Duplicates are displayed if -a is used or the dev is named as an arg. */
+
+		_device_list_remove(all_devices, devl->dev);
+
+		if (!process_all_devices && dm_list_empty(arg_devices))
+			continue;
+
+		if ((dil = _device_list_find_dev(arg_devices, devl->dev)))
+			_device_list_remove(arg_devices, devl->dev);
+
+		if (!process_all_devices && !dil)
+			continue;
+
+		if (!(cmd->command->flags & ENABLE_DUPLICATE_DEVS))
+			continue;
+
+		/*
+		 * Use the cached VG from the preferred device for the PV,
+		 * the vg is only used to display the VG name.
+		 *
+		 * This VG from lvmcache was not read from the duplicate
+		 * dev being processed here, but from the preferred dev
+		 * in lvmcache.
+		 *
+		 * When a duplicate PV is displayed, the reporting fields
+		 * that come from the VG metadata are not shown, because
+		 * the dev is not a part of the VG, the dev for the
+		 * preferred PV is (also the VG metadata in lvmcache is
+		 * not from the duplicate dev, but from the preferred dev).
+		 */
+
+		log_very_verbose("Processing duplicate device %s.", dev_name(devl->dev));
+
+		info = lvmcache_info_from_pvid(devl->dev->pvid, 0);
+		if (info)
+			vgname = lvmcache_vgname_from_info(info);
+		if (vgname)
+			vgid = lvmcache_vgid_from_vgname(cmd, vgname);
+		if (vgid)
+			vg = lvmcache_get_vg(cmd, vgname, vgid, 0);
+
+		memset(&pv_dummy, 0, sizeof(pv_dummy));
+		dm_list_init(&pv_dummy.tags);
+		dm_list_init(&pv_dummy.segments);
+		pv_dummy.dev = devl->dev;
+		pv_dummy.fmt = lvmcache_fmt_from_info(info);
+		pv = &pv_dummy;
+
+		ret = process_single_pv(cmd, vg, pv, handle);
+
+		if (vg)
+			release_vg(vg);
+
+		if (ret > ret_max)
+			ret_max = ret;
+
+		if (sigint_caught())
+			return_ECMD_FAILED;
+	}
+
+	return ECMD_PROCESSED;
+}
+
 static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct dm_list *all_devices,
@@ -3045,7 +3121,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	struct device_id_list *dil;
-	struct device *dev_orig;
 	const char *pv_name;
 	int selected;
 	int process_pv;
@@ -3082,14 +3157,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			_device_list_remove(arg_devices, dil->dev);
 		}
 
-		/* Select the PV if the device arg has the same pvid. */
-
-		if (!process_pv && !dm_list_empty(arg_devices) &&
-		    (dil = _device_list_find_pvid(arg_devices, pv))) {
-			process_pv = 1;
-			_device_list_remove(arg_devices, dil->dev);
-		}
-
 		if (!process_pv && !dm_list_empty(arg_tags) &&
 		    str_list_match_list(arg_tags, &pv->tags, NULL))
 			process_pv = 1;
@@ -3121,83 +3188,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 				if (ret > ret_max)
 					ret_max = ret;
 			}
-
-			/*
-			 * We have processed the PV on device pv->dev.  Now
-			 * deal with any duplicates of this PV on other
-			 * devices.
-			 */
-
-			/*
-			 * This is a very rare and obscure case where multiple
-			 * duplicate devices are specified on the command line
-			 * referring to this PV.  In this case we want to
-			 * process this PV once for each specified device.
-			 */
-			if (!skip && !dm_list_empty(arg_devices)) {
-				while ((dil = _device_list_find_pvid(arg_devices, pv))) {
-					_device_list_remove(arg_devices, dil->dev);
-
-					/*
-					 * Replace pv->dev with this dil->dev
-					 * in lvmcache so the duplicate dev
-					 * info will be reported.  FIXME: it
-					 * would be nicer to override pv->dev
-					 * without munging lvmcache content.
-					 */
-					dev_orig = pv->dev;
-					lvmcache_replace_dev(cmd, pv, dil->dev);
-
-					log_very_verbose("Processing PV %s device %s in VG %s.",
-							 pv_name, dev_name(dil->dev), vg->name);
-
-					ret = process_single_pv(cmd, vg, pv, handle);
-					if (ret != ECMD_PROCESSED)
-						stack;
-					if (ret > ret_max)
-						ret_max = ret;
-
-					/* Put the cache state back as it was. */
-					lvmcache_replace_dev(cmd, pv, dev_orig);
-				}
-			}
-
-			/*
-			 * This is another rare and obscure case where multiple
-			 * duplicate devices are being displayed by pvs -a, and
-			 * we want each of them to be displayed in the context
-			 * of this VG, so that this VG name appears next to it.
-			 */
-			if (process_all_devices && lvmcache_found_duplicate_pvs()) {
-				while ((dil = _device_list_find_pvid(all_devices, pv))) {
-					_device_list_remove(all_devices, dil->dev);
-
-					dev_orig = pv->dev;
-					lvmcache_replace_dev(cmd, pv, dil->dev);
-
-					ret = process_single_pv(cmd, vg, pv, handle);
-					if (ret != ECMD_PROCESSED)
-						stack;
-					if (ret > ret_max)
-						ret_max = ret;
-
-					lvmcache_replace_dev(cmd, pv, dev_orig);
-				}
-			}
-
-			/*
-			 * Remove any duplicates of the processed device from
-			 * the list of all devices.  If they were left in the
-			 * list of all devices, they would be considered
-			 * "missed" at the end.
-			 */
-			if (process_all_pvs && lvmcache_found_duplicate_pvs()) {
-				while ((dil = _device_list_find_pvid(all_devices, pv))) {
-					log_very_verbose("Skip duplicate device %s of processed device %s",
-							 dev_name(dil->dev), dev_name(pv->dev));
-					_device_list_remove(all_devices, dil->dev);
-				}
-			}
 		}
 
 		/*
@@ -3410,6 +3400,46 @@ int process_each_pv(struct cmd_context *cmd,
 		ret_max = ret;
 
 	/*
+	 * Process the list of unused duplicate devs so they can be shown by
+	 * report/display commands.  These are the devices that were not chosen
+	 * to be used in lvmcache because another device with the same PVID was
+	 * preferred.  The unused duplicate devs are not seen by
+	 * _process_pvs_in_vgs, which only sees the preferred device for the
+	 * PVID.
+	 *
+	 * The main purpose in reporting/displaying the unused duplicate PVs
+	 * here is so that they do not appear to be unused/free devices or
+	 * orphans.
+	 *
+	 * We do not allow modifying the unused duplicate PVs.  To modify a
+	 * non-preferred duplicate PV, e.g. pvchange -u, a filter needs to be
+	 * used with the command to exclude the other devices with the same
+	 * PVID.  This results in the command seeing only the one device with
+	 * the PVID and allows it to be changed.  (If the duplicates actually
+	 * represent the same underlying storage, these precautions are
+	 * unnecessary, but lvm can't tell when the duplicates are different
+	 * paths to the same storage or different underlying storage.)
+	 *
+	 * Even the preferred duplicate PV in lvmcache is limitted from being
+	 * modified (by allow_changes_with_duplicate_pvs setting), because lvm
+	 * cannot be sure that the preferred duplicate device is the correct one,
+	 * e.g. if a VG has two PVs, and both PVs are cloned, lvm might prefer
+	 * one of the original PVs and one of the cloned PVs, pairing them
+	 * together as the VG.  Any changes on the VG or PVs in that state would
+	 * end up changing one of the original PVs and one of the cloned PVs.
+	 *
+	 * vgimportclone of the two cloned PVs changes their PV UUIDs and gives
+	 * them a new VG name.
+	 */
+
+	ret = _process_duplicate_pvs(cmd, &all_devices, &arg_devices, process_all_devices,
+				     handle, process_single_pv);
+	if (ret != ECMD_PROCESSED)
+		stack;
+	if (ret > ret_max)
+		ret_max = ret;
+
+	/*
 	 * If the orphans lock was held, there shouldn't be missed devices.  If
 	 * there were, we cannot clear the cache while holding the orphans lock
 	 * anyway.
diff --git a/tools/tools.h b/tools/tools.h
index 7b1bda3..cfb79de 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -112,6 +112,8 @@ struct arg_value_group_list {
 #define MUST_USE_ALL_ARGS        0x00000100
 /* Command wants to control the device scan for lvmetad itself. */
 #define NO_LVMETAD_AUTOSCAN      0x00000200
+/* Command should process unused duplicate devices. */
+#define ENABLE_DUPLICATE_DEVS    0x00000400
  
 /* a register of the lvm commands */
 struct command {


