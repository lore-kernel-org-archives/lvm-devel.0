From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Feb 2019 16:31:56 -0500
Subject: master - pvscan: autoactivate a VG once
Message-ID: <201902212131.x1LLVuUE001238@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74a388cca15baa4149a24e37bccb421c53f726e5
Commit:        74a388cca15baa4149a24e37bccb421c53f726e5
Parent:        f0089472e7fd679acbc004daf4b35e9a86fc11a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 13 14:21:56 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 21 15:17:41 2019 -0600

pvscan: autoactivate a VG once

When a VG has multiple PVs, and all those PVs come online
at the same time, concurrent pvscans for each PV will all
create the individual pvid files, and all will often see
the VG is now complete.  This causes each of the pvscan
commands to think it should activate the VG, so there
are multiple activations of the same VG.  The vg lock
serializes them, and only the first pvscan actually does
the activation, but there is still a lot of extra overhead
and time used by the other pvscans that attempt to
activate the already active VG.  This can lead to a backlog
of pvscans and timeouts.

To fix this, this adds a new /run/lvm/vgs_online/ dir that
works like the existing /run/lvm/pvs_online/ dir.  Each pvscan
that wants to activate a VG will first try to exlusively create
the file vgs_online/<vgname>.  Only the first pvscan will
succeed, and that one will do the VG activation. The other
pvscans will find the vgname file exists and will not do the
activation step.

When a PV goes offline, the vgs_online file for the corresponding
VG is removed.  This allows the VG to be autoactivated again
when the PV comes online again.  This requires that the vgname be
stored in the pvid files.
---
 test/shell/pvscan-autoactivate.sh |   39 ++++---
 test/shell/pvscan-cache.sh        |   20 +++-
 tools/pvscan.c                    |  214 +++++++++++++++++++++++++++++++-----
 3 files changed, 226 insertions(+), 47 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index cd360e9..419fb9b 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -14,14 +14,15 @@ SKIP_WITH_LVMPOLLD=1
 
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
-ONLINEDIR="$RUNDIR/lvm/pvs_online"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
 
 # FIXME: kills logic for running system
