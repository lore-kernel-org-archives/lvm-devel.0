From: David Teigland <teigland@sourceware.org>
Date: Fri,  5 Feb 2021 22:25:07 +0000 (GMT)
Subject: main - md component detection changes
Message-ID: <20210205222507.833153857807@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87ee401eea3c3c3958ec5cda6e5c246b80503b8c
Commit:        87ee401eea3c3c3958ec5cda6e5c246b80503b8c
Parent:        67d8fb1e83002f702f9c995ec96ffc723ea0d6ce
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 5 16:16:03 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 5 16:23:51 2021 -0600

md component detection changes

Move extra md component detection into the label scan phase.
It had been in set_pv_devices which was deep within the vg_read
phase, which wasn't a good place (better to detect that earlier.)
Now that pv metadata info is available in the scan phase, the pv
details (size and device_hint) can be used for extra md checking.

Use the device_hint from the pv metadata to trigger a full md
component check if the device_hint begins with /dev/md.

Stop triggering full md component checks based on missing
udev info for a dev.

Changes to tests to reflect that the code is now detecting
md components in some test case that it wasn't before.
---
 lib/cache/lvmcache.c            | 117 ++++++++++++++++++++++++++++++++++------
 lib/cache/lvmcache.h            |   2 +
 lib/format_text/archiver.c      |   2 +-
 lib/format_text/import.c        |   2 +-
 lib/label/label.c               |  40 +++++---------
 lib/metadata/metadata.c         |  39 ++------------
 lib/metadata/metadata.h         |   2 +-
 test/shell/duplicate-pvs-md1.sh |  98 ++++++++++-----------------------
 tools/pvscan.c                  |  30 ++++++++---
 9 files changed, 173 insertions(+), 159 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 495748f22..03c5f4d4f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1028,6 +1028,104 @@ int lvmcache_label_reopen_vg_rw(struct cmd_context *cmd, const char *vgname, con
 	return 1;
 }
 
