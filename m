From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:19 +0000 (GMT)
Subject: master - pvscan: rework to improve PVs without metadata
Message-ID: <20201022204319.063AB39874CA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3b723cd8d7b0ac3c7580ab6861666178bfba34f
Commit:        f3b723cd8d7b0ac3c7580ab6861666178bfba34f
Parent:        a7f195b7e8f27c292761c604c1697c1d97cd5c1d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 15 14:11:08 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 22 13:14:31 2020 -0500

pvscan: rework to improve PVs without metadata

Restructure the pvscan code, and add new temporary files
that list pvids in a VG, used for processing PVs that
have no metadata.

The new temp files, in /run/lvm/pvs_lookup/<vgname>, allow a
proper pvscan --cache to be done on PVs that have no metadata.
pvscan --cache <dev> is only supposed to read <dev>, but when
<dev> has no metadata, this had not been possible.  The
command had to fall back to scanning all devices to read all
VG metadata to get the list of all PVIDs needed to check for
a complete VG.  Now, the temp file can be used in place of
reading metadata from all PVs on the system.
---
 test/shell/hints.sh               |    2 +-
 test/shell/metadata-bad-text.sh   |   29 +-
 test/shell/pvscan-autoactivate.sh |    8 +-
 tools/pvscan.c                    | 1312 ++++++++++++++++++++-----------------
 4 files changed, 733 insertions(+), 618 deletions(-)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 5ac72282b..b2a53c678 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -330,7 +330,7 @@ rm $HINTS $PREV
 pvs
 cp $HINTS $PREV
 # this next pvscan creates newhints to trigger a refresh
-pvscan --cache "$dev5"
+pvscan --cache "$dev4"
 cat $NEWHINTS
 # this next pvs creates new hints
 pvs
diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 421706a9e..971b861ca 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -297,20 +297,13 @@ vgchange -an $vg
 _clear_online_files
 
 # pvscan of one dev with bad metadata will result
-# in the dev acting like a PV without metadata,
-# which causes pvscan to scan all devs to find the
-# VG it belongs to.  In this case it finds all the
-# other devs in the VG are online and activates the
-# VG.
+# in the pvid online file being created but the 
+# VG will not be known.
 pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
-ls "$RUNDIR/lvm/pvs_online/$PVID2"
-ls "$RUNDIR/lvm/pvs_online/$PVID3"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-
-lvs $vg
-check lv_field $vg/$lv1 lv_active "active"
-vgchange -an $vg
+not ls "$RUNDIR/lvm/pvs_online/$PVID2"
+not ls "$RUNDIR/lvm/pvs_online/$PVID3"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
 
 _clear_online_files
 
@@ -321,18 +314,6 @@ not ls "$RUNDIR/lvm/pvs_online/$PVID2"
 ls "$RUNDIR/lvm/pvs_online/$PVID3"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-# scan the next pv with bad metadata, causes pvscan to scan
-# and find all PVs and activate
-pvscan --cache -aay "$dev2"
-ls "$RUNDIR/lvm/pvs_online/$PVID1"
-ls "$RUNDIR/lvm/pvs_online/$PVID2"
-ls "$RUNDIR/lvm/pvs_online/$PVID3"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-
-check lv_field $vg/$lv1 lv_active "active"
-vgchange -an $vg
-
-
 vgck --updatemetadata $vg
 
 pvs 2>&1 | tee out
diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index d79a7e3b9..9f7fc2ee7 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -16,6 +16,7 @@ RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
 VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+PVS_LOOKUP_DIR="$RUNDIR/lvm/pvs_lookup"
 
 # FIXME: kills logic for running system
 _clear_online_files() {
@@ -23,6 +24,7 @@ _clear_online_files() {
 	aux udev_wait
 	rm -f "$PVS_ONLINE_DIR"/*
 	rm -f "$VGS_ONLINE_DIR"/*
+	rm -f "$PVS_LOOKUP_DIR"/*
 }
 
 . lib/inittest
@@ -34,6 +36,7 @@ lvcreate -n $lv1 -l 4 -a n $vg1
 
 test -d "$PVS_ONLINE_DIR" || mkdir -p "$PVS_ONLINE_DIR"
 test -d "$VGS_ONLINE_DIR" || mkdir -p "$VGS_ONLINE_DIR"
+test -d "$PVS_LOOKUP_DIR" || mkdir -p "$PVS_LOOKUP_DIR"
 _clear_online_files
 
 # check pvscan with no args scans and activates all
@@ -93,12 +96,9 @@ pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
-# test case where dev without metadata is scanned first
-# which triggers scanning all, which finds both
-
 _clear_online_files
 pvscan --cache -aay "$dev1"
-check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv1 lv_active ""
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 4d811da55..55c708682 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -36,9 +36,15 @@ struct pvscan_aa_params {
 	unsigned int activate_errors;
 };
 
+/*
+ * Used by _pvscan_aa_quick() which is an optimization used
+ * when one vg is being activated.
+ */
+static struct volume_group *saved_vg;
 
 static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
 static const char *_vgs_online_dir = DEFAULT_RUN_DIR "/vgs_online";
+static const char *_pvs_lookup_dir = DEFAULT_RUN_DIR "/pvs_lookup";
 
 static int _pvscan_display_pv(struct cmd_context *cmd,
 				  struct physical_volume *pv,
@@ -234,6 +240,20 @@ static int _online_pvid_file_read(char *path, int *major, int *minor, char *vgna
 	return 1;
 }
 
+static void _lookup_file_remove(char *vgname)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, vgname) < 0) {
+		log_error("Path %s/%s is too long.", _pvs_lookup_dir, vgname);
+		return;
+	}
+
+	log_debug("Unlink pvs_lookup: %s", path);
+
+	if (unlink(path))
+		log_sys_debug("unlink", path);
+}
 
 /*
  * When a PV goes offline, remove the vg online file for that VG
@@ -295,8 +315,10 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 			if (unlink(path))
 				log_sys_debug("unlink", path);
 
-			if (file_vgname[0])
+			if (file_vgname[0]) {
 				_online_vg_file_remove(file_vgname);
+				_lookup_file_remove(file_vgname);
+			}
 		}
 	}
 	if (closedir(dir))
@@ -349,13 +371,13 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 	}
 
 	if ((len1 = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
-		log_error("Cannot create online pv file for %d:%d.", major, minor);
+		log_error("Cannot create online file path for %s %d:%d.", dev_name(dev), major, minor);
 		return 0;
 	}
 
 	if (vgname) {
 		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
-			log_warn("Incomplete online pv file for %d:%d vg %s.", major, minor, vgname);
+			log_warn("Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
 			/* can still continue without vgname */
 			len2 = 0;
 		}
@@ -369,18 +391,19 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 	if (fd < 0) {
 		if (errno == EEXIST)
 			goto check_duplicate;
-		log_error("Failed to open create %s: %d", path, errno);
+		log_error("Failed to create online file for %s path %s error %d", dev_name(dev), path, errno);
 		return 0;
 	}
 
 	while (len > 0) {
 		rv = write(fd, buf, len);
 		if (rv < 0) {
-			log_error("Failed to write fd %d buf %s dev %s to %s: %d",
-			          fd, buf, dev_name(dev), path, errno);
+			/* file exists so it still works in part */
+			log_warn("Cannot write online file for %s to %s error %d",
+				  dev_name(dev), path, errno);
 			if (close(fd))
 				log_sys_debug("close", path);
-			return 0;
+			return 1;
 		}
 		len -= rv;
 	}
@@ -440,412 +463,258 @@ static int _online_pvid_file_exists(const char *pvid)
 
 	rv = stat(path, &buf);
 	if (!rv) {
-		log_debug("Check pv online: yes");
+		log_debug("Check pv online %s: yes", pvid);
 		return 1;
 	}