-_clear_online() {
+_clear_online_files() {
 	# wait till udev is finished
 	aux udev_wait
-	rm -f "$ONLINEDIR"/*
-	test -n "${1+varset}" || touch "$ONLINEDIR/foo"
+	rm -f "$PVS_ONLINE_DIR"/*
+	rm -f "$VGS_ONLINE_DIR"/*
 }
 
 . lib/inittest
@@ -32,8 +33,9 @@ vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 
 # the first pvscan scans all devs
-test -d "$ONLINEDIR" || mkdir -p "$ONLINEDIR"
-_clear_online nofoo
+test -d "$PVS_ONLINE_DIR" || mkdir -p "$PVS_ONLINE_DIR"
+test -d "$VGS_ONLINE_DIR" || mkdir -p "$VGS_ONLINE_DIR"
+_clear_online_files
 
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
@@ -42,7 +44,7 @@ lvchange -an $vg1
 # the first pvscan scans all devs even when
 # only one device is specified
 
-_clear_online nofoo
+_clear_online_files
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -50,7 +52,8 @@ lvchange -an $vg1
 
 # touch foo to disable first-pvscan case,
 # then check pvscan with no args scans all
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay
 check lv_field $vg1/$lv1 lv_active "active"
@@ -60,7 +63,8 @@ lvchange -an $vg1
 # then check that vg is activated only after
 # both devs appear separately
 
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
@@ -72,7 +76,8 @@ lvchange -an $vg1
 # then check that vg is activated when both
 # devs appear together
 
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev1" "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -92,7 +97,8 @@ lvcreate -n $lv1 -l 4 -a n $vg1
 # touch foo to disable first-pvscan case,
 # test case where dev with metadata appears first
 
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active ""
@@ -104,7 +110,8 @@ lvchange -an $vg1
 # test case where dev without metadata
 # appears first which triggers scanning all
 
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -115,7 +122,7 @@ lvchange -an $vg1
 # dev without metadata is scanned, but
 # first-pvscan case scans all devs
 
-_clear_online nofoo
+_clear_online_files
 
 pvscan --cache -aay "$dev1"
 check lv_field $vg1/$lv1 lv_active "active"
@@ -125,7 +132,8 @@ lvchange -an $vg1
 # is online without the -aay option to
 # activate until after they are online
 
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
@@ -137,7 +145,8 @@ lvchange -an $vg1
 
 # like previous
 
-_clear_online
+_clear_online_files
+touch "$RUNDIR/lvm/pvs_online/foo"
 
 pvscan --cache "$dev1"
 check lv_field $vg1/$lv1 lv_active ""
diff --git a/test/shell/pvscan-cache.sh b/test/shell/pvscan-cache.sh
index c272c6c..e0576f9 100644
--- a/test/shell/pvscan-cache.sh
+++ b/test/shell/pvscan-cache.sh
@@ -13,6 +13,18 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+
+_clear_online_files() {
+	# wait till udev is finished
+	aux udev_wait
+	rm -f "$PVS_ONLINE_DIR"/*
+	rm -f "$VGS_ONLINE_DIR"/*
+}
+
 . lib/inittest
 
 aux prepare_pvs 2
@@ -35,9 +47,12 @@ check lv_exists $vg1
 check lv_field $vg1/$lv1 lv_active ""
 
 # Check that an LV cannot be activated by pvscan while VG is exported
+vgchange -an $vg1
+_clear_online_files
 vgexport $vg1
-not pvscan --cache -aay "$dev1"
-not pvscan --cache -aay "$dev2"
+pvscan --cache -aay "$dev1" || true
+pvscan --cache -aay "$dev2" || true
+_clear_online_files
 vgimport $vg1
 check lv_exists $vg1
 check lv_field $vg1/$lv1 lv_active ""
@@ -51,6 +66,7 @@ lvchange -an $vg1/$lv1
 # metadata which hasn't been updated for some
 # time and also since the MDA is marked as ignored,
 # it should really be *ignored*!
+_clear_online_files
 pvchange --metadataignore y "$dev1"
 aux disable_dev "$dev2"
 pvscan --cache
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 5928f7e..c6f2902 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -37,6 +37,9 @@ struct pvscan_aa_params {
 	unsigned int activate_errors;
 };
 
+
+static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
+static const char *_vgs_online_dir = DEFAULT_RUN_DIR "/vgs_online";
 static const char *_online_file = DEFAULT_RUN_DIR "/pvs_online_lock";
 static int _online_fd = -1;
 
@@ -228,7 +231,51 @@ out:
 	return ret;
 }
 
-static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
+static char *_vgname_in_pvid_file_buf(char *buf)
+{
+	char *p, *n;
+
+	/*
+	 * file contains:
+	 * <major>:<minor>\n
+	 * vg:<vgname>\n\0
+	 */
+
+	if (!(p = strchr(buf, '\n')))
+		return NULL;
+
+	p++; /* skip \n */
+
+	if (*p && !strncmp(p, "vg:", 3)) {
+		if ((n = strchr(p, '\n')))
+			*n = '\0';
+		return p + 3;
+	}
+	return NULL;
+}
+
+#define MAX_PVID_FILE_SIZE 512
+
+/*
+ * When a PV goes offline, remove the vg online file for that VG
+ * (even if other PVs for the VG are still online).  This means
+ * that the vg will be activated again when it becomes complete.
+ */
+
+static void _online_vg_file_remove(const char *vgname)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
+		log_error("Path %s/%s is too long.", _vgs_online_dir, vgname);
+		return;
+	}
+
+	log_debug("Unlink vg online: %s", path);
+
+	if (unlink(path))
+		log_sys_debug("unlink", path);
+}
 
 /*
  * When a device goes offline we only know its major:minor, not its PVID.
@@ -241,8 +288,9 @@ static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
 static void _online_pvid_file_remove_devno(int major, int minor)
 {
 	char path[PATH_MAX];
-	char buf[32];
-	char buf_in[32];
+	char buf[MAX_PVID_FILE_SIZE];
+	char buf_in[MAX_PVID_FILE_SIZE];
+	char *vgname = NULL;
 	DIR *dir;
 	struct dirent *de;
 	int fd, rv;
@@ -268,6 +316,8 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 			continue;
 		}
 
+		memset(buf_in, 0, sizeof(buf_in));
+
 		rv = read(fd, buf_in, sizeof(buf_in));
 		if (close(fd))
 			log_sys_debug("close", path);
@@ -277,9 +327,16 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		}
 
 		if (!strncmp(buf, buf_in, strlen(buf))) {
-			log_debug("Unlink pv online %s %s", buf, path);
+			log_debug("Unlink pv online %s", path);
 			if (unlink(path))
 				log_sys_debug("unlink", path);
+
+			/* vgname points to an offset in buf_in */
+			if ((vgname = _vgname_in_pvid_file_buf(buf_in)))
+				_online_vg_file_remove(vgname);
+			else
+				log_debug("No vgname in pvid file");
+
 			break;
 		}
 	}
@@ -287,13 +344,13 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		log_sys_debug("closedir", _pvs_online_dir);
 }
 
