From: David Teigland <teigland@sourceware.org>
Date: Tue, 3 Sep 2019 11:13:24 -0400
Subject: master - pvscan: avoid full scan for activation
Message-ID: <201909031513.x83FDOLx013959@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25b58310e3d606a85abc9bd50991ccb7ddcbfe25
Commit:        25b58310e3d606a85abc9bd50991ccb7ddcbfe25
Parent:        98d420200e16b450b6b7e33b83bdf36a59196d6d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 26 17:07:18 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 3 10:11:16 2019 -0500

pvscan: avoid full scan for activation

When an online PV completed a VG, the standard
activation functions were used to activate the VG.
These functions use a full scan of all devs.
When many pvscans are run during startup and need
to activate many VGs, scanning all devs from all
the pvscans can take a long time.

Optimize VG activation in pvscan to scan only the
devs in the VG being activated.  This makes use of
the online file info that was used to determine
the VG was complete.

The downside of this approach is that pvscan activation
will not detect duplicate PVs and block activation,
where a normal activation command (which scans all
devices) would.
---
 lib/metadata/metadata-exported.h |    7 +
 lib/metadata/metadata.c          |    3 +-
 test/shell/duplicate-pvs-md1.sh  |  108 +++++++---
 test/shell/metadata-bad-text.sh  |  106 +++++++++
 tools/pvscan.c                   |  452 +++++++++++++++++++++++++++++++-------
 tools/toollib.c                  |    6 -
 6 files changed, 568 insertions(+), 114 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e1767b7..a910aa3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -186,6 +186,7 @@
 #define READ_FOR_UPDATE		0x00100000U /* command tells vg_read it plans to write the vg */
 #define PROCESS_SKIP_SCAN	0x00200000U /* skip lvmcache_label_scan in process_each_pv */
 #define READ_FOR_ACTIVATE	0x00400000U /* command tells vg_read it plans to activate the vg */
+#define READ_WITHOUT_LOCK	0x00800000U /* caller responsible for vg lock */
 
 /* vg_read returns these in error_flags */
 #define FAILED_NOT_ENABLED	0x00000001U
@@ -559,6 +560,12 @@ struct vgnameid_list {
 	const char *vgid;
 };
 
+struct device_id_list {
+	struct dm_list list;
+	struct device *dev;
+	char pvid[ID_LEN + 1];
+};
+
 #define PV_PE_START_CALC ((uint64_t) -1) /* Calculate pe_start value */
 
 /*
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 61906cc..b434967 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4917,7 +4917,8 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	 * of needing to write to them.
 	 */
 