-	log_debug("Check pv online: no");
+	log_debug("Check pv online %s: no", pvid);
 	return 0;
 }
 
-static void _online_dir_setup(void)
-{
-	struct stat st;
-	int rv;
-
-	if (!stat(DEFAULT_RUN_DIR, &st))
-		goto do_pvs;
-
-	log_debug("Creating run_dir.");
-	dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
-	rv = mkdir(DEFAULT_RUN_DIR, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
-		log_error("Failed to create %s %d", DEFAULT_RUN_DIR, errno);
-
-do_pvs:
-	if (!stat(_pvs_online_dir, &st))
-		goto do_vgs;
-
-	log_debug("Creating pvs_online_dir.");
-	dm_prepare_selinux_context(_pvs_online_dir, S_IFDIR);
-	rv = mkdir(_pvs_online_dir, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(_pvs_online_dir, &st))
-		log_error("Failed to create %s %d", _pvs_online_dir, errno);
-
-do_vgs:
-	if (!stat(_vgs_online_dir, &st))
-		return;
-
-	log_debug("Creating vgs_online_dir.");
-	dm_prepare_selinux_context(_vgs_online_dir, S_IFDIR);
-	rv = mkdir(_vgs_online_dir, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(_vgs_online_dir, &st))
-		log_error("Failed to create %s %d", _vgs_online_dir, errno);
-}
-
-static int _online_pv_found(struct cmd_context *cmd,
-			    struct device *dev, struct dm_list *dev_args,
-			    struct volume_group *vg,
-			    struct dm_list *found_vgnames)
+static int _write_lookup_file(struct cmd_context *cmd, struct volume_group *vg)
 {
+	char path[PATH_MAX];
+	char line[ID_LEN+2];
 	struct pv_list *pvl;
-	int pvids_not_online = 0;
-	int dev_args_in_vg = 0;
-
-	/*
-	 * Create file named for pvid to record this PV is online.
-	 */
+	int fd;
 
-	if (!_online_pvid_file_create(dev, vg ? vg->name : NULL))
-		return_0;
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, vg->name) < 0) {
+		log_error("Path %s/%s is too long.", _pvs_lookup_dir, vg->name);
+		return 0;
+	}
 
-	if (!vg || !found_vgnames) {
-		log_print("pvscan[%d] PV %s online.", getpid(), dev_name(dev));
-		return 1;
+	fd = open(path, O_CREAT | O_EXCL | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		/* not a problem, can happen when multiple pvscans run@once */
+		log_debug("Did not create %s: %d", path, errno);
+		return 0;
 	}
 
-	/*
-	 * Check if all the PVs for this VG are online.  This is only
-	 * needed when autoactivating the VG which should be run only
-	 * when the VG is complete.  If the arrival of this dev completes
-	 * the VG, then we want to activate the VG.
-	 */
+	log_debug("write_lookup_file %s", path);
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!_online_pvid_file_exists((const char *)&pvl->pv->id.uuid))
-			pvids_not_online++;
-
-		/* Check if one of the devs on the command line is in this VG. */
-		if (dev_args && dev_in_device_list(pvl->pv->dev, dev_args))
-			dev_args_in_vg = 1;
-	}
-
-	/*
-	 * Return if we did not find an online file for one of the PVIDs
-	 * in the VG, which means the VG is not yet complete.
-	 */
+		memcpy(&line, &pvl->pv->id.uuid, ID_LEN);
+		line[ID_LEN] = '\n';
+		line[ID_LEN+1] = '\0';
 
-	if (pvids_not_online) {
-		log_print("pvscan[%d] PV %s online, VG %s incomplete (need %d).",
-			  getpid(), dev_name(dev), vg->name, pvids_not_online);
-		return 1;
+		if (write(fd, &line, ID_LEN+1) < 0)
+			log_sys_debug("write", path);
 	}
 
-	log_print("pvscan[%d] PV %s online, VG %s is complete.", getpid(), dev_name(dev), vg->name);
-
-	/*
-	 * When all PVIDs from the VG are online, then add vgname to
-	 * found_vgnames.
-	 */
-
-	log_debug("online dev %s completes VG %s.", dev_name(dev), vg->name);
-
-	/*
-	 * We either want to return all complete VGs that are found on any devs
-	 * we are scanning, or we want to return complete VGs only when they
-	 * contain PVs that were specified on the command line.
-	 */
-
-	if (!dev_args || dev_args_in_vg) {
-		log_debug("online dev %s can autoactivate VG %s", dev_name(dev), vg->name);
-		if (!str_list_add(cmd->mem, found_vgnames, dm_pool_strdup(cmd->mem, vg->name)))
-			stack;
-	}
+	if (close(fd))
+		log_sys_debug("close", path);
 
 	return 1;
 }
 
-struct _pvscan_baton {
-	struct cmd_context *cmd;
-	struct volume_group *vg;
-	struct format_instance *fid;
-};
-
-/*
- * If no mdas on this PV have a usable copy of the metadata,
- * then the PV behaves like a PV without metadata, which
- * causes the pvscan to scan all devs to find a copy of the
- * metadata on another dev to check if the VG is now complete
- * and can be activated.
- */
-
-static int _online_pvscan_single(struct metadata_area *mda, void *baton)
+static int _lookup_file_contains_pvid(FILE *fp, char *pvid)
 {
-	struct _pvscan_baton *b = baton;
-	struct volume_group *vg;
-	struct device *mda_dev = mda_get_device(mda);
+	char line[64];
 
-	if (mda_is_ignored(mda))
-		return 1;
-	vg = mda->ops->vg_read(b->cmd, b->fid, "", mda, NULL, NULL);
-	if (!vg) {
-		/*
-		 * Many or most cases of bad metadata would be found in
-		 * the scan, and the mda removed from the list, so we
-		 * would not get here to attempt this.
-		 */
-		log_print("pvscan[%d] metadata error in mda %d on %s.",
-			  getpid(), mda->mda_num, dev_name(mda_dev));
-		return 1;
+	while (fgets(line, sizeof(line), fp)) {
+		if (!memcmp(pvid, line, ID_LEN))
+			return 1;
 	}
-
-	log_debug("pvscan vg_read %s seqno %u in mda %d on %s",
-		  vg->name, vg->seqno, mda->mda_num, dev_name(mda_dev));
-
-	if (!b->vg || vg->seqno > b->vg->seqno)
-		b->vg = vg;
-	else if (b->vg)
-		release_vg(vg);
-
-	return 1;
+	return 0;
 }
 
-static struct volume_group *_find_saved_vg(struct dm_list *saved_vgs, const char *vgname)
+static void _lookup_file_count_pvid_files(FILE *fp, const char *vgname, int *pvs_online, int *pvs_offline)
 {
-	struct vg_list *vgl;
+	char line[64];
+	char pvid[ID_LEN+1];
 
-	dm_list_iterate_items(vgl, saved_vgs) {
-		if (!strcmp(vgname, vgl->vg->name))
-			return vgl->vg;
-	}
-	return NULL;
-}
+	log_debug("checking all pvid files using lookup file for %s", vgname);
 
-/*
- * disable_remove is 1 when resetting the online state, which begins with
- * removing all pvid files, and then creating new pvid files for PVs that
- * are found, so we don't need to try to remove pvid files here when a PV
- * is not found on a device.
- */
+	rewind(fp);
 
-static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
-			      struct dm_list *dev_args,
-			      struct dm_list *found_vgnames,
-			      struct dm_list *saved_vgs,
-			      int disable_remove,
-			      const char **pvid_without_metadata)
-{
-	struct lvmcache_info *info;
-	struct vg_list *vgl;
-	struct _pvscan_baton baton;
-	const struct format_type *fmt;
-	/* Create a dummy instance. */
-	struct format_instance_ctx fic = { .type = 0 };
-	uint32_t ext_version;
-	uint32_t ext_flags;
-	int ret = 0;
-
-	log_debug("pvscan metadata from dev %s", dev_name(dev));
-
-	if (udev_dev_is_mpath_component(dev)) {
-		log_print("pvscan[%d] ignore multipath component %s.", getpid(), dev_name(dev));
-		return 1;
-	}
+	while (fgets(line, sizeof(line), fp)) {
+		memset(pvid, 0, sizeof(pvid));
+		memcpy(pvid, line, ID_LEN);
 
-	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
-		log_debug("No PV info found on %s for PVID %s.", dev_name(dev), dev->pvid);
-		if (!disable_remove)
-			_online_pvid_file_remove_devno((int)MAJOR(dev->dev), (int)MINOR(dev->dev));
-		return 1;
-	}
+		if (strlen(pvid) != ID_LEN) {
+			log_debug("ignore lookup file line %s", line);
+			continue;
+		}
 
-	if (!lvmcache_get_label(info)) {
-		log_debug("No PV label found for %s.", dev_name(dev));
-		if (!disable_remove)
-			_online_pvid_file_remove_devno((int)MAJOR(dev->dev), (int)MINOR(dev->dev));
-		return 1;
+		if (_online_pvid_file_exists((const char *)pvid))
+			(*pvs_online)++;
+		else
+			(*pvs_offline)++;
 	}
+}
 