+/*
+ * During label_scan, the md component filter is applied to each device after
+ * the device header has been read.  This often just checks the start of the
+ * device for an md header, and if the device has an md header at the end, the
+ * md component filter wouldn't detect it.  In some cases, the full md filter
+ * is enabled during label_scan, in which case the md component filter will
+ * check both the start and end of the device for md superblocks.
+ *
+ * In this function, after label_scan is done, we may decide that a full md
+ * component check should be applied to a device if it hasn't been yet.  This
+ * is based on some clues or uncertainty that arose during label_scan.
+ *
+ * label_scan saved metadata info about pvs in lvmcache pvsummaries.  That
+ * pvsummary metadata includes the pv size.  So now, after label_scan is done,
+ * we can compare the pv size with the size of the device the pv was read from.
+ * If the pv and dev sizes do not match, it can sometimes be normal, but other
+ * times it can be a clue that label_scan mistakenly read the pv from an md
+ * component device instead of from the md device itself.  So for unmatching
+ * sizes, we do a full md component check on the device.
+ */
+
+void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
+{
+	struct lvmcache_vginfo *vginfo, *vginfo2;
+	struct lvmcache_info *info, *info2;
+	struct device *dev;
+	const char *device_hint;
+	uint64_t devsize, pvsize;
+	int dropped = 0;
+	int do_check;
+
+	/*
+	 * use_full_md_check: if set then no more needs to be done here,
+	 * all devs have already been fully checked as md components.
+	 *
+	 * md_component_checks "full": use_full_md_check was set, and caused
+	 *  filter-md to already do a full check, no more is needed.
+	 *
+	 * md_component_checks "start": skip end of device md component checks,
+	 *  the start of device has already been checked by filter-md.
+	 *
+	 * md_component_checks "auto": do full checks only when lvm finds some
+	 * clue or reasons to believe it might be useful, which is what this
+	 * function is looking for.
+	 */
+	if (!cmd->md_component_detection || cmd->use_full_md_check ||
+	    !strcmp(cmd->md_component_checks, "none") || !strcmp(cmd->md_component_checks, "start"))
+		return;
+
+	/*
+	 * We want to avoid extra scanning for end-of-device md superblocks
+	 * whenever possible, since it can add up to a lot of extra io if we're
+	 * not careful to do it only when there's a good reason to believe a
+	 * dev is an md component.
+	 *
+	 * If the pv/dev size mismatches are commonly occuring for
+	 * non-md-components then we'll want to stop using that as a trigger
+	 * for the full md check.
+	 */
+
+	dm_list_iterate_items_safe(vginfo, vginfo2, &_vginfos) {
+		dm_list_iterate_items_safe(info, info2, &vginfo->infos) {
+			dev = info->dev;
+			device_hint = _get_pvsummary_device_hint(dev->pvid);
+			pvsize = _get_pvsummary_size(dev->pvid);
+			devsize = dev->size;
+			do_check = 0;
+
+			if (!devsize && !dev_get_size(dev, &devsize))
+				log_debug("No size for %s.", dev_name(dev));
+
+			/*
+			 * PV larger than dev not common; dev larger than PV
+			 * can be common, but not as often as PV larger.
+			 */
+			if (pvsize && devsize && (pvsize != devsize))
+				do_check = 1;
+			else if (device_hint && !strcmp(device_hint, "/dev/md"))
+				do_check = 1;
+
+			if (do_check) {
+				log_debug("extra md component check %llu %llu device_hint %s dev %s",
+					  (unsigned long long)pvsize, (unsigned long long)devsize,
+					  device_hint ?: "none", dev_name(dev));
+
+				if (dev_is_md_component(dev, NULL, 1)) {
+					log_debug("dropping PV from md component %s", dev_name(dev));
+					dev->flags &= ~DEV_SCAN_FOUND_LABEL;
+					/* lvmcache_del will also delete vginfo if info was last one */
+					lvmcache_del(info);
+					lvmcache_del_dev_from_duplicates(dev);
+					cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
+				}
+			}
+		}
+	}
+}
+
 /*
  * Uses label_scan to populate lvmcache with 'vginfo' struct for each VG
  * and associated 'info' structs for those VGs.  Only VG summary information
@@ -1057,13 +1155,9 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	struct dm_list del_cache_devs;
 	struct dm_list add_cache_devs;
 	struct lvmcache_info *info;
-	struct lvmcache_vginfo *vginfo;
 	struct device_list *devl;
-	int vginfo_count = 0;
-
-	int r = 0;
 
-	log_debug_cache("Finding VG info");
+	log_debug_cache("lvmcache label scan begin");
 
 	/*
 	 * Duplicates found during this label scan are added to _initial_duplicates.
@@ -1125,17 +1219,8 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		_warn_unused_duplicates(cmd);
 	}
 
-	r = 1;
-
-	dm_list_iterate_items(vginfo, &_vginfos) {
-		if (is_orphan_vg(vginfo->vgname))
-			continue;
-		vginfo_count++;
-	}
-
-	log_debug_cache("Found VG info for %d VGs", vginfo_count);
-
-	return r;
+	log_debug_cache("lvmcache label scan done");
+	return 1;
 }
 
 int lvmcache_get_vgnameids(struct cmd_context *cmd,
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index fb4ab5562..d00bba575 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -222,4 +222,6 @@ const char *devname_error_reason(const char *devname);
 
 struct metadata_area *lvmcache_get_dev_mda(struct device *dev, int mda_num);
 
+void lvmcache_extra_md_component_checks(struct cmd_context *cmd);
+
 #endif
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 733e62be8..07e9b04e4 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -321,7 +321,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	if (vg)
-		set_pv_devices(tf, vg, NULL);
+		set_pv_devices(tf, vg);
 
 	if (!vg)
 		tf->fmt->ops->destroy_instance(tf);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index a4ea98b00..2dc80f13f 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -231,7 +231,7 @@ static struct volume_group *_import_vg_from_config_tree(struct cmd_context *cmd,
 		if (!(vg = (*vsn)->read_vg(cmd, fid->fmt, fid, cft)))
 			stack;
 		else {
-			set_pv_devices(fid, vg, NULL);
+			set_pv_devices(fid, vg);
 
 			if ((vg_missing = vg_missing_pv_count(vg)))
 				log_verbose("There are %d physical volumes missing.", vg_missing);
diff --git a/lib/label/label.c b/lib/label/label.c
index e6dd4a17e..1e777d7c2 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1205,34 +1205,6 @@ int label_scan(struct cmd_context *cmd)
 		}
 	}
 
-	/*
-	 * Stronger exclusion of md components that might have been
-	 * misidentified as PVs due to having an end-of-device md superblock.
-	 * If we're not using hints, and are not already doing a full md check
-	 * on devs being scanned, then if udev info is missing for a PV, scan
-	 * the end of the PV to verify it's not an md component.  The full
-	 * dev_is_md_component call will do new reads at the end of the dev.
-	 */
-	if (cmd->md_component_detection && !cmd->use_full_md_check && !using_hints &&
-	    !strcmp(cmd->md_component_checks, "auto")) {
-		int once = 0;
-		dm_list_iterate_items(devl, &scan_devs) {
-			if (!(devl->dev->flags & DEV_SCAN_FOUND_LABEL))
-				continue;
-			if (!(devl->dev->flags & DEV_UDEV_INFO_MISSING))
-				continue;
-			if (!once++)
-				log_debug_devs("Scanning end of PVs with no udev info for MD components");
-
-			if (dev_is_md_component(devl->dev, NULL, 1)) {
-				log_debug_devs("Scan dropping PV from MD component %s", dev_name(devl->dev));
-				devl->dev->flags &= ~DEV_SCAN_FOUND_LABEL;
-				lvmcache_del_dev(devl->dev);
-				lvmcache_del_dev_from_duplicates(devl->dev);
-			}
-		}
-	}
-
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
 		free(devl);