-	if (!lock_vol(cmd, vg_name, (writing || activating) ? LCK_VG_WRITE : LCK_VG_READ, NULL)) {
+	if (!(read_flags & READ_WITHOUT_LOCK) &&
+	    !lock_vol(cmd, vg_name, (writing || activating) ? LCK_VG_WRITE : LCK_VG_READ, NULL)) {
 		log_error("Can't get lock for %s", vg_name);
 		failure |= FAILED_LOCKING;
 		goto_bad;
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index 47b5bac..ccd113f 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -185,20 +185,28 @@ lvs -o active $vg |tee out || true
 grep "active" out
 vgchange -an $vg
 
-# N.B. pvscan --cache on the md component does not detect it's
-# a md component, and marks the PVID online, then does activation,
-# but the activation phase scans all devs, finds duplicates between
-# components and the actual md dev, chooses the md dev, and activates
-# the VG using the md dev.
-# The behavior with auto mode is preferable in which this does nothing,
-# but this is ok.
+# N.B. when the md dev (which is started) has not been scanned by
+# pvscan, then pvscan --cache on the md component does not detect it's
+# an md component, and marks the PVID online, then does activation,
+# but the activation using the component fails because the component
+# device is busy from being used in the md dev, and activation fails.
+# The default behavior in auto mode is preferrable.
 _clear_online_files
-pvscan --cache -aay "$dev1"
+not pvscan --cache -aay "$dev1"
+ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
+ls "$RUNDIR/lvm/vgs_online/$vg"
+lvs -o active $vg |tee out || true
+not grep "active" out
+
+# pvscan activation from mddev first, then try from component which fails
+_clear_online_files
+pvscan --cache -aay "$mddev"
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
 lvs -o active $vg |tee out || true
 grep "active" out
-# FIXME: verify the LV is using the md dev and not the component
+not pvscan --cache -aay "$dev1"
+
 
 vgchange -an $vg
 vgremove -f $vg
@@ -266,6 +274,14 @@ aux cleanup_md_dev
 # md_component_checks: start (not auto)
 # mddev: stopped             (not started)
 #
+# N.B. This test case is just characterizing the current behavior, even
+# though the behavior it's testing for is not what we'd want to happen.
+# In this scenario, we have disabled/avoided everything that would
+# lead lvm to discover that dev1 is an md component, so dev1 is used
+# as the PV.  Multiple default settings need to be changed to get to
+# this unwanted behavior (md_component_checks,
+# obtain_device_list_from_udev), and other conditions also
+# need to be true (md device stopped).
 
 aux lvmconf 'devices/md_component_checks = "start"'
 
@@ -301,26 +317,37 @@ not grep "$dev2" $HINTS
 not lvchange -ay $vg/$lv1
 not lvs $vg
 
-# pvscan activation all does nothing
+# pvscan activation all does nothing because both legs are
+# seen as duplicates which triggers md component check which
+# eliminates the devs
 _clear_online_files
 pvscan --cache -aay
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-# pvscan activation from md components does nothing
 _clear_online_files
-pvscan --cache -aay "$dev1" || true
-# N.B it would be preferrable if this did not recognize the PV on the
-# component and attempt to activate, like auto mode, but this is ok,
-# the activation scans all devs, sees duplicates, which triggers md
-# component detection which eliminates both devs, leaving no vg to activate.
+pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2" || true
-lvs -o active $vg |tee out || true
-not grep "active" out
 
-aux cleanup_md_dev
+# N.B. not good to activate from component, but result of "start" setting
+# Other commands will not see the vg at this point because they'll
+# recognize the md components and ignore them (where pvscan is special due
+# to it not scanning all devs and not seeing the duplicates and not
+# detecting the components.)
+# disable dev2 so other cmds don't see dups and we can deactivate the vg
+aux disable_dev "$dev2"
+vgchange -an $vg
+
+aux enable_dev "$dev2"
+aux udev_wait
+cat /proc/mdstat
+# for some reason enabling dev2 starts an odd md dev
+mdadm --stop "$mddev" || true
+mdadm --stop --scan
+cat /proc/mdstat
+wipefs -a "$dev1" || true
+wipefs -a "$dev2" || true
 
 
 ##########################################
@@ -382,12 +409,18 @@ _clear_online_files
 pvscan --cache -aay
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
+# N.B. not good to activate from component, but result of "start" setting
+lvs -o active $vg |tee out || true
+grep "active" out
 vgchange -an $vg
 
 _clear_online_files
 pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
+# N.B. not good to activate from component, but result of "start" setting
+lvs -o active $vg |tee out || true
+grep "active" out
 vgchange -an $vg
 
 aux enable_dev "$dev2"
@@ -582,21 +615,32 @@ pvscan --cache -aay
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-# pvscan activation from md components does nothing
 _clear_online_files
 pvscan --cache -aay "$dev1" || true
-# N.B it would be preferrable if this did not recognize the PV on the
-# component and attempt to activate, like auto mode, but this is ok,
-# the activation scans all devs, sees duplicates, which triggers md
-# component detection which eliminates both devs, leaving no vg to activate.
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2" || true
-lvs -o active $vg |tee out || true
-not grep "active" out
-pvscan --cache -aay "$dev4" || true
-lvs -o active $vg |tee out || true
-not grep "active" out
+# N.B. not good to activate from component, but result of "start" setting
+# Scanning the other two legs sees existing pv online file and warns about
+# duplicate PVID, exiting with error:
+not pvscan --cache -aay "$dev2"
+not pvscan --cache -aay "$dev4"
+
+# Have to disable other legs so we can deactivate since
+# vgchange will detect and eliminate the components due
+# to duplicates and not see the vg.
+aux disable_dev "$dev2"
+aux disable_dev "$dev4"
+vgchange -an $vg
 
-aux cleanup_md_dev
+aux enable_dev "$dev2"
+aux enable_dev "$dev4"
+aux udev_wait
+cat /proc/mdstat
+# for some reason enabling dev2 starts an odd md dev
+mdadm --stop "$mddev" || true
+mdadm --stop --scan
+cat /proc/mdstat
+wipefs -a "$dev1" || true
+wipefs -a "$dev2" || true
+wipefs -a "$dev4" || true
 
diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 4c59bc9..2937a66 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -10,6 +10,18 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+
+_clear_online_files() {
+        # wait till udev is finished
+        aux udev_wait
+        rm -f "$PVS_ONLINE_DIR"/*
+        rm -f "$VGS_ONLINE_DIR"/*
+}
+
 . lib/inittest
 
 aux prepare_devs 3
@@ -234,3 +246,97 @@ lvs $vg/$lv1
 vgchange -an $vg
 vgremove -ff $vg
 
+#
+# Test pvscan activation with bad PVs
+#
+
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+dd if=/dev/zero of="$dev3" || true
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
+
+PVID1=`pvs $dev1 --noheading -o uuid | tr -d - | awk '{print $1}'`
+echo $PVID1
+PVID2=`pvs $dev2 --noheading -o uuid | tr -d - | awk '{print $1}'`
+echo $PVID2
+PVID3=`pvs $dev3 --noheading -o uuid | tr -d - | awk '{print $1}'`
+echo $PVID3
+
+pvs
+
+dd if="$dev1" of=meta1 bs=4k count=2
+dd if="$dev2" of=meta2 bs=4k count=2
+
+sed 's/READ/RRRR/' meta1 > meta1.bad
+sed 's/seqno =/sss =/' meta2 > meta2.bad
+
+dd if=meta1.bad of="$dev1"
+dd if=meta2.bad of="$dev2"
+
+pvs 2>&1 | tee out
+grep "bad metadata text" out > out2
+grep "$dev1" out2
+grep "$dev2" out2
+
+pvs "$dev1"
+pvs "$dev2"
+pvs "$dev3"
+
+# bad metadata in one mda doesn't prevent using
+# the VG since other mdas are fine
+lvcreate -l1 -n $lv1 $vg
+
+vgchange -an $vg
+
+_clear_online_files
+
+# pvscan of one dev with bad metadata will result
+# in the dev acting like a PV without metadata,
+# which causes pvscan to scan all devs to find the
+# VG it belongs to.  In this case it finds all the
+# other devs in the VG are online and activates the
+# VG.
+pvscan --cache -aay "$dev1"
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+ls "$RUNDIR/lvm/vgs_online/$vg"
+
+lvs $vg
+check lv_field $vg/$lv1 lv_active "active"
+vgchange -an $vg
+
+_clear_online_files
+
+# scan the one pv with good metadata, does not scan any others
+pvscan --cache -aay "$dev3"
+not ls "$RUNDIR/lvm/pvs_online/$PVID1"
+not ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+not ls "$RUNDIR/lvm/vgs_online/$vg"
+
+# scan the next pv with bad metadata, causes pvscan to scan
+# and find all PVs and activate
+pvscan --cache -aay "$dev2"
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+ls "$RUNDIR/lvm/vgs_online/$vg"
+
+check lv_field $vg/$lv1 lv_active "active"
+vgchange -an $vg
+
+
+vgck --updatemetadata $vg
+
+pvs 2>&1 | tee out
+not grep "bad metadata text" out
+
+pvs "$dev1"
+pvs "$dev2"
+pvs "$dev3"
+
+vgchange -an $vg
+vgremove -ff $vg
+
diff --git a/tools/pvscan.c b/tools/pvscan.c
index bfa5a83..b025ae3 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -199,6 +199,43 @@ static char *_vgname_in_pvid_file_buf(char *buf)
 
 #define MAX_PVID_FILE_SIZE 512
 
+static int _online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
+{
+	char buf[MAX_PVID_FILE_SIZE];
+	char *name;
+	int fd, rv;
+
+	fd = open(path, O_RDONLY);
+	if (fd < 0) {
+		log_warn("Failed to open %s", path);
+		return 0;
+	}
+
+	memset(buf, 0, sizeof(buf));
+
+	rv = read(fd, buf, sizeof(buf));
+	if (close(fd))
+		log_sys_debug("close", path);
+	if (!rv || rv < 0) {
+		log_warn("No info in %s", path);
+		return 0;
+	}
+
+	if (sscanf(buf, "%d:%d", major, minor) != 2) {
+		log_warn("No device numbers in %s", path);
+		return 0;
+	}
+
+	/* vgname points to an offset in buf */
+	if ((name = _vgname_in_pvid_file_buf(buf)))
+		strncpy(vgname, name, NAME_LEN);
+	else
+		log_debug("No vgname in %s", path);
+
+	return 1;
+}
+
+
 /*
  * When a PV goes offline, remove the vg online file for that VG
  * (even if other PVs for the VG are still online).  This means
@@ -231,15 +268,10 @@ static void _online_vg_file_remove(const char *vgname)
 static void _online_pvid_file_remove_devno(int major, int minor)
 {
 	char path[PATH_MAX];
-	char buf[MAX_PVID_FILE_SIZE];
-	char buf_in[MAX_PVID_FILE_SIZE];
-	char *vgname = NULL;
+	char file_vgname[NAME_LEN];
 	DIR *dir;
 	struct dirent *de;
-	int fd, rv;
-
-	memset(buf, 0, sizeof(buf));
-	snprintf(buf, sizeof(buf), "%d:%d\n", major, minor);
+	int file_major = 0, file_minor = 0;
 
 	log_debug("Remove pv online devno %d:%d", major, minor);
 
@@ -253,34 +285,19 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		memset(path, 0, sizeof(path));
 		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, de->d_name);
 
-		fd = open(path, O_RDONLY);
-		if (fd < 0) {
-			log_debug("Failed to open %s", path);
-			continue;
-		}
-
-		memset(buf_in, 0, sizeof(buf_in));
+		file_major = 0;
+		file_minor = 0;
+		memset(file_vgname, 0, sizeof(file_vgname));
 
-		rv = read(fd, buf_in, sizeof(buf_in));
-		if (close(fd))
-			log_sys_debug("close", path);
-		if (!rv || rv < 0) {
-			log_debug("Failed to read %s", path);
-			continue;
-		}
+		_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
 
-		if (!strncmp(buf, buf_in, strlen(buf))) {
+		if ((file_major == major) && (file_minor == minor)) {
 			log_debug("Unlink pv online %s", path);
 			if (unlink(path))
 				log_sys_debug("unlink", path);
 
-			/* vgname points to an offset in buf_in */
-			if ((vgname = _vgname_in_pvid_file_buf(buf_in)))
-				_online_vg_file_remove(vgname);
-			else
-				log_debug("No vgname in pvid file");
-
-			break;
+			if (file_vgname[0])
+				_online_vg_file_remove(file_vgname);
 		}
 	}
 	if (closedir(dir))