-	ext_version = lvmcache_ext_version(info);
-	ext_flags = lvmcache_ext_flags(info);
+/*
+ * There is no synchronization between the one doing write_lookup_file and the
+ * other doing check_lookup_file.  The pvscan doing write thinks the VG is
+ * incomplete, and the pvscan doing check may also conclude the VG is
+ * incomplete if it happens prior to the write.  If neither pvscan thinks the
+ * VG is complete then neither will activate it.  To solve this race, the
+ * pvscan doing write will recheck pvid online files after the write in which
+ * case it would find the pvid online file from the pvscan doing check.
+ */
 
-	if ((ext_version >= 2) && !(ext_flags & PV_EXT_USED)) {
-		log_print("pvscan[%d] PV %s not used.", getpid(), dev_name(dev));
-		return 1;
-	}
+/*
+ * The VG is not yet complete, more PVs need to arrive, and
+ * some of those PVs may not have metadata on them.  Without
+ * metadata, pvscan for those PVs will be unable to determine
+ * if the VG is complete.  We don't know if other PVs will have
+ * metadata or not.
+ *
+ * Save a temp file with a list of pvids in the vg, to be used
+ * by a later pvscan on a PV without metadata.  The later
+ * pvscan will check for vg completeness using the temp file
+ * since it has no vg metadata to use.
+ *
+ * Only the first pvscan for the VG creates the temp file.  If
+ * there are multiple pvscans for the same VG running at once,
+ * they all race to create the lookup file, and only the first
+ * to create the file will write it.
+ *
+ * After writing the temp file, we count pvid online files for
+ * the VG again - the VG could now be complete since multiple
+ * pvscans will run concurrently.  We repeat this to cover a
+ * race where another pvscan was running _check_lookup_file
+ * during our _write_lookup_file.  _write_lookup_file may not
+ * have finished before _check_lookup_file, which would cause
+ * the other pvscan to not find the pvid it's looking for, and
+ * conclude the VG is incomplete, while we also think the VG is
+ * incomplete.  If we recheck online files after write_lookup,
+ * we will see the pvid online file from the other pvscan and
+ * see the VG is complete.
+ */
 
-	fmt = lvmcache_fmt(info);
+static int _count_pvid_files_from_lookup_file(struct cmd_context *cmd, struct device *dev,
+					       int *pvs_online, int *pvs_offline,
+					       const char **vgname_out)
+{
+	char path[PATH_MAX];
+	FILE *fp;
+	DIR *dir;
+	struct dirent *de;
+	const char *vgname = NULL;
+	int online = 0, offline = 0;
 
-	memset(&baton, 0, sizeof(baton));
-	baton.cmd = cmd;
-	baton.vg = NULL;
-	baton.fid = fmt->ops->create_instance(fmt, &fic);
+	*pvs_online = 0;
+	*pvs_offline = 0;
 
-	if (!baton.fid) {
-		ret = 0;
-		goto_out;
-	}
+	if (!(dir = opendir(_pvs_lookup_dir)))
+		goto_bad;
 
-	lvmcache_foreach_mda(info, _online_pvscan_single, &baton);
+	/*
+	 * Read each file in pvs_lookup to find dev->pvid, and if it's
+	 * found save the vgname of the file it's found in.
+	 */
+	while ((de = readdir(dir))) {
+		if (de->d_name[0] == '.')
+			continue;
 
-	if (!baton.vg) {
-		log_print("pvscan[%d] PV %s has no VG metadata.", getpid(), dev_name(dev));
-		if (pvid_without_metadata)
-			*pvid_without_metadata = dm_pool_strdup(cmd->mem, dev->pvid);
-		fmt->ops->destroy_instance(baton.fid);
-	} else {
-		set_pv_devices(baton.fid, baton.vg, NULL);
-	}
+		memset(path, 0, sizeof(path));
+		snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, de->d_name);
 
-	/* This check repeated because set_pv_devices can do new md check. */
-	if (dev->flags & DEV_IS_MD_COMPONENT) {
-		log_print("pvscan[%d] PV %s ignore MD component, ignore metadata.", getpid(), dev_name(dev));
-		if (baton.vg)
-			release_vg(baton.vg);
-		else
-			fmt->ops->destroy_instance(baton.fid);
-		return 1;
-	}
+		if (!(fp = fopen(path, "r"))) {
+			log_warn("Failed to open %s", path);
+			continue;
+		}
 
-	if (baton.vg && vg_is_shared(baton.vg)) {
-		log_print("pvscan[%d] PV %s ignore shared VG.", getpid(), dev_name(dev));
-		release_vg(baton.vg);
-		return 1;
-	}
+		if (_lookup_file_contains_pvid(fp, dev->pvid)) {
+			vgname = dm_pool_strdup(cmd->mem, de->d_name);
+			break;
+		}
 
-	if (baton.vg &&
-	    baton.vg->system_id && baton.vg->system_id[0] &&
-	    cmd->system_id && cmd->system_id[0] &&
-	    vg_is_foreign(baton.vg)) {
-		log_verbose("Ignore PV %s with VG system id %s with our system id %s",
-			    dev_name(dev), baton.vg->system_id, cmd->system_id);
-		log_print("pvscan[%d] PV %s ignore foreign VG.", getpid(), dev_name(dev));
-		release_vg(baton.vg);
-		return 1;
+		if (fclose(fp))
+			stack;
 	}
+	if (closedir(dir))
+		log_sys_debug("closedir", _pvs_lookup_dir);
 
-	ret = _online_pv_found(cmd, dev, dev_args, baton.vg, found_vgnames);
+	if (!vgname)
+		goto_bad;
 
 	/*
-	 * Save vg's in case they need to be used at the end for checking PVs
-	 * without metadata (in _check_vg_with_pvid_complete), or activating.
+	 * stat pvid online file of each pvid listed in this file
+	 * the list of pvids from the file is the alternative to
+	 * using vg->pvs
 	 */
-	if (saved_vgs && baton.vg) {
-		if (!_find_saved_vg(saved_vgs, baton.vg->name)) {
-	       		if ((vgl = malloc(sizeof(struct vg_list)))) {
-				vgl->vg = baton.vg;
-				baton.vg = NULL;
-				dm_list_add(saved_vgs, &vgl->list);
-			}
-		}
-	}
+	_lookup_file_count_pvid_files(fp, vgname, &online, &offline);
 
-	if (baton.vg)
-		release_vg(baton.vg);
-out:
-	return ret;
+	if (fclose(fp))
+		stack;
+
+	*pvs_online = online;
+	*pvs_offline = offline;
+	*vgname_out = vgname;
+	return 1;
+bad:
+	return 0;
 }
 