@@ -1248,6 +1220,18 @@ int label_scan(struct cmd_context *cmd)
 		free(devl);
 	}
 
+	/*
+	 * Look for md components that might have been missed by filter-md
+	 * during the scan.  With the label scanning complete we have metadata
+	 * available that can sometimes offer a clue that a dev is actually an
+	 * md component (device name hint, pv size vs dev size).  In some of
+	 * those cases we may want to do a full md check on a dev that has been
+	 * scanned.  This is done before hints are written so that any devs
+	 * dropped due to being md components will not be included in a new
+	 * hint file.
+	 */
+	lvmcache_extra_md_component_checks(cmd);
+
 	/*
 	 * If hints were not available/usable, then we scanned all devs,
 	 * and we now know which are PVs.  Save this list of PVs we've
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 266db0a4c..d83cf21a6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3568,14 +3568,12 @@ bad:
  */
 static void _set_pv_device(struct format_instance *fid,
 			   struct volume_group *vg,
-			   struct physical_volume *pv,
-			   int *found_md_component)
+			   struct physical_volume *pv)
 {
 	char buffer[64] __attribute__((aligned(8)));
 	struct cmd_context *cmd = fid->fmt->cmd;
 	struct device *dev;
 	uint64_t size;
-	int do_check = 0;
 
 	if (!(dev = lvmcache_device_from_pvid(cmd, &pv->id, &pv->label_sector))) {
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
@@ -3588,35 +3586,6 @@ static void _set_pv_device(struct format_instance *fid,
 			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
 	}
 
-	/*
-	 * If the device and PV are not the size, it's a clue that we might
-	 * be reading an MD component (but not necessarily). Skip this check
-	 * if md component detection is disabled or if we are already doing
-	 * full a md check in label scan
-	 */
-	if (dev && cmd && cmd->md_component_detection && !cmd->use_full_md_check) {
-		uint64_t devsize = dev->size;
-
-		if (!devsize && !dev_get_size(dev, &devsize))
-			log_debug("No size for %s when setting PV dev.", dev_name(dev));
-
-		/* PV larger than dev not common, check for md component */
-		else if (pv->size > devsize)
-			do_check = 1;
-
-		/* dev larger than PV can be common, limit check to auto mode */
-		else if ((pv->size < devsize) && !strcmp(cmd->md_component_checks, "auto"))
-			do_check = 1;
-
-		if (do_check && dev_is_md_component(dev, NULL, 1)) {
-			log_warn("WARNING: device %s is an md component, not setting device for PV.",
-				 dev_name(dev));
-			dev = NULL;
-			if (found_md_component)
-				*found_md_component = 1;
-		}
-	}
-
 	pv->dev = dev;
 
 	/*
@@ -3658,12 +3627,12 @@ static void _set_pv_device(struct format_instance *fid,
  * Finds the 'struct device' that correponds to each PV in the metadata,
  * and may make some adjustments to vg fields based on the dev properties.
  */
-void set_pv_devices(struct format_instance *fid, struct volume_group *vg, int *found_md_component)
+void set_pv_devices(struct format_instance *fid, struct volume_group *vg)
 {
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, &vg->pvs)
-		_set_pv_device(fid, vg, pvl->pv, found_md_component);
+		_set_pv_device(fid, vg, pvl->pv);
 }
 
 int pv_write(struct cmd_context *cmd,
@@ -4914,7 +4883,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	vg = NULL;
 
 	if (vg_ret)
-		set_pv_devices(fid, vg_ret, &found_md_component);
+		set_pv_devices(fid, vg_ret);
 
 	fid->ref_count--;
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 0f230e441..c6500d488 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -537,6 +537,6 @@ struct id pv_vgid(const struct physical_volume *pv);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
 
-void set_pv_devices(struct format_instance *fid, struct volume_group *vg, int *found_md_component);
+void set_pv_devices(struct format_instance *fid, struct volume_group *vg);
 
 #endif
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index 0e1b83cca..d0016f166 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -188,17 +188,13 @@ lvs -o active $vg |tee out || true
 grep "active" out
 vgchange -an $vg
 
-# The dev name and device_hint don't match so pvscan
-# skips quick activation and scans all devs during
-# activation.  This means it sees the component and
-# the mddev as duplicates and chooses to use the mddev
-# for activation.
+# pvscan activation from component should do nothing
 _clear_online_files
 pvscan --cache -aay "$dev1"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
+not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
 lvs -o active $vg |tee out || true
-grep "active" out
+not grep "active" out
 
 # pvscan activation from mddev first, then try from component which fails
 _clear_online_files
@@ -207,7 +203,9 @@ ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
 lvs -o active $vg |tee out || true
 grep "active" out
-not pvscan --cache -aay "$dev1"
+rm "$RUNDIR/lvm/pvs_online/$PVIDMD"
+pvscan --cache -aay "$dev1"
+not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 
 
 vgchange -an $vg
@@ -280,14 +278,6 @@ aux udev_wait
 # md_component_checks: start (not auto)
 # mddev: stopped             (not started)
 #
-# N.B. This test case is just characterizing the current behavior, even
-# though the behavior it's testing for is not what we'd want to happen.
-# In this scenario, we have disabled/avoided everything that would
-# lead lvm to discover that dev1 is an md component, so dev1 is used
-# as the PV.  Multiple default settings need to be changed to get to
-# this unwanted behavior (md_component_checks,
-# obtain_device_list_from_udev), and other conditions also
-# need to be true (md device stopped).
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
@@ -316,27 +306,19 @@ not grep "$dev1" $HINTS
 not grep "$dev2" $HINTS
 
 # the vg is not seen, normal activation does nothing
-not lvchange -ay $vg/$lv1
+rm $HINTS
 not lvs $vg
+not lvchange -ay $vg/$lv1
 
-# pvscan activation all does nothing because both legs are
-# seen as duplicates which triggers md component check which
-# eliminates the devs
 _clear_online_files
 pvscan --cache -aay
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-# component dev name does not match device_hint in metadata so
-# quick activation is skipped and activation scans all devs.
-# this leads it to see both components as duplicates which
-# triggers full md check which means we see both devs are
-# md components and drop them, leaving no remaining devs
-# on which this vg is seen.
 _clear_online_files
-not pvscan --cache -aay "$dev1"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
+pvscan --cache -aay "$dev1"
+not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -348,14 +330,6 @@ aux wipefs_a "$dev2" || true
 # mddev: stopped             (not started)
 # only one raid image online
 #
-# N.B. This test case is just characterizing the current behavior, even
-# though the behavior it's testing for is not what we'd want to happen.
-# In this scenario, we have disabled/avoided everything that would
-# lead lvm to discover that dev1 is an md component, so dev1 is used
-# as the PV.  Multiple default settings need to be changed to get to
-# this unwanted behavior (md_component_checks,
-# obtain_device_list_from_udev), and multiple other conditions also
-# need to be true (md device stopped, only one leg visible).
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
@@ -377,39 +351,35 @@ cat /proc/mdstat
 aux disable_dev "$dev2"
 
 # pvs does not show the PV
+rm $HINTS
 not pvs "$mddev"
-pvs "$dev1"
+rm $HINTS
+not pvs "$dev1"
+rm $HINTS
 not pvs "$dev2"
+rm $HINTS
 pvs > out
 not grep $mddev out
-grep "$dev1" out
+not grep "$dev1" out
 not grep "$dev2" out
+rm $HINTS
 pvscan --cache
 not grep "$mddev" $HINTS
-grep "$dev1" $HINTS
+not grep "$dev1" $HINTS
 not grep "$dev2" $HINTS
 
-lvchange -ay $vg/$lv1
-lvs $vg
-vgchange -an $vg
+not lvs $vg
 
 _clear_online_files
 pvscan --cache -aay
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-# N.B. not good to activate from component, but result of "start" setting
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
+not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
+not lvs $vg
 
 _clear_online_files
 pvscan --cache -aay "$dev1"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-# N.B. not good to activate from component, but result of "start" setting
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
+not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 aux enable_dev "$dev2"
 aux udev_wait
@@ -597,20 +567,8 @@ not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 _clear_online_files
 pvscan --cache -aay "$dev1" || true
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-# N.B. not good to activate from component, but result of "start" setting
-# Scanning the other two legs sees existing pv online file and warns about
-# duplicate PVID, exiting with error:
-not pvscan --cache -aay "$dev2"
-not pvscan --cache -aay "$dev4"
-
-# Have to disable other legs so we can deactivate since
-# vgchange will detect and eliminate the components due
-# to duplicates and not see the vg.
-aux disable_dev "$dev2"
-aux disable_dev "$dev4"
-vgchange -an $vg
+not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 aux enable_dev "$dev2"
 aux enable_dev "$dev4"
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 45d94c21b..dc24f4e34 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1176,9 +1176,12 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 	struct format_instance *fid;
 	struct metadata_area *mda1, *mda2;
 	struct volume_group *vg;
+	struct physical_volume *pv;
 	const char *vgname;
 	uint32_t ext_version, ext_flags;
+	uint64_t devsize;
 	int do_activate = arg_is_set(cmd, activate_ARG);
+	int do_full_check;
 	int pvs_online;
 	int pvs_offline;
 	int pvs_unknown;
@@ -1233,15 +1236,28 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 			goto online;
 		}
 
-		set_pv_devices(fid, vg, NULL);
+		set_pv_devices(fid, vg);
 
-		/*
-		 * Skip devs that are md components (set_pv_devices can do new
-		 * md check), are shared, or foreign.
-		 */
+		if (!(pv = find_pv(vg, dev))) {
+			log_print("pvscan[%d] PV %s not found in VG %s.", getpid(), dev_name(dev), vg->name);
+			release_vg(vg);
+			continue;
+		}
 
-        	if (dev->flags & DEV_IS_MD_COMPONENT) {
-			log_print("pvscan[%d] PV %s ignore MD component, ignore metadata.", getpid(), dev_name(dev));
+		devsize = dev->size;
+		if (!devsize)
+			dev_get_size(dev, &devsize);
+		do_full_check = 0;
+
+		/* If use_full_md_check is set then this has already been done by filter. */
+		if (!cmd->use_full_md_check) {
+			if (devsize && (pv->size != devsize))
+				do_full_check = 1;
+			if (pv->device_hint && !strncmp(pv->device_hint, "/dev/md", 7))
+				do_full_check = 1;
+		}
+		if (do_full_check && dev_is_md_component(dev, NULL, 1)) {
+			log_print("pvscan[%d] ignore md component %s.", getpid(), dev_name(dev));
 			release_vg(vg);
 			continue;
 		}