@@ -313,6 +330,8 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 {
 	char path[PATH_MAX];
 	char buf[MAX_PVID_FILE_SIZE];
+	char file_vgname[NAME_LEN];
+	int file_major = 0, file_minor = 0;
 	int major, minor;
 	int fd;
 	int rv;
@@ -347,8 +366,10 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 
 	log_debug("Create pv online: %s %d:%d %s", path, major, minor, dev_name(dev));
 
-	fd = open(path, O_CREAT | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
+	fd = open(path, O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR);
 	if (fd < 0) {
+		if (errno == EEXIST)
+			goto check_duplicate;
 		log_error("Failed to open create %s: %d", path, errno);
 		return 0;
 	}
@@ -371,6 +392,39 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 		log_sys_debug("close", path);
 
 	return 1;
+
+check_duplicate:
+
+	/*
+	 * If a PVID online file already exists for this PVID, check if the
+	 * file contains a different device number, and if so we may have a
+	 * duplicate PV.
+	 *
+	 * FIXME: disable autoactivation of the VG somehow?
+	 * The VG may or may not already be activated when a dupicate appears.
+	 * Perhaps write a new field in the pv online or vg online file?
+	 */
+
+	memset(file_vgname, 0, sizeof(file_vgname));
+
+	_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+
+	if ((file_major == major) && (file_minor == minor)) {
+		log_debug("Existing online file for %d:%d", major, minor);
+		return 1;
+	}
+
+	/* Don't know how vgname might not match, but it's not good so fail. */
+
+	if ((file_major != major) || (file_minor != minor))
+		log_error("pvscan[%d] PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
+			  getpid(), dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
+
+	if (file_vgname[0] && strcmp(file_vgname, vgname))
+		log_error("pvscan[%d] PV %s has unexpected VG %s vs %s.",
+			  getpid(), dev_name(dev), vgname, file_vgname);
+
+	return 0;
 }
 
 static int _online_pvid_file_exists(const char *pvid)
@@ -511,23 +565,39 @@ struct _pvscan_baton {
 	struct cmd_context *cmd;
 	struct volume_group *vg;
 	struct format_instance *fid;
-	int mda_read_errors;
 };
 
+/*
+ * If no mdas on this PV have a usable copy of the metadata,
+ * then the PV behaves like a PV without metadata, which
+ * causes the pvscan to scan all devs to find a copy of the
+ * metadata on another dev to check if the VG is now complete
+ * and can be activated.
+ */
+
 static int _online_pvscan_single(struct metadata_area *mda, void *baton)
 {
 	struct _pvscan_baton *b = baton;
 	struct volume_group *vg;
+	struct device *mda_dev = mda_get_device(mda);
 
 	if (mda_is_ignored(mda))
 		return 1;
 	vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL);
 	if (!vg) {
-		b->mda_read_errors++;
+		/*
+		 * Many or most cases of bad metadata would be found in
+		 * the scan, and the mda removed from the list, so we
+		 * would not get here to attempt this.
+		 */
+		log_print("pvscan[%d] metadata error in mda %d on %s.",
+			  getpid(), mda->mda_num, dev_name(mda_dev));
 		return 1;
 	}
 
-	/* FIXME Also ensure contents match etc. */
+	log_debug("pvscan vg_read %s seqno %u in mda %d on %s",
+		  vg->name, vg->seqno, mda->mda_num, dev_name(mda_dev));
+
 	if (!b->vg || vg->seqno > b->vg->seqno)
 		b->vg = vg;
 	else if (b->vg)
@@ -536,6 +606,17 @@ static int _online_pvscan_single(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
+static struct volume_group *_find_saved_vg(struct dm_list *saved_vgs, const char *vgname)
+{
+	struct vg_list *vgl;
+
+	dm_list_iterate_items(vgl, saved_vgs) {
+		if (!strcmp(vgname, vgl->vg->name))
+			return vgl->vg;
+	}
+	return NULL;
+}
+
 /*
  * disable_remove is 1 when resetting the online state, which begins with
  * removing all pvid files, and then creating new pvid files for PVs that
@@ -546,7 +627,7 @@ static int _online_pvscan_single(struct metadata_area *mda, void *baton)
 static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 			      struct dm_list *dev_args,
 			      struct dm_list *found_vgnames,
-			      struct dm_list *all_vgs,
+			      struct dm_list *saved_vgs,
 			      int disable_remove,
 			      const char **pvid_without_metadata)
 {
@@ -603,17 +684,8 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 
 	lvmcache_foreach_mda(info, _online_pvscan_single, &baton);
 
-	if (baton.mda_read_errors) {
-		/* Don't record the PV as online if there are errors reading the vg. */
-		log_print("pvscan[%d] PV %s ignore for metadata processing error.", getpid(), dev_name(dev));
-		if (baton.vg)
-			release_vg(baton.vg);
-		else
-			fmt->ops->destroy_instance(baton.fid);
-		return 1;
-	}
-
 	if (!baton.vg) {
+		log_print("pvscan[%d] PV %s has no VG metadata.", getpid(), dev_name(dev));
 		if (pvid_without_metadata)
 			*pvid_without_metadata = dm_pool_strdup(cmd->mem, dev->pvid);
 		fmt->ops->destroy_instance(baton.fid);
@@ -652,21 +724,14 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 
 	/*
 	 * Save vg's in case they need to be used at the end for checking PVs
-	 * without metadata (in _check_vg_with_pvid_complete).
+	 * without metadata (in _check_vg_with_pvid_complete), or activating.
 	 */
-	if (all_vgs && baton.vg) {
-		int found = 0;
-		dm_list_iterate_items(vgl, all_vgs) {
-			if (!strcmp(baton.vg->name, vgl->vg->name)) {
-				found = 1;
-				break;
-			}
-		}
-		if (!found) {
+	if (saved_vgs && baton.vg) {
+		if (!_find_saved_vg(saved_vgs, baton.vg->name)) {
 	       		if ((vgl = malloc(sizeof(struct vg_list)))) {
 				vgl->vg = baton.vg;
 				baton.vg = NULL;
-				dm_list_add(all_vgs, &vgl->list);
+				dm_list_add(saved_vgs, &vgl->list);
 			}
 		}
 	}
@@ -681,7 +746,7 @@ out:
  * This is to handle the case where pvscan --cache -aay (with no dev args)
  * gets to the final PV, completing the VG, but that final PV does not
  * have VG metadata.  In this case, we need to use VG metadata from a
- * previously scanned PV in the same VG, which we saved in the all_vgs
+ * previously scanned PV in the same VG, which we saved in the saved_vgs
  * list.  Using this saved metadata, we can find which VG this PVID
  * belongs to, and then check if that VG is now complete, and if so
  * add the VG name to the list of complete VGs to be autoactivated.
@@ -693,7 +758,7 @@ out:
  */
 static void _check_vg_with_pvid_complete(struct cmd_context *cmd,
 				         struct dm_list *found_vgnames,
-					 struct dm_list *all_vgs,
+					 struct dm_list *saved_vgs,
 					 const char *pvid)
 {
 	struct vg_list *vgl;
@@ -702,7 +767,7 @@ static void _check_vg_with_pvid_complete(struct cmd_context *cmd,
 	int pvids_not_online = 0;
 	int found;
 
-	dm_list_iterate_items(vgl, all_vgs) {
+	dm_list_iterate_items(vgl, saved_vgs) {
 		vg = vgl->vg;
 		found = 0;
 
@@ -749,16 +814,13 @@ static void _check_vg_with_pvid_complete(struct cmd_context *cmd,
 
 static void _online_pvscan_all_devs(struct cmd_context *cmd,
 				    struct dm_list *found_vgnames,
+				    struct dm_list *saved_vgs,
 				    struct dm_list *dev_args)
 {
-	struct dm_list all_vgs;
 	struct dev_iter *iter;
-	struct vg_list *vgl;
 	struct device *dev;
 	const char *pvid_without_metadata;
 
-	dm_list_init(&all_vgs);
-
 	lvmcache_label_scan(cmd);
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
@@ -774,19 +836,16 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 
 		pvid_without_metadata = NULL;
 
-		if (!_online_pvscan_one(cmd, dev, dev_args, found_vgnames, &all_vgs, 1, &pvid_without_metadata)) {
+		if (!_online_pvscan_one(cmd, dev, dev_args, found_vgnames, saved_vgs, 1, &pvid_without_metadata)) {
 			stack;
 			break;
 		}
 
 		/* This PV without metadata may complete a VG. */
 		if (pvid_without_metadata && found_vgnames)
-			_check_vg_with_pvid_complete(cmd, found_vgnames, &all_vgs, pvid_without_metadata);
+			_check_vg_with_pvid_complete(cmd, found_vgnames, saved_vgs, pvid_without_metadata);
 	}
 
-	dm_list_iterate_items(vgl, &all_vgs)
-		release_vg(vgl->vg);
-
 	dev_iter_destroy(iter);
 }
 
@@ -840,8 +899,236 @@ static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
 	return 1;
 }
 
+/*
+ * This is a very unconventional way of doing things because
+ * we want to figure out which devices to read the VG from
+ * without first scanning devices.  It's usually the reverse;
+ * we have to scan all devs, which tells us which devs we
+ * need to read to get the VG.
+ *
+ * We can do it this way only by cheating and using the pvid
+ * online files for devs that have been scanned by prior pvscan
+ * instances.
+ *
+ * This is similar to the hints file, but the hints file is
+ * always a full picture of PV state, and is only ever created
+ * by scanning all devs, whereas the online files are only
+ * created incrementally by scanning one device at a time.
+ * The online files are only used for determining complete VGs
+ * for the purpose of autoactivation, and no attempt is made
+ * to keep them in sync with lvm state once autoactivation
+ * is complete, but much effort is made to always ensure hints
+ * will accurately reflect PV state.
+ *
+ * The saved VG metadata tells us which PVIDs are needed to
+ * complete the VG.  The pv online files tell us which of those
+ * PVIDs are online, and the content of those pv online files
+ * tells us which major:minor number holds that PVID.  The
+ * dev_cache tell us which struct device has the major:minor.
+ * We end up with a list of struct devices that we need to
+ * scan/read in order to process/activate the VG.
+ */
+
+static int _get_devs_from_saved_vg(struct cmd_context *cmd, char *vgname,
+				   struct dm_list *saved_vgs,
+				   struct dm_list *devs)
+{
+	char path[PATH_MAX];
+	char file_vgname[NAME_LEN];
+	struct pv_list *pvl;
+	struct device_list *devl;
+	struct device *dev;
+	struct volume_group *vg;
+	const char *pvid;
+	dev_t devno;
+	int file_major = 0, file_minor = 0;
+
+	/*
+	 * We previously saved the metadata (as a struct vg) from the device
+	 * arg that was scanned.  Now use that metadata to put together a list
+	 * of devices for this VG.  (This could alternatively be worked out by
+	 * reading all the pvid online files, see which have a matching vg
+	 * name, and getting the device numbers from those files.)
+	 */
+	if (!(vg = _find_saved_vg(saved_vgs, vgname)))
+		return_0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pvid = (const char *)&pvl->pv->id.uuid;
+
+		memset(path, 0, sizeof(path));
+		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid);
+
+		file_major = 0;
+		file_minor = 0;
+		memset(file_vgname, 0, sizeof(file_vgname));
+
+		_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+
+		if (file_vgname[0] && strcmp(vgname, file_vgname)) {
+			log_error("Wrong VG found for %d:%d PVID %s: %s vs %s",
+				  file_major, file_minor, pvid, vgname, file_vgname);
+			return 0;
+		}
+
+		devno = MKDEV(file_major, file_minor);
+
+		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
+			log_error("No device found for %d:%d PVID %s", file_major, file_minor, pvid);
+			return 0;
+		}
+
+		if (!(devl = zalloc(sizeof(*devl))))
+			return_0;
+
+		devl->dev = dev;
+		dm_list_add(devs, &devl->list);
+		log_debug("pvscan using %s for PVID %s in VG %s", dev_name(dev), pvid, vgname);
+	}
+
+	return 1;
+}
+
+/*
+ * When there's a single VG to activate (the common case),
+ * optimize things by cutting out the process_each_vg().
+ *
+ * The main point of this optimization is to avoid extra
+ * device scanning in the common case where we're
+ * activating a completed VG after scanning a single PV.
+ * The scanning overhead of hundreds of concurrent
+ * activations from hundreds of PVs appearing together
+ * can be overwhelming, and scanning needs to be reduced
+ * as much as possible.
+ *
+ * The common process_each_vg will generally do:
+ * label scan all devs
+ * vg_read
+ *   lock vg
+ *   label rescan of only vg devs (often skipped)
+ *   read metadata
+ *   set pv devices (find devs for each PVID)
+ * do command (vgchange_activate)
+ * unlock vg
+ *
+ * In this optimized version with process_each we do:
+ * lock vg
+ * label scan of only vg devs
+ * vg_read
+ *   read metadata
+ *   set pv devices (find devs for each PVID)
+ * do command (vgchange_activate)
+ * unlock vg
+ *
+ * The optimized version avoids scanning all devs, which
+ * is important when there are many devs.
+ */
+
+static int _pvscan_aa_direct(struct cmd_context *cmd, struct pvscan_aa_params *pp, char *vgname,
+			     struct dm_list *saved_vgs)
+{
+	struct dm_list devs; /* device_list */
+	struct volume_group *vg;
+	struct pv_list *pvl;
+	const char *vgid;
+	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
+	int ret = ECMD_PROCESSED;
+
+	dm_list_init(&devs);
+
+	/*
+	 * Get list of devices for this VG so we can label scan them.
+	 * The saved VG struct gives the list of PVIDs in the VG.
+	 * The pvs_online/PVID files gives us the devnums for PVIDs.
+	 * The dev_cache gives us struct devices from the devnums.
+	 */
+	if (!_get_devs_from_saved_vg(cmd, vgname, saved_vgs, &devs)) {
+		log_error("pvscan activation for VG %s failed to find devices.", vgname);
+		return ECMD_FAILED;
+	}
+
+	/*
+	 * Lock the VG before scanning so we don't need to
+	 * rescan in _vg_read.  (The lock_vol and the
+	 * label rescan are then disabled in vg_read.)
+	 */
+	if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL)) {
+		log_error("pvscan activation for VG %s failed to lock VG.", vgname);
+		return ECMD_FAILED;
+	}
+
+	/*
+	 * Drop lvmcache info about the PV/VG that was saved
+	 * when originally identifying the PV.
+	 */
+	lvmcache_destroy(cmd, 1, 1);
+
+	label_scan_devs(cmd, NULL, &devs);
+
+	if (!(vgid = lvmcache_vgid_from_vgname(cmd, vgname))) {
+		log_error("pvscan activation for VG %s failed to find vgid.", vgname);
+		return ECMD_FAILED;
+	}
+
+	/*
+	 * can_use_one_scan and READ_WITHOUT_LOCK are both important key
+	 * changes made to vg_read that are possible because the VG is locked
+	 * above (lock_vol).
+	 */
+
+	cmd->can_use_one_scan = 1;
+
+	vg = vg_read(cmd, vgname, vgid, READ_WITHOUT_LOCK | READ_FOR_ACTIVATE, lockd_state, &error_flags, NULL);
+
+	if (!vg) {
+		/*
+		 * The common cases would already have been caught during the
+		 * original device arg scan.  There will be very few and unusual
+		 * cases that would be caught here.
+		 */
+		log_error("pvscan activation for VG %s cannot read (%x).", vgname, error_flags);
+		return ECMD_FAILED;
+	}
+
+	/*
+	 * These cases would already have been caught during the original
+	 * device arg scan.
+	 */
+	if (vg_is_clustered(vg))
+		goto_out;
+	if (vg_is_exported(vg))
+		goto_out;
+	if (vg_is_shared(vg))
+		goto_out;
+
+	/*
+	 * Verify that the devices we scanned above for the VG are in fact the
+	 * devices used by the VG we read.
+	 */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (dev_in_device_list(pvl->pv->dev, &devs))
+			continue;
+		log_error("pvscan activation for VG %s found different devices.", vgname);
+		ret = ECMD_FAILED;
+		goto out;
+	}
+
+	log_debug("pvscan autoactivating VG %s.", vgname);
+
+	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
+		log_error("%s: autoactivation failed.", vg->name);
+		pp->activate_errors++;
+	}
+
+out:
+	unlock_vg(cmd, vg, vgname);
+	release_vg(vg);
+	return ret;
+}
+
 static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
-		      struct dm_list *vgnames)
+		      struct dm_list *vgnames, struct dm_list *saved_vgs)
 {
 	struct processing_handle *handle = NULL;
 	struct dm_str_list *sl, *sl2;
@@ -880,7 +1167,13 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 		return ECMD_PROCESSED;
 	}
 