-/*
- * This is to handle the case where pvscan --cache -aay (with no dev args)
- * gets to the final PV, completing the VG, but that final PV does not
- * have VG metadata.  In this case, we need to use VG metadata from a
- * previously scanned PV in the same VG, which we saved in the saved_vgs
- * list.  Using this saved metadata, we can find which VG this PVID
- * belongs to, and then check if that VG is now complete, and if so
- * add the VG name to the list of complete VGs to be autoactivated.
- *
- * The "pvid" arg here is the PVID of the PV that has just been scanned
- * and didn't have metadata.  We look through previously scanned VG
- * metadata to find the VG this PVID belongs to, and then check that VG
- * metadata to see if all the PVs are now online.
- */
-static void _check_vg_with_pvid_complete(struct cmd_context *cmd,
-				         struct dm_list *found_vgnames,
-					 struct dm_list *saved_vgs,
-					 const char *pvid)
+static void _online_dir_setup(void)
 {
-	struct vg_list *vgl;
-	struct pv_list *pvl;
-	struct volume_group *vg;
-	int pvids_not_online = 0;
-	int found;
+	struct stat st;
+	int rv;
 
-	dm_list_iterate_items(vgl, saved_vgs) {
-		vg = vgl->vg;
-		found = 0;
+	if (!stat(DEFAULT_RUN_DIR, &st))
+		goto do_pvs;
 
-		dm_list_iterate_items(pvl, &vg->pvs) {
-			if (strcmp((const char *)&pvl->pv->id.uuid, pvid))
-				continue;
-			found = 1;
-			break;
-		}
-		if (!found)
-			continue;
+	log_debug("Creating run_dir.");
+	dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
+	rv = mkdir(DEFAULT_RUN_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
 
-		dm_list_iterate_items(pvl, &vg->pvs) {
-			if (!_online_pvid_file_exists((const char *)&pvl->pv->id.uuid)) {
-				pvids_not_online++;
-				break;
-			}
-		}
+	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
+		log_error("Failed to create %s %d", DEFAULT_RUN_DIR, errno);
 
-		if (!pvids_not_online) {
-			log_debug("pvid %s makes complete VG %s", pvid, vg->name);
-			if (!str_list_add(cmd->mem, found_vgnames, dm_pool_strdup(cmd->mem, vg->name)))
-				stack;
-		} else
-			log_debug("pvid %s incomplete VG %s", pvid, vg->name);
-		break;
-	}
-}
+do_pvs:
+	if (!stat(_pvs_online_dir, &st))
+		goto do_vgs;
 
-/*
- * dev_args is the list of devices that were specified on the
- * pvscan command line.
- *
- * . When dev_args is NULL, any complete VGs that are found will
- *   be returned in found_vgnames.
- *
- * . When dev_args is set, then complete VGs that that contain
- *   devs in dev_args will be returned in found_vgnames.
- *
- * found_vgnames is null for 'pvscan --cache' (without -aay)
- * since the command does not need to keep track of complete
- * vgs since it does not need to activate them.
- */
+	log_debug("Creating pvs_online_dir.");
+	dm_prepare_selinux_context(_pvs_online_dir, S_IFDIR);
+	rv = mkdir(_pvs_online_dir, 0755);
+	dm_prepare_selinux_context(NULL, 0);
 
-static void _online_pvscan_all_devs(struct cmd_context *cmd,
-				    struct dm_list *found_vgnames,
-				    struct dm_list *saved_vgs,
-				    struct dm_list *dev_args)
-{
-	struct dev_iter *iter;
-	struct device *dev;
-	const char *pvid_without_metadata;
+	if ((rv < 0) && stat(_pvs_online_dir, &st))
+		log_error("Failed to create %s %d", _pvs_online_dir, errno);
 
-	lvmcache_label_scan(cmd);
+do_vgs:
+	if (!stat(_vgs_online_dir, &st))
+		goto do_lookup;
+
+	log_debug("Creating vgs_online_dir.");
+	dm_prepare_selinux_context(_vgs_online_dir, S_IFDIR);
+	rv = mkdir(_vgs_online_dir, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(_vgs_online_dir, &st))
+		log_error("Failed to create %s %d", _vgs_online_dir, errno);
 
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
+do_lookup:
+	if (!stat(_pvs_lookup_dir, &st))
 		return;
-	}
 
-	while ((dev = dev_iter_get(cmd, iter))) {
-		if (sigint_caught()) {
-			stack;
-			break;
-		}
+	log_debug("Creating pvs_lookup_dir.");
+	dm_prepare_selinux_context(_pvs_lookup_dir, S_IFDIR);
+	rv = mkdir(_pvs_lookup_dir, 0755);
+	dm_prepare_selinux_context(NULL, 0);
 
-		pvid_without_metadata = NULL;
+	if ((rv < 0) && stat(_pvs_lookup_dir, &st))
+		log_error("Failed to create %s %d", _pvs_lookup_dir, errno);
 
-		if (!_online_pvscan_one(cmd, dev, dev_args, found_vgnames, saved_vgs, 1, &pvid_without_metadata)) {
-			stack;
-			break;
-		}
 
-		/* This PV without metadata may complete a VG. */
-		if (pvid_without_metadata && found_vgnames)
-			_check_vg_with_pvid_complete(cmd, found_vgnames, saved_vgs, pvid_without_metadata);
-	}
+}
 
-	dev_iter_destroy(iter);
+static void _count_pvid_files(struct volume_group *vg, int *pvs_online, int *pvs_offline)
+{
+	struct pv_list *pvl;
+
+	*pvs_online = 0;
+	*pvs_offline = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (_online_pvid_file_exists((const char *)&pvl->pv->id.uuid))
+			(*pvs_online)++;
+		else
+			(*pvs_offline)++;
+	}
 }
 
 static int _pvscan_aa_single(struct cmd_context *cmd, const char *vg_name,
@@ -929,7 +798,6 @@ static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
  */
 
 static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
-				   struct dm_list *saved_vgs,
 				   struct dm_list *devs)
 {
 	char path[PATH_MAX];
@@ -951,8 +819,8 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 	 * reading all the pvid online files, see which have a matching vg
 	 * name, and getting the device numbers from those files.)
 	 */
-	if (!(vg = _find_saved_vg(saved_vgs, vgname)))
-		return_0;
+	if (!(vg = saved_vg))
+		goto_bad;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pvid = (const char *)&pvl->pv->id.uuid;
@@ -969,14 +837,14 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		if (file_vgname[0] && strcmp(vgname, file_vgname)) {
 			log_error("Wrong VG found for %d:%d PVID %s: %s vs %s",
 				  file_major, file_minor, pvid, vgname, file_vgname);
-			return 0;
+			goto bad;
 		}
 
 		devno = MKDEV(file_major, file_minor);
 
 		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
 			log_error("No device found for %d:%d PVID %s", file_major, file_minor, pvid);
-			return 0;
+			goto bad;
 		}
 
 		name1 = dev_name(dev);
@@ -986,11 +854,11 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 			if (!id_write_format((const struct id *)pvid, uuidstr, sizeof(uuidstr)))
 				uuidstr[0] = '\0';
 			log_print("PVID %s read from %s last written to %s.", uuidstr, name1, name2);
-			return 0;
+			goto bad;
 		}
 
 		if (!(devl = zalloc(sizeof(*devl))))
-			return_0;
+			goto_bad;
 
 		devl->dev = dev;
 		dm_list_add(devs, &devl->list);