-static void _online_pvid_files_remove(void)
+static void _online_files_remove(const char *dirpath)
 {
 	char path[PATH_MAX];
 	DIR *dir;
 	struct dirent *de;
 
-	if (!(dir = opendir(_pvs_online_dir)))
+	if (!(dir = opendir(dirpath)))
 		return;
 
 	while ((de = readdir(dir))) {
@@ -301,22 +358,26 @@ static void _online_pvid_files_remove(void)
 			continue;
 
 		memset(path, 0, sizeof(path));
-		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, de->d_name);
+		snprintf(path, sizeof(path), "%s/%s", dirpath, de->d_name);
 		if (unlink(path))
 			log_sys_debug("unlink", path);
 	}
 	if (closedir(dir))
-		log_sys_debug("closedir", _pvs_online_dir);
+		log_sys_debug("closedir", dirpath);
 }
 
-static int _online_pvid_file_create(struct device *dev)
+static int _online_pvid_file_create(struct device *dev, const char *vgname)
 {
 	char path[PATH_MAX];
-	char buf[32];
+	char buf[MAX_PVID_FILE_SIZE];
 	int major, minor;
 	int fd;
 	int rv;
 	int len;
+	int len1 = 0;
+	int len2 = 0;
+
+	memset(buf, 0, sizeof(buf));
 
 	major = (int)MAJOR(dev->dev);
 	minor = (int)MINOR(dev->dev);
@@ -326,16 +387,26 @@ static int _online_pvid_file_create(struct device *dev)
 		return 0;
 	}
 