-	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_ACTIVATE, 0, handle, _pvscan_aa_single);
+	if (dm_list_size(vgnames) == 1) {
+		dm_list_iterate_items(sl, vgnames)
+			ret = _pvscan_aa_direct(cmd, pp, (char *)sl->str, saved_vgs);
+	} else {
+		/* FIXME: suppress label scan in process_each if label scan already done? */
+		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_ACTIVATE, 0, handle, _pvscan_aa_single);
+	}
 
 	destroy_processing_handle(cmd, handle);
 
@@ -893,9 +1186,12 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_list add_devs;
 	struct dm_list rem_devs;
 	struct dm_list vgnames;
+	struct dm_list vglist;
 	struct dm_list *complete_vgnames = NULL;
+	struct dm_list *saved_vgs = NULL;
 	struct device *dev;
 	struct device_list *devl;
+	struct vg_list *vgl;
 	const char *pv_name;
 	const char *pvid_without_metadata = NULL;
 	int32_t major = -1;
@@ -913,6 +1209,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	dm_list_init(&add_devs);
 	dm_list_init(&rem_devs);
 	dm_list_init(&vgnames);
+	dm_list_init(&vglist);
 
 	/*
 	 * When systemd/udev run pvscan --cache commands, those commands
@@ -921,8 +1218,10 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	init_udev_sleeping(0);
 
-	if (do_activate)
+	if (do_activate) {
 		complete_vgnames = &vgnames;
+		saved_vgs = &vglist;
+	}
 
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
@@ -1081,7 +1380,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		log_verbose("pvscan all devices for requested refresh.");
 		_online_files_remove(_pvs_online_dir);
 		_online_files_remove(_vgs_online_dir);
-		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
+		_online_pvscan_all_devs(cmd, complete_vgnames, saved_vgs, NULL);
 
 		cmd->pvscan_recreate_hints = 0;
 		cmd->use_hints = 0;
@@ -1120,7 +1419,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 			add_single_count++;
 
-			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, NULL, 0, &pvid_without_metadata))
+			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, saved_vgs, 0, &pvid_without_metadata))
 				add_errors++;
 		}
 	}
@@ -1137,8 +1436,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	if (!dm_list_empty(&add_devs) && complete_vgnames && dm_list_empty(complete_vgnames) &&
 	    pvid_without_metadata && do_activate) {
-		log_verbose("pvscan all devices for PV without metadata: %s.", pvid_without_metadata);
-		_online_pvscan_all_devs(cmd, complete_vgnames, &add_devs);
+		log_print("pvscan[%d] scan all devices for PV without metadata: %s.", getpid(), pvid_without_metadata);
+		_online_pvscan_all_devs(cmd, complete_vgnames, saved_vgs, &add_devs);
 	}
 
 	/*
@@ -1159,11 +1458,14 @@ activate:
 	 * list, and we can attempt to autoactivate LVs in the VG.
 	 */
 	if (do_activate)
-		ret = _pvscan_aa(cmd, &pp, complete_vgnames);
+		ret = _pvscan_aa(cmd, &pp, complete_vgnames, saved_vgs);
 
 	if (add_errors || pp.activate_errors)
 		ret = ECMD_FAILED;
 
+	dm_list_iterate_items(vgl, &vglist)
+		release_vg(vgl->vg);
+
 	if (!sync_local_dev_names(cmd))
 		stack;
 	return ret;
diff --git a/tools/toollib.c b/tools/toollib.c
index 1f41feb..bb97e15 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -26,12 +26,6 @@
 					((ret_code) == ECMD_PROCESSED) ? REPORT_OBJECT_CMDLOG_SUCCESS \
 								   : REPORT_OBJECT_CMDLOG_FAILURE, (ret_code))
 
-struct device_id_list {
-	struct dm_list list;
-	struct device *dev;
-	char pvid[ID_LEN + 1];
-};
-
 const char *command_name(struct cmd_context *cmd)
 {
 	return cmd->command->name;