@@ -998,6 +866,13 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 	}
 
 	return 1;
+
+bad:
+	if (saved_vg) {
+		release_vg(saved_vg);
+		saved_vg = NULL;
+	}
+	return 0;
 }
 
 /*
@@ -1036,7 +911,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
  */
 
 static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp, const char *vgname,
-			    struct dm_list *saved_vgs, int *no_quick)
+			    int *no_quick)
 {
 	struct dm_list devs; /* device_list */
 	struct volume_group *vg;
@@ -1054,7 +929,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	 * The pvs_online/PVID files gives us the devnums for PVIDs.
 	 * The dev_cache gives us struct devices from the devnums.
 	 */
-	if (!_get_devs_from_saved_vg(cmd, vgname, saved_vgs, &devs)) {
+	if (!_get_devs_from_saved_vg(cmd, vgname, &devs)) {
 		log_print("pvscan[%d] VG %s not using quick activation.", getpid(), vgname);
 		*no_quick = 1;
 		return ECMD_FAILED;
@@ -1140,21 +1015,17 @@ out:
 }
 
 static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
-		      struct dm_list *vgnames, struct dm_list *saved_vgs)
+		      int do_all, struct dm_list *vgnames)
 {
 	struct processing_handle *handle = NULL;
 	struct dm_str_list *sl, *sl2;
 	int no_quick = 0;
 	int ret;
 
-	if (dm_list_empty(vgnames)) {
-		log_debug("No VGs to autoactivate.");
-		return ECMD_PROCESSED;
-	}
-
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
-		return ECMD_FAILED;
+		ret = ECMD_FAILED;
+		goto out;
 	}
 
 	handle->custom_handle = pp;
@@ -1177,282 +1048,509 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 
 	if (dm_list_empty(vgnames)) {
 		destroy_processing_handle(cmd, handle);
-		return ECMD_PROCESSED;
+		ret = ECMD_PROCESSED;
+		goto out;
 	}
 
-	if (dm_list_size(vgnames) == 1) {
-		dm_list_iterate_items(sl, vgnames)
-			ret = _pvscan_aa_quick(cmd, pp, sl->str, saved_vgs, &no_quick);
+	/*
+	 * When saved_vg is set there should only be one vgname.
+	 * If the optimized "quick" function finds something amiss
+	 * it will set no_quick and return so that the slow version
+	 * can be used.
+	 */
+	if (!do_all && saved_vg && (dm_list_size(vgnames) == 1)) {
+		log_debug("autoactivate quick");
+		ret = _pvscan_aa_quick(cmd, pp, saved_vg->name, &no_quick);
 	}
 
-	if ((dm_list_size(vgnames) > 1) || no_quick)
-		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_ACTIVATE, 0, handle, _pvscan_aa_single);
+	/*
+	 * do_all indicates 'pvscan --cache' in which case
+	 * pvscan_cache_all() has already done lvmcache_label_scan
+	 * which does not need to be repeated by process_each_vg.
+	 */
+	if (!saved_vg || (dm_list_size(vgnames) > 1) || no_quick) {
+		uint32_t read_flags = READ_FOR_ACTIVATE;
+		if (do_all)
+			read_flags |= PROCESS_SKIP_SCAN;
+		log_debug("autoactivate slow");
+		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, read_flags, 0, handle, _pvscan_aa_single);
+	}
 
 	destroy_processing_handle(cmd, handle);
-
+out:
+	if (saved_vg) {
+		release_vg(saved_vg);
+		saved_vg = NULL;
+	}
 	return ret;
 }
 