-	if ((len = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
-		log_error("Device %d:%d is too long.", major, minor);
+	if ((len1 = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
+		log_error("Cannot create online pv file for %d:%d.", major, minor);
 		return 0;
 	}
 
+	if (vgname) {
+		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
+			log_warn("Incomplete online pv file for %d:%d vg %s.", major, minor, vgname);
+			/* can still continue without vgname */
+			len2 = 0;
+		}
+	}
+
+	len = len1 + len2;
+
 	log_debug("Create pv online: %s %d:%d %s", path, major, minor, dev_name(dev));
 
 	fd = open(path, O_CREAT | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
 	if (fd < 0) {
-		log_error("Failed to open %s: %d", path, errno);
+		log_error("Failed to open create %s: %d", path, errno);
 		return 0;
 	}
 
@@ -380,20 +451,45 @@ static int _online_pvid_file_exists(const char *pvid)
 	return 0;
 }
 
-static void _online_pvid_dir_setup(void)
+static void _online_dir_setup(void)
 {
 	struct stat st;
 	int rv;
 
+	if (!stat(DEFAULT_RUN_DIR, &st))
+		goto do_pvs;
+
+	log_debug("Creating run_dir.");
+	dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
+	rv = mkdir(DEFAULT_RUN_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
+		log_error("Failed to create %s %d", DEFAULT_RUN_DIR, errno);
+
+do_pvs:
 	if (!stat(_pvs_online_dir, &st))
-		return;
+		goto do_vgs;
 
+	log_debug("Creating pvs_online_dir.");
 	dm_prepare_selinux_context(_pvs_online_dir, S_IFDIR);
-	rv = mkdir(_pvs_online_dir, 0777);
+	rv = mkdir(_pvs_online_dir, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(_pvs_online_dir, &st))
+		log_error("Failed to create %s %d", _pvs_online_dir, errno);
+
+do_vgs:
+	if (!stat(_vgs_online_dir, &st))
+		return;
+
+	log_debug("Creating vgs_online_dir.");
+	dm_prepare_selinux_context(_vgs_online_dir, S_IFDIR);
+	rv = mkdir(_vgs_online_dir, 0755);
 	dm_prepare_selinux_context(NULL, 0);
 
-	if (rv < 0)
-		log_debug("Failed to create %s", _pvs_online_dir);
+	if ((rv < 0) && stat(_vgs_online_dir, &st))
+		log_error("Failed to create %s %d", _vgs_online_dir, errno);
 }
 
 static void _online_file_setup(void)
@@ -404,8 +500,10 @@ static void _online_file_setup(void)
 	if (!stat(_online_file, &st))
 		return;
 
-	if (!(fp = fopen(_online_file, "w")))
+	if (!(fp = fopen(_online_file, "w"))) {
+		log_error("Failed to create %s %d", _online_file, errno);
 		return;
+	}
 	if (fclose(fp))
 		stack;
 }
@@ -445,11 +543,13 @@ static int _online_pv_found(struct cmd_context *cmd,
 	 * Create file named for pvid to record this PV is online.
 	 */
 
-	if (!_online_pvid_file_create(dev))
+	if (!_online_pvid_file_create(dev, vg ? vg->name : NULL))
 		return_0;
 
-	if (!vg || !found_vgnames)
+	if (!vg || !found_vgnames) {
+		log_print("pvscan[%d] PV %s online.", getpid(), dev_name(dev));
 		return 1;
+	}
 
 	/*
 	 * Check if all the PVs for this VG are online.  This is only
@@ -472,8 +572,13 @@ static int _online_pv_found(struct cmd_context *cmd,
 	 * in the VG, which means the VG is not yet complete.
 	 */
 
-	if (pvids_not_online)
+	if (pvids_not_online) {
+		log_print("pvscan[%d] PV %s online, VG %s incomplete (need %d).",
+			  getpid(), dev_name(dev), vg->name, pvids_not_online);
 		return 1;
+	}
+
+	log_print("pvscan[%d] PV %s online, VG %s is complete.", getpid(), dev_name(dev), vg->name);
 
 	/*
 	 * When all PVIDs from the VG are online, then add vgname to
@@ -544,7 +649,7 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 	log_debug("pvscan metadata from dev %s", dev_name(dev));
 
 	if (udev_dev_is_mpath_component(dev)) {
-		log_debug("Ignore multipath component for pvscan.");
+		log_print("pvscan[%d] ignore multipath component %s.", getpid(), dev_name(dev));
 		return 1;
 	}
 
@@ -652,10 +757,37 @@ static int _pvscan_aa_single(struct cmd_context *cmd, const char *vg_name,
 	return ECMD_PROCESSED;
 }
 
+static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
+{
+	char path[PATH_MAX];
+	int fd;
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
+		log_error("Path %s/%s is too long.", _vgs_online_dir, vgname);
+		return 0;
+	}
+
+	log_debug("Create vg online: %s", path);
+
+	fd = open(path, O_CREAT | O_EXCL | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		log_debug("Failed to create %s: %d", path, errno);
+		return 0;
+	}
+
+	/* We don't care about syncing, these files are not even persistent. */
+
+	if (close(fd))
+		log_sys_debug("close", path);
+
+	return 1;
+}
+
 static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 		      struct dm_list *vgnames)
 {
 	struct processing_handle *handle = NULL;
+	struct dm_str_list *sl, *sl2;
 	int ret;
 
 	if (dm_list_empty(vgnames)) {
@@ -670,6 +802,27 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 
 	handle->custom_handle = pp;
 
+	/*
+	 * For each complete vg that can be autoactivated, see if this
+	 * particular pvscan command should activate the vg.  There can be
+	 * multiple concurrent pvscans for the same completed vg (when all the
+	 * PVs for the VG appear at once), and we want only one of the pvscans
+	 * to run the activation.  The first to create the file will do it.
+	 */
+	dm_list_iterate_items_safe(sl, sl2, vgnames) {
+		if (!_online_vg_file_create(cmd, sl->str)) {
+			log_print("pvscan[%d] VG %s skip autoactivation.", getpid(), sl->str);
+			str_list_del(vgnames, sl->str);
+			continue;
+		}
+		log_print("pvscan[%d] VG %s run autoactivation.", getpid(), sl->str);
+	}
+
+	if (dm_list_empty(vgnames)) {
+		destroy_processing_handle(cmd, handle);
+		return ECMD_PROCESSED;
+	}
+
 	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_UPDATE, 0, handle, _pvscan_aa_single);
 
 	destroy_processing_handle(cmd, handle);
@@ -711,7 +864,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	_online_pvid_dir_setup();
+	_online_dir_setup();
 	_online_file_setup();
 	
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
@@ -734,8 +887,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 		_lock_online(LOCK_EX, 0);
 		log_verbose("pvscan all devices for requested refresh.");
-		_online_pvid_files_remove();
-		/* identify complete vgs, and only activate those vgs */
+		_online_files_remove(_pvs_online_dir);
+		_online_files_remove(_vgs_online_dir);
 		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
 		_unlock_online();
 		goto activate;
@@ -763,16 +916,17 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * In the non-init case, a VG with two PVs, where both PVs appear at once,
 	 * two parallel pvscans for each PV create the pvid files for each PV in
 	 * parallel, then both pvscans see the vg has completed, and both pvscans
-	 * activate the VG in parallel.  The activations should be serialized by
-	 * the VG lock.
+	 * activate the VG in parallel.  The first pvscan to create the vgname
+	 * file in vgs_online will do the activation, any others will skip it.
 	 */
 
 	_lock_online(LOCK_EX, 0);
 
 	if (_online_pvid_files_missing()) {
 		log_verbose("pvscan all devices to initialize available PVs.");
-		_online_pvid_files_remove();
-		/* identify complete vgs, and only activate those vgs */
+		_online_files_remove(_pvs_online_dir);
+		_online_files_remove(_vgs_online_dir);
+		cmd->pvscan_cache_single = 1;
 		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
 		_unlock_online();
 		goto activate;