-int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
-{
-	struct pvscan_aa_params pp = { 0 };
-	struct dm_list add_devs;
-	struct dm_list rem_devs;
-	struct dm_list vgnames;
-	struct dm_list vglist;
-	struct dm_list *complete_vgnames = NULL;
-	struct dm_list *saved_vgs = NULL;
+struct pvscan_arg {
+	struct dm_list list;
+	const char *devname;
+	dev_t devno;
 	struct device *dev;
-	struct device_list *devl;
-	struct vg_list *vgl;
-	const char *pv_name;
-	const char *pvid_without_metadata = NULL;
-	int32_t major = -1;
-	int32_t minor = -1;
-	int devno_args = 0;
-	int all_devs;
+};
+
+static int _get_args(struct cmd_context *cmd, int argc, char **argv,
+		     struct dm_list *pvscan_args)
+{
 	struct arg_value_group_list *current_group;
-	dev_t devno;
-	int filtered;
-	int do_activate = arg_is_set(cmd, activate_ARG);
-	int add_errors = 0;
-	int add_single_count = 0;
-	int ret = ECMD_PROCESSED;
+	struct pvscan_arg *arg;
+	const char *arg_name;
+	int major, minor;
 
-	dm_list_init(&add_devs);
-	dm_list_init(&rem_devs);
-	dm_list_init(&vgnames);
-	dm_list_init(&vglist);
+	/* Process position args, which can be /dev/name or major:minor */
 
-	/*
-	 * When systemd/udev run pvscan --cache commands, those commands
-	 * should not wait on udev info since the udev info may not be
-	 * complete until the pvscan --cache command is done.
-	 */
-	init_udev_sleeping(0);
+	while (argc) {
+		argc--;
+		arg_name = *argv++;
 
-	if (do_activate) {
-		complete_vgnames = &vgnames;
-		saved_vgs = &vglist;
-	}
+		if (arg_name[0] == '/') {
+			if (!(arg = dm_pool_zalloc(cmd->mem, sizeof(*arg))))
+				return_0;
+			arg->devname = arg_name;
+			dm_list_add(pvscan_args, &arg->list);
+			continue;
+		}
 
-	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
-		devno_args = 1;
+		if (sscanf(arg_name, "%d:%d", &major, &minor) != 2) {
+			log_warn("WARNING: Failed to parse major:minor from %s, skipping.", arg_name);
+			continue;
+		}
 
-	if (devno_args && (!arg_is_set(cmd, major_ARG) || !arg_is_set(cmd, minor_ARG))) {
-		log_error("Both --major and --minor required to identify devices.");
-		return EINVALID_CMD_LINE;
+		if (!(arg = dm_pool_zalloc(cmd->mem, sizeof(*arg))))
+			return_0;
+		arg->devno = MKDEV(major, minor);
+		dm_list_add(pvscan_args, &arg->list);
 	}
 
-	if (argc || devno_args) {
-		log_verbose("pvscan devices on command line.");
-		cmd->pvscan_cache_single = 1;
-		all_devs = 0;
-	} else {
-		all_devs = 1;
+	/* Process any grouped --major --minor args */
+
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		major = grouped_arg_int_value(current_group->arg_values, major_ARG, major);
+		minor = grouped_arg_int_value(current_group->arg_values, minor_ARG, minor);
+
+		if (major < 0 || minor < 0)
+			continue;
+
+		if (!(arg = dm_pool_zalloc(cmd->mem, sizeof(*arg))))
+			return_0;
+		arg->devno = MKDEV(major, minor);
+		dm_list_add(pvscan_args, &arg->list);
 	}
 
-	_online_dir_setup();
+	return 1;
+}
 
-	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
-	dev_cache_scan();
+static int _get_args_devs(struct cmd_context *cmd, struct dm_list *pvscan_args,
+			  struct dm_list *pvscan_devs)
+{
+	struct pvscan_arg *arg;
+	struct device_list *devl;
 
-	if (cmd->md_component_detection && !cmd->use_full_md_check &&
-	    !strcmp(cmd->md_component_checks, "auto") &&
-	    dev_cache_has_md_with_end_superblock(cmd->dev_types)) {
-		log_debug("Enable full md component check.");
-		cmd->use_full_md_check = 1;
+	/* pass NULL filter when getting devs from dev-cache, filtering is done separately */
+
+	/* in common usage, no dev will be found for a devno */
+
+	dm_list_iterate_items(arg, pvscan_args) {
+		if (arg->devname)
+			arg->dev = dev_cache_get(cmd, arg->devname, NULL);
+		else if (arg->devno)
+			arg->dev = dev_cache_get_by_devt(cmd, arg->devno, NULL, NULL);
+		else
+			return_0;
 	}
 
-	/*
-	 * For each device command arg (from either position or --major/--minor),
-	 * decide if that device is being added to the system (a dev node exists
-	 * for it in /dev), or being removed from the system (no dev node exists
-	 * for it in /dev).  Create entries in add_devs/rem_devs for each arg
-	 * accordingly.
-	 */
+	dm_list_iterate_items(arg, pvscan_args) {
+		if (!arg->dev)
+			continue;
 
-	while (argc) {
-		argc--;
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			return_0;
+		devl->dev = arg->dev;
+		dm_list_add(pvscan_devs, &devl->list);
+	}
 
-		pv_name = *argv++;
-		if (pv_name[0] == '/') {
-			if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
-				log_debug("pvscan arg %s not found.", pv_name);
-				if ((dev = dev_cache_get(cmd, pv_name, NULL))) {
-					/* nothing to do for this dev name */
-					log_print("pvscan[%d] device %s excluded by filter.", getpid(), dev_name(dev));
-				} else {
-					log_error("Physical Volume %s not found.", pv_name);
-					ret = ECMD_FAILED;
-				}
-			} else {
-				/*
-				 * Scan device.  This dev could still be removed
-				 * below if it doesn't pass other filters.
-				 */
-				log_debug("pvscan arg %s found.", pv_name);
-
-				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-					return_0;
-				devl->dev = dev;
-				dm_list_add(&add_devs, &devl->list);
-			}
-		} else {
-			if (sscanf(pv_name, "%d:%d", &major, &minor) != 2) {
-				log_warn("WARNING: Failed to parse major:minor from %s, skipping.", pv_name);
-				continue;
-			}
-			devno = MKDEV(major, minor);
-
-			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter, &filtered))) {
-				if (filtered) {
-					if ((dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL)))
-						log_print("pvscan[%d] device %d:%d %s excluded by filter.", getpid(), major, minor, dev_name(dev));
-					else
-						log_print("pvscan[%d] device %d:%d excluded by filter.", getpid(), major, minor);
-				} else
-					log_print("pvscan[%d] device %d:%d not found.", getpid(), major, minor);
-
-				if (!(dev = dm_pool_zalloc(cmd->mem, sizeof(struct device))))
-					return_0;
-				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-					return_0;
-				dev->dev = devno;
-				devl->dev = dev;
-				dm_list_add(&rem_devs, &devl->list);
-			} else {
-				/*
-				 * Scan device.  This dev could still be removed
-				 * below if it doesn't pass other filters.
-				 */
-				log_debug("pvscan arg %d:%d found.", major, minor);
-
-				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-					return_0;
-				devl->dev = dev;
-				dm_list_add(&add_devs, &devl->list);
-			}
+	return 1;
+}
+
+static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvscan_devs,
+			int *pv_count, struct dm_list *complete_vgnames)
+{
+	struct device_list *devl, *devl2;
+	struct device *dev;
+	struct lvmcache_info *info;
+	const struct format_type *fmt;
+	struct format_instance_ctx fic = { .type = 0 };
+	struct format_instance *fid;
+	struct metadata_area *mda1, *mda2;
+	struct volume_group *vg;
+	const char *vgname;
+	uint32_t ext_version, ext_flags;
+	int do_activate = arg_is_set(cmd, activate_ARG);
+	int pvs_online;
+	int pvs_offline;
+	int pvs_unknown;
+	int vg_complete;
+	int ret = 1;
+
+	dm_list_iterate_items_safe(devl, devl2, pvscan_devs) {
+		dev = devl->dev;
+
+		log_debug("online_devs %s %s", dev_name(dev), dev->pvid);
+
+		/*
+		 * This should already have been done by the filter, but make
+		 * another check directly with udev in case the filter was not
+		 * using udev and the native version didn't catch it.
+		 */
+		if (udev_dev_is_mpath_component(dev)) {
+			log_print("pvscan[%d] ignore multipath component %s.", getpid(), dev_name(dev));
+			continue;
 		}
-	}
 
-	/* Process any grouped --major --minor args */
-	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
-		major = grouped_arg_int_value(current_group->arg_values, major_ARG, major);
-		minor = grouped_arg_int_value(current_group->arg_values, minor_ARG, minor);
+		if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
+			if (!do_all)
+				log_print("pvscan[%d] ignore %s with no lvm info.", getpid(), dev_name(dev));
+			continue;
+		}
 
-		if (major < 0 || minor < 0)
+		ext_version = lvmcache_ext_version(info);
+		ext_flags = lvmcache_ext_flags(info);
+		if ((ext_version >= 2) && !(ext_flags & PV_EXT_USED)) {
+			log_print("pvscan[%d] PV %s not used.", getpid(), dev_name(dev));
+			(*pv_count)++;
 			continue;
+		}
 
-		devno = MKDEV(major, minor);
+		fmt = lvmcache_fmt(info);
+		fid = fmt->ops->create_instance(fmt, &fic);
+		vg = NULL;
 
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter, &filtered))) {
-			if (filtered) {
-				if ((dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL)))
-					log_print("pvscan[%d] device %d:%d %s excluded by filter.", getpid(), major, minor, dev_name(dev));
-				else
-					log_print("pvscan[%d] device %d:%d excluded by filter.", getpid(), major, minor);
-			} else
-				log_print("pvscan[%d] device %d:%d not found.", getpid(), major, minor);
+		mda1 = lvmcache_get_dev_mda(dev, 1);
+		mda2 = lvmcache_get_dev_mda(dev, 2);
 
-			if (!(dev = dm_pool_zalloc(cmd->mem, sizeof(struct device))))
-				return_0;
-			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-				return_0;
-			dev->dev = devno;
-			devl->dev = dev;
-			dm_list_add(&rem_devs, &devl->list);
+		if (mda1 && !mda_is_ignored(mda1))
+			vg = mda1->ops->vg_read(cmd, fid, "", mda1, NULL, NULL);
+
+		if (!vg && mda2 && !mda_is_ignored(mda2))
+			vg = mda2->ops->vg_read(cmd, fid, "", mda2, NULL, NULL);
+
+		if (!vg) {
+			log_print("pvscan[%d] PV %s has no VG metadata.", getpid(), dev_name(dev));
+			fmt->ops->destroy_instance(fid);
+			goto online;
+		}
+
+		set_pv_devices(fid, vg, NULL);
+
+		/*
+		 * Skip devs that are md components (set_pv_devices can do new
+		 * md check), are shared, or foreign.
+		 */
+
+        	if (dev->flags & DEV_IS_MD_COMPONENT) {
+			log_print("pvscan[%d] PV %s ignore MD component, ignore metadata.", getpid(), dev_name(dev));
+			release_vg(vg);
+			continue;
+		}
+
+		if (vg_is_shared(vg)) {
+			log_print("pvscan[%d] PV %s ignore shared VG.", getpid(), dev_name(dev));
+			release_vg(vg);
+			continue;
+		}
+
+		if (vg->system_id && vg->system_id[0] &&
+		    cmd->system_id && cmd->system_id[0] &&
+		    vg_is_foreign(vg)) {
+			log_verbose("Ignore PV %s with VG system id %s with our system id %s",
+				    dev_name(dev), vg->system_id, cmd->system_id);
+			log_print("pvscan[%d] PV %s ignore foreign VG.", getpid(), dev_name(dev));
+			release_vg(vg);
+			continue;
+		}
+
+		/*
+		 * online file phase
+		 * create pvs_online/<pvid>
+		 * check if vg is complete: stat pvs_online/<pvid> for each vg->pvs
+		 * if vg is complete, save vg name in list for activation phase
+		 * if vg not complete, create pvs_lookup/<vgname> listing all pvids from vg->pvs
+		 * (only if pvs_lookup/<vgname> does not yet exist)
+		 * if no vg metadata, read pvs_lookup files for pvid, use that list to check if complete
+		 */
+ online:
+		(*pv_count)++;
+
+		/*
+		 * Create file named for pvid to record this PV is online.
+		 */
+		if (!_online_pvid_file_create(dev, vg ? vg->name : NULL)) {
+			log_error("pvscan[%d] PV %s failed to create online file.", getpid(), dev_name(dev));
+			release_vg(vg);
+			ret = 0;
+			continue;
+		}
+
+		/*
+		 * When not activating we don't need to know about vg completeness.
+		 */
+		if (!do_activate) {
+			log_print("pvscan[%d] PV %s online.", getpid(), dev_name(dev));
+			release_vg(vg);
+			continue;
+		}
+
+		/*
+		 * Check if all the PVs for this VG are online.  If the arrival
+		 * of this dev completes the VG, then save the vgname in
+		 * complete_vgnames so it will be activated.
+		 */
+		pvs_online = 0;
+		pvs_offline = 0;
+		pvs_unknown = 0;
+		vg_complete = 0;
+
+		if (vg) {
+			/*
+			 * Use the VG metadata from this PV for a list of all
+			 * PVIDs.  Write a lookup file of PVIDs in case another
+			 * pvscan needs it.  After writing lookup file, recheck
+			 * pvid files to resolve a possible race with another
+			 * pvscan reading the lookup file that missed it.
+			 */
+			log_debug("checking all pvid files from vg %s", vg->name);
+			_count_pvid_files(vg, &pvs_online, &pvs_offline);
+
+			if (pvs_offline && _write_lookup_file(cmd, vg)) {
+				log_debug("rechecking all pvid files from vg %s", vg->name);
+				_count_pvid_files(vg, &pvs_online, &pvs_offline);
+				if (!pvs_offline)
+					log_print("pvscan[%d] VG %s complete after recheck.", getpid(), vg->name);
+			}
+
+			vgname = vg->name;
 		} else {
-			log_debug("pvscan arg %d:%d found.", major, minor);
+			/*
+			 * No VG metadata on this PV, so try to use a lookup
+			 * file written by a prior pvscan for a list of all
+			 * PVIDs.  A lookup file may not exist for this PV if
+			 * it's the first to appear from the VG.
+			 */
+			log_debug("checking all pvid files from lookup file");
+			if (!_count_pvid_files_from_lookup_file(cmd, dev, &pvs_online, &pvs_offline, &vgname))
+				pvs_unknown = 1;
+		}
 
-			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-				return_0;
-			devl->dev = dev;
-			dm_list_add(&add_devs, &devl->list);
+		if (pvs_unknown) {
+			log_print("pvscan[%d] PV %s online, VG unknown.", getpid(), dev_name(dev));
+			vg_complete = 0;
+
+		} else if (pvs_offline) {
+			log_print("pvscan[%d] PV %s online, VG %s incomplete (need %d).",
+				  getpid(), dev_name(dev), vgname, pvs_offline);
+			vg_complete = 0;
+
+		} else {
+			log_print("pvscan[%d] PV %s online, VG %s is complete.", getpid(), dev_name(dev), vgname);
+			if (!str_list_add(cmd->mem, complete_vgnames, dm_pool_strdup(cmd->mem, vgname)))
+				stack;
+			vg_complete = 1;
 		}
+
+		if (!saved_vg && vg && vg_complete && !do_all && (dm_list_size(pvscan_devs) == 1))
+			saved_vg = vg;
+		else
+			release_vg(vg);
 	}
 
+	return ret;
+}
+
+static int _pvscan_cache_all(struct cmd_context *cmd, int argc, char **argv,
+			     struct dm_list *complete_vgnames)
+{
+	struct dm_list pvscan_devs;
+	struct dev_iter *iter;
+	struct device_list *devl;
+	struct device *dev;
+	int pv_count = 0;
+
+	dm_list_init(&pvscan_devs);
+
+	_online_files_remove(_pvs_online_dir);
+	_online_files_remove(_vgs_online_dir);
+	_online_files_remove(_pvs_lookup_dir);
+
 	/*
-	 * No device args means rescan/regenerate/[reactivate] everything.
-	 * Scan all devices when no args are given; clear all pvid
-	 * files on recreate pvid files for existing devices.
-	 * When -aay is set, any complete vg is activated
-	 * (even if it's already active.)
+	 * pvscan --cache removes existing hints and recreates new ones.
+	 * We begin by clearing hints at the start of the command.
+	 * The pvscan_recreate_hints flag is used to enable the
+	 * special case hint recreation in label_scan.
 	 */
+	cmd->pvscan_recreate_hints = 1;
+	pvscan_recreate_hints_begin(cmd);
 
-	if (all_devs) {
-		/*
-		 * pvscan --cache removes existing hints and recreates new ones.
-		 * We begin by clearing hints at the start of the command.
-		 * The pvscan_recreate_hints flag is used to enable the
-		 * special case hint recreation in label_scan.
-		 */
-		cmd->pvscan_recreate_hints = 1;
-		pvscan_recreate_hints_begin(cmd);
+	log_debug("pvscan_cache_all: label scan all");
 
-		log_verbose("pvscan all devices for requested refresh.");
-		_online_files_remove(_pvs_online_dir);
-		_online_files_remove(_vgs_online_dir);
-		_online_pvscan_all_devs(cmd, complete_vgnames, saved_vgs, NULL);
+	/*
+	 * use lvmcache_label_scan() instead of just label_scan_devs()
+	 * because label_scan() has the ability to update hints,
+	 * which we want 'pvscan --cache' to do, and that uses
+	 * info from lvmcache, e.g. duplicate pv info.
+	 */
+	lvmcache_label_scan(cmd);
+
+	cmd->pvscan_recreate_hints = 0;
+	cmd->use_hints = 0;
+
+	log_debug("pvscan_cache_all: create list of devices");
+
+	/*
+	 * The use of filter here will just reuse the existing
+	 * (persistent) filter info label_scan has already set up.
+	 */
+	if (!(iter = dev_iter_create(cmd->filter, 1)))
+		return_0;
 
-		cmd->pvscan_recreate_hints = 0;
-		cmd->use_hints = 0;
-		goto activate;
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl)))) {
+			dev_iter_destroy(iter);
+			return_0;
+		}
+		devl->dev = dev;
+		dm_list_add(&pvscan_devs, &devl->list);
 	}
+	dev_iter_destroy(iter);
 
-	log_verbose("pvscan only specific devices add %d rem %d.",
-		    dm_list_size(&add_devs), dm_list_size(&rem_devs));
+	_online_devs(cmd, 1, &pvscan_devs, &pv_count, complete_vgnames);
+
+	return 1;
+}
+
+static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
+			      struct dm_list *complete_vgnames)
+{
+	struct dm_list pvscan_args; /* struct pvscan_arg */
+	struct dm_list pvscan_devs; /* struct device_list */
+	struct pvscan_arg *arg;
+	struct device_list *devl, *devl2;
+	int pv_count = 0;
+	int ret;
+
+	dm_list_init(&pvscan_args);
+	dm_list_init(&pvscan_devs);
+
+	cmd->pvscan_cache_single = 1;
+
+	dev_cache_scan();
 
 	/*
-	 * Unlink online files for devices that no longer have a device node.
-	 * When unlinking a pvid file for dev, we don't need to scan the dev
-	 * (we can't since it's gone), but we know which pvid file it is
-	 * because the major:minor are saved in the pvid files which we can
-	 * read to find the correct one.
+	 * Get list of args.  Do not use filters.
 	 */
-	dm_list_iterate_items(devl, &rem_devs)
-		_online_pvid_file_remove_devno((int)MAJOR(devl->dev->dev), (int)MINOR(devl->dev->dev));
+	if (!_get_args(cmd, argc, argv, &pvscan_args))
+		return_0;
 
 	/*
-	 * Create online files for devices that exist and pass the filter.
-	 * When creating a pvid file for a dev, we have to scan it first
-	 * to know that it's ours and what its pvid is (and which vg it
-	 * belongs to if we want to do autoactivation.)
+	 * Get list of devs for args.  Do not use filters.
 	 */
-	if (!dm_list_empty(&add_devs)) {
-		label_scan_devs(cmd, cmd->filter, &add_devs);
+	if (!_get_args_devs(cmd, &pvscan_args, &pvscan_devs))
+		return_0;
 
-		dm_list_iterate_items(devl, &add_devs) {
-			dev = devl->dev;
+	/*
+	 * Remove pvid online files for major/minor args for which the dev has
+	 * been removed.
+	 */
+	dm_list_iterate_items(arg, &pvscan_args) {
+		if (arg->dev || !arg->devno)
+			continue;
+		_online_pvid_file_remove_devno((int)MAJOR(arg->devno), (int)MINOR(arg->devno));
+	}
 
-			if (dev->flags & DEV_FILTER_OUT_SCAN) {
-				log_print("pvscan[%d] device %s excluded by filter.", getpid(), dev_name(dev));
-				continue;
-			}
+	/*
+	 * A common pvscan removal of a single dev is done here.
+	 */
+	if (dm_list_empty(&pvscan_devs))
+		return 1;
+
+	if (cmd->md_component_detection && !cmd->use_full_md_check &&
+	    !strcmp(cmd->md_component_checks, "auto") &&
+	    dev_cache_has_md_with_end_superblock(cmd->dev_types)) {
+		log_debug("Enable full md component check.");
+		cmd->use_full_md_check = 1;
+	}
 
-			add_single_count++;
+	/*
+	 * Apply nodata filters.
+	 * bcache is not yet set up so no filters will do io.
+	 */
+
+	log_debug("pvscan_cache_args: filter devs nodata");
+
+	cmd->filter_nodata_only = 1;
 
-			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, saved_vgs, 0, &pvid_without_metadata))
-				add_errors++;
+	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
+			log_print("pvscan[%d] %s excluded by filters: %s.", getpid(),
+				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			dm_list_del(&devl->list);
 		}
 	}
 
+	cmd->filter_nodata_only = 0;
+
+	/*
+	 * Clear the results of nodata filters that were saved by the
+	 * persistent filter so that the complete set of filters will
+	 * be checked by passes_filter below.
+	 */
+	dm_list_iterate_items(devl, &pvscan_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+
 	/*
-	 * After scanning only specific devs to add a device, there is a
-	 * special case that requires us to then scan all devs.  That is when
-	 * the dev scanned has no VG metadata, and it's the final device to
-	 * complete the VG.  In this case we want to autoactivate the VG, but
-	 * the scanned device does not know what VG it's in or whether that VG
-	 * is now complete.  In this case we need to scan all devs and pick out
-	 * the complete VG holding this device so we can then autoactivate that
-	 * VG.
+	 * Read header from each dev.
+	 * Eliminate non-lvm devs.
+	 * Apply all filters.
 	 */
-	if (!dm_list_empty(&add_devs) && complete_vgnames && dm_list_empty(complete_vgnames) &&
-	    pvid_without_metadata && do_activate) {
-		log_print("pvscan[%d] scan all devices for PV without metadata: %s.", getpid(), pvid_without_metadata);
-		_online_pvscan_all_devs(cmd, complete_vgnames, saved_vgs, &add_devs);
+
+	log_debug("pvscan_cache_args: read and filter devs");
+
+	label_scan_setup_bcache();
+
+	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
+		if (!label_read_pvid(devl->dev)) {
+			/* Not an lvm device */
+			log_print("pvscan[%d] %s not an lvm device.", getpid(), dev_name(devl->dev));
+			dm_list_del(&devl->list);
+			continue;
+		}
+
+		/* Applies all filters, including those that need data from dev. */
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
+			log_print("pvscan[%d] %s excluded by filters: %s.", getpid(),
+				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			dm_list_del(&devl->list);
+		}
 	}
 
+	if (dm_list_empty(&pvscan_devs))
+		return 1;
+
+	log_debug("pvscan_cache_args: label scan devs");
+
+	/*
+	 * Scan devs to populate lvmcache info, which includes the mda info that's
+	 * needed to read vg metadata in the next step.  The _cached variant of
+	 * label_scan is used so the exsting bcache data from label_read_pvid above
+	 * can be reused (although more data may need to be read depending on how
+	 * much of the metadata was covered by reading the pvid.)
+	 */
+	label_scan_devs_cached(cmd, NULL, &pvscan_devs);
+
+	ret = _online_devs(cmd, 0, &pvscan_devs, &pv_count, complete_vgnames);
+
 	/*
 	 * When a new PV appears, the system runs pvscan --cache dev.
 	 * This also means that existing hints are invalid, and
@@ -1460,25 +1558,61 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * cases where this detects a change that the other methods
 	 * of detecting invalid hints doesn't catch.
 	 */
-	if (add_single_count)
+	if (pv_count)
 		invalidate_hints(cmd);
 
-activate:
+	return ret;
+}
+
+int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct pvscan_aa_params pp = { 0 };
+	struct dm_list complete_vgnames;
+	int do_activate = arg_is_set(cmd, activate_ARG);
+	int devno_args = 0;
+	int do_all;
+	int ret;
+
+	dm_list_init(&complete_vgnames);
+
+	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
+		devno_args = 1;
+
+	if (devno_args && (!arg_is_set(cmd, major_ARG) || !arg_is_set(cmd, minor_ARG))) {
+		log_error("Both --major and --minor required to identify devices.");
+		return EINVALID_CMD_LINE;
+	}
+
+	do_all = !argc && !devno_args;
+
+	_online_dir_setup();
+
+	if (do_all) {
+		if (!_pvscan_cache_all(cmd, argc, argv, &complete_vgnames))
+			return ECMD_FAILED;
+	} else {
+		if (!_pvscan_cache_args(cmd, argc, argv, &complete_vgnames))
+			return ECMD_FAILED;
+	}
+
+	if (!do_activate)
+		return ECMD_PROCESSED;
+
+	if (dm_list_empty(&complete_vgnames)) {
+		log_debug("No VGs to autoactivate.");
+		return ECMD_PROCESSED;
+	}
 
 	/*
-	 * Step 2: when the PV was recorded online, we check if all the
-	 * PVs for the VG are online.  If so, the vgname was added to the
-	 * list, and we can attempt to autoactivate LVs in the VG.
+	 * When the PV was recorded online, we check if all the PVs for the VG
+	 * are online.  If so, the vgname was added to the list, and we can
+	 * attempt to autoactivate LVs in the VG.
 	 */
-	if (do_activate)
-		ret = _pvscan_aa(cmd, &pp, complete_vgnames, saved_vgs);
+	ret = _pvscan_aa(cmd, &pp, do_all, &complete_vgnames);
 
-	if (add_errors || pp.activate_errors)
+	if (pp.activate_errors)
 		ret = ECMD_FAILED;
 
-	dm_list_iterate_items(vgl, &vglist)
-		release_vg(vgl->vg);
-
 	if (!sync_local_dev_names(cmd))
 		stack;
 	return ret;


