From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Oct 2021 17:43:25 +0000 (GMT)
Subject: main - pvscan: add options listlvs listvg checkcomplete
Message-ID: <20211007174325.2BAD13857C47@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b6782fa0139e412f827cc9d1f0cd96ea38e27b0
Commit:        0b6782fa0139e412f827cc9d1f0cd96ea38e27b0
Parent:        3e1316bb09b087ec79c9661ead14d8556c36fa8d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 9 10:59:40 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 7 12:06:49 2021 -0500

pvscan: add options listlvs listvg checkcomplete

pvscan --cache <dev>
    . read only dev
    . create online file for dev

pvscan --listvg <dev>
    . read only dev
    . list VG using dev

pvscan --listlvs <dev>
    . read only dev
    . list VG using dev
    . list LVs using dev

pvscan --cache --listvg [--checkcomplete] <dev>
    . read only dev
    . create online file for dev
    . list VG using dev
    . [check online files and report if VG is complete]

pvscan --cache --listlvs [--checkcomplete] <dev>
    . read only dev
    . create online file for dev
    . list VG using dev
    . list LVs using dev
    . [check online files and report if VG is complete]
    . [check online files and report if LVs are complete]

[--vgonline]
can be used with --checkcomplete, to enable use of a vg online
file.  This results in only the first pvscan command to see
the complete VG to report 'VG complete', and others will report
'VG finished'.  This allows the caller to easily run a single
activation of the VG.

[--udevoutput]
can be used with --cache --listvg --checkcomplete, to enable
an output mode that prints LVM_VG_NAME_COMPLETE='vgname' that
a udev rule can import, and prevents other output from the
command (other output causes udev to ignore the command.)

The list of complete LVs is meant to be passed to lvchange -aay,
or the complete VG used with vgchange -aay.

When --checkcomplete is used, lvm assumes that that the output
will be used to trigger event-based autoactivation, so the pvscan
does nothing if event_activation=0 and --checkcomplete is used.

Example of listlvs
------------------

$ lvs -a vg -olvname,devices
  LV     Devices
  lv_a   /dev/loop0(0)
  lv_ab  /dev/loop0(1),/dev/loop1(1)
  lv_abc /dev/loop0(3),/dev/loop1(3),/dev/loop2(1)
  lv_b   /dev/loop1(0)
  lv_c   /dev/loop2(0)

$ pvscan --cache --listlvs --checkcomplete /dev/loop0
  pvscan[35680] PV /dev/loop0 online, VG vg incomplete (need 2).
  VG vg incomplete
  LV vg/lv_a complete
  LV vg/lv_ab incomplete
  LV vg/lv_abc incomplete

$ pvscan --cache --listlvs --checkcomplete /dev/loop1
  pvscan[35681] PV /dev/loop1 online, VG vg incomplete (need 1).
  VG vg incomplete
  LV vg/lv_b complete
  LV vg/lv_ab complete
  LV vg/lv_abc incomplete

$ pvscan --cache --listlvs --checkcomplete /dev/loop2
  pvscan[35682] PV /dev/loop2 online, VG vg is complete.
  VG vg complete
  LV vg/lv_c complete
  LV vg/lv_abc complete

Example of listvg
-----------------

$ pvscan --cache --listvg --checkcomplete /dev/loop0
  pvscan[35684] PV /dev/loop0 online, VG vg incomplete (need 2).
  VG vg incomplete

$ pvscan --cache --listvg --checkcomplete /dev/loop1
  pvscan[35685] PV /dev/loop1 online, VG vg incomplete (need 1).
  VG vg incomplete

$ pvscan --cache --listvg --checkcomplete /dev/loop2
  pvscan[35686] PV /dev/loop2 online, VG vg is complete.
  VG vg complete
---
 lib/commands/toolcontext.h |   1 +
 lib/metadata/metadata.c    |  33 ++++
 lib/metadata/metadata.h    |   4 +
 tools/args.h               |  20 +++
 tools/command-lines.in     |  30 +++-
 tools/lvmcmdline.c         |   4 +
 tools/pvscan.c             | 418 ++++++++++++++++++++++++++++++++++-----------
 tools/toollib.c            |  18 ++
 tools/tools.h              |   2 +
 9 files changed, 431 insertions(+), 99 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 8f11a7714..731cc7ee0 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -29,6 +29,7 @@ struct config_info {
 	int debug_classes;
 	int verbose;
 	int silent;
+	int suppress;
 	int test;
 	int yes;
 	int syslog;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5fa623ec9..c4f65366b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5279,3 +5279,36 @@ struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_
 
 	return vg;
 }
+
+int get_visible_lvs_using_pv(struct cmd_context *cmd, struct volume_group *vg, struct device *dev,
+			     struct dm_list *lvs_list)
+{
+	struct pv_list *pvl;
+	struct lv_list *lvl, *lvl2;
+	struct physical_volume *pv = NULL;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->dev == dev) {
+			pv = pvl->pv;
+			break;
+		}
+	}
+
+	if (!pv)
+		return_0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!lv_is_visible(lvl->lv))
+			continue;
+		if (!lv_is_on_pv(lvl->lv, pv))
+			continue;
+
+		if (!(lvl2 = dm_pool_zalloc(cmd->mem, sizeof(*lvl2))))
+			return_0;
+		lvl2->lv = lvl->lv;
+		dm_list_add(lvs_list, &lvl2->list);
+	}
+
+	return 1;
+}
+
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 95ca320e6..6c39ff845 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -535,4 +535,8 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
 
 void set_pv_devices(struct format_instance *fid, struct volume_group *vg);
 
+int get_visible_lvs_using_pv(struct cmd_context *cmd, struct volume_group *vg, struct device *dev,
+                            struct dm_list *lvs_list);
+
+
 #endif
diff --git a/tools/args.h b/tools/args.h
index 05c16d94a..8ce176739 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -329,6 +329,19 @@ arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0,
     "start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS\n"
     "in the source). Use with care.\n")
 
+arg(listlvs_ARG, '\0', "listlvs", 0, 0, 0,
+    "Print a list of LVs that use the device.\n")
+
+arg(listvg_ARG, '\0', "listvg", 0, 0, 0,
+    "Print the VG that uses the device.\n")
+
+arg(checkcomplete_ARG, '\0', "checkcomplete", 0, 0, 0,
+    "Check if all the devices used by a VG or LV are present,\n"
+    "and print \"complete\" or \"incomplete\" for each listed\n"
+    "VG or LV.  This option is used as a part of event-based\n"
+    "autoactivation, so pvscan will do nothing if this option\n"
+    "is set and event_activation=0 in the config settings.\n")
+
 arg(lockopt_ARG, '\0', "lockopt", string_VAL, 0, 0,
     "Used to pass options for special cases to lvmlockd.\n"
     "See \\fBlvmlockd\\fP(8) for more information.\n")
@@ -816,6 +829,9 @@ arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
     "(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).\n"
     "Use inferred types with care because it can lead to unexpected results.\n")
 
+arg(udevoutput_ARG, '\0', "udevoutput", 0, 0, 0,
+    "Command output is modified to be imported from a udev rule.\n")
+
 arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
     "Produce output immediately without sorting or aligning the columns properly.\n")
 
@@ -892,6 +908,10 @@ arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", vgmetadatacopies_VAL, 0, 0,
     "\\fBall\\fP causes LVM to first clear the metadataignore flags on\n"
     "all PVs, and then to become unmanaged.\n")
 
+arg(vgonline_ARG, '\0', "vgonline", 0, 0, 0,
+    "The first command to see a complete VG will report it uniquely.\n"
+    "Other commands to see the complete VG will report it differently.\n")
+
 arg(withsummary_ARG, '\0', "withsummary", 0, 0, 0,
     "Display a one line comment for each configuration node.\n")
 
diff --git a/tools/command-lines.in b/tools/command-lines.in
index e63b2bcc3..332ad8a3b 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1634,11 +1634,37 @@ DESC: Display PV information.
 
 pvscan --cache_long
 OO: --ignorelockingfailure, --reportformat ReportFmt,
---activate ay, --major Number, --minor Number, --noudevsync
+--major Number, --minor Number, --noudevsync
 OP: PV|String ...
 IO: --background
 ID: pvscan_cache
-DESC: Autoactivate a VG when all PVs are online.
+DESC: Record that a PV is online or offline.
+
+pvscan --cache_long --activate ay
+OO: --ignorelockingfailure, --reportformat ReportFmt,
+--major Number, --minor Number, --noudevsync
+OP: PV|String ...
+IO: --background
+ID: pvscan_cache
+DESC: Record that a PV is online and autoactivate the VG if complete.
+
+pvscan --cache_long --listvg PV
+OO: --ignorelockingfailure, --checkcomplete, --vgonline, --udevoutput
+ID: pvscan_cache
+DESC: Record that a PV is online and list the VG using the PV.
+
+pvscan --cache_long --listlvs PV
+OO: --ignorelockingfailure, --checkcomplete, --vgonline
+ID: pvscan_cache
+DESC: Record that a PV is online and list LVs using the PV.
+
+pvscan --listlvs PV
+ID: pvscan_cache
+DESC: List LVs using the PV.
+
+pvscan --listvg PV
+ID: pvscan_cache
+DESC: List the VG using the PV.
 
 ---
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1fc2dc3bb..d82c374c6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2391,6 +2391,9 @@ static void _reset_current_settings_to_default(struct cmd_context *cmd)
 
 static void _get_current_output_settings_from_args(struct cmd_context *cmd)
 {
+	if (arg_is_set(cmd, udevoutput_ARG))
+		cmd->current_settings.suppress = 1;
+
 	if (arg_is_set(cmd, debug_ARG))
 		cmd->current_settings.debug = _LOG_FATAL + (arg_count(cmd, debug_ARG) - 1);
 
@@ -2406,6 +2409,7 @@ static void _get_current_output_settings_from_args(struct cmd_context *cmd)
 
 static void _apply_current_output_settings(struct cmd_context *cmd)
 {
+	log_suppress(cmd->current_settings.suppress);
 	init_debug(cmd->current_settings.debug);
 	init_debug_classes_logged(cmd->default_settings.debug_classes);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a0be17e8e..75a08d325 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -179,6 +179,27 @@ out:
 	return ret;
 }
 
+/*
+ * Avoid a duplicate pvscan[%d] prefix when logging to the journal.
+ * FIXME: this should probably replace if (udevoutput) with
+ * if (log_journal & LOG_JOURNAL_OUTPUT)
+ */
+#define log_print_pvscan(cmd, fmt, args...) \
+do \
+	if (arg_is_set(cmd, udevoutput_ARG)) \
+		log_print(fmt, ##args); \
+	else \
+		log_print("pvscan[%d] " fmt, getpid(), ##args); \
+while (0)
+
+#define log_error_pvscan(cmd, fmt, args...) \
+do \
+	if (arg_is_set(cmd, udevoutput_ARG)) \
+		log_error(fmt, ##args); \
+	else \
+		log_error("pvscan[%d] " fmt, getpid(), ##args); \
+while (0)
+
 static char *_vgname_in_pvid_file_buf(char *buf)
 {
 	char *p, *n;
@@ -260,7 +281,7 @@ static void _lookup_file_remove(char *vgname)
  * that the vg will be activated again when it becomes complete.
  */
 
-static void _online_vg_file_remove(const char *vgname)
+void online_vg_file_remove(const char *vgname)
 {
 	char path[PATH_MAX];
 
@@ -315,7 +336,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 				log_sys_debug("unlink", path);
 
 			if (file_vgname[0]) {
-				_online_vg_file_remove(file_vgname);
+				online_vg_file_remove(file_vgname);
 				_lookup_file_remove(file_vgname);
 			}
 		}
@@ -346,7 +367,7 @@ static void _online_files_remove(const char *dirpath)
 		log_sys_debug("closedir", dirpath);
 }
 
-static int _online_pvid_file_create(struct device *dev, const char *vgname)
+static int _online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const char *vgname)
 {
 	char path[PATH_MAX];
 	char buf[MAX_PVID_FILE_SIZE] = { 0 };
@@ -363,18 +384,18 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 	minor = (int)MINOR(dev->dev);
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, dev->pvid) < 0) {
-		log_error("Path %s/%s is too long.", _pvs_online_dir, dev->pvid);
+		log_error_pvscan(cmd, "Path %s/%s is too long.", _pvs_online_dir, dev->pvid);
 		return 0;
 	}
 
 	if ((len1 = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
-		log_error("Cannot create online file path for %s %d:%d.", dev_name(dev), major, minor);
+		log_error_pvscan(cmd, "Cannot create online file path for %s %d:%d.", dev_name(dev), major, minor);
 		return 0;
 	}
 
 	if (vgname) {
 		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
-			log_warn("Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
+			log_print_pvscan(cmd, "Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
 			/* can still continue without vgname */
 			len2 = 0;
 		}
@@ -388,7 +409,7 @@ static int _online_pvid_file_create(struct device *dev, const char *vgname)
 	if (fd < 0) {
 		if (errno == EEXIST)
 			goto check_duplicate;
-		log_error("Failed to create online file for %s path %s error %d", dev_name(dev), path, errno);
+		log_error_pvscan(cmd, "Failed to create online file for %s path %s error %d", dev_name(dev), path, errno);
 		return 0;
 	}
 
@@ -436,12 +457,12 @@ check_duplicate:
 	/* Don't know how vgname might not match, but it's not good so fail. */
 
 	if ((file_major != major) || (file_minor != minor))
-		log_error("pvscan[%d] PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
-			  getpid(), dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
+		log_error_pvscan(cmd, "PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
+			         dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
 
 	if (file_vgname[0] && vgname && strcmp(file_vgname, vgname))
-		log_error("pvscan[%d] PV %s has unexpected VG %s vs %s.",
-			  getpid(), dev_name(dev), vgname, file_vgname);
+		log_error_pvscan(cmd, "PV %s has unexpected VG %s vs %s.",
+			         dev_name(dev), vgname, file_vgname);
 
 	return 0;
 }
@@ -476,7 +497,7 @@ static int _write_lookup_file(struct cmd_context *cmd, struct volume_group *vg)
 	int fd;
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, vg->name) < 0) {
-		log_error("Path %s/%s is too long.", _pvs_lookup_dir, vg->name);
+		log_error_pvscan(cmd, "Path %s/%s is too long.", _pvs_lookup_dir, vg->name);
 		return 0;
 	}
 
@@ -639,7 +660,7 @@ static int _count_pvid_files_from_lookup_file(struct cmd_context *cmd, struct de
 	return (vgname) ? 1 : 0;
 }
 
-static void _online_dir_setup(void)
+static void _online_dir_setup(struct cmd_context *cmd)
 {
 	struct stat st;
 	int rv;
@@ -653,7 +674,7 @@ static void _online_dir_setup(void)
 	dm_prepare_selinux_context(NULL, 0);
 
 	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
-		log_error("Failed to create %s %d", DEFAULT_RUN_DIR, errno);
+		log_error_pvscan(cmd, "Failed to create %s %d", DEFAULT_RUN_DIR, errno);
 
 do_pvs:
 	if (!stat(_pvs_online_dir, &st))
@@ -665,7 +686,7 @@ do_pvs:
 	dm_prepare_selinux_context(NULL, 0);
 
 	if ((rv < 0) && stat(_pvs_online_dir, &st))
-		log_error("Failed to create %s %d", _pvs_online_dir, errno);
+		log_error_pvscan(cmd, "Failed to create %s %d", _pvs_online_dir, errno);
 
 do_vgs:
 	if (!stat(_vgs_online_dir, &st))
@@ -677,7 +698,7 @@ do_vgs:
 	dm_prepare_selinux_context(NULL, 0);
 
 	if ((rv < 0) && stat(_vgs_online_dir, &st))
-		log_error("Failed to create %s %d", _vgs_online_dir, errno);
+		log_error_pvscan(cmd, "Failed to create %s %d", _vgs_online_dir, errno);
 
 do_lookup:
 	if (!stat(_pvs_lookup_dir, &st))
@@ -689,7 +710,7 @@ do_lookup:
 	dm_prepare_selinux_context(NULL, 0);
 
 	if ((rv < 0) && stat(_pvs_lookup_dir, &st))
-		log_error("Failed to create %s %d", _pvs_lookup_dir, errno);
+		log_error_pvscan(cmd, "Failed to create %s %d", _pvs_lookup_dir, errno);
 
 
 }
@@ -728,7 +749,7 @@ static int _pvscan_aa_single(struct cmd_context *cmd, const char *vg_name,
 	log_debug("pvscan autoactivating VG %s.", vg_name);
 
 	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
-		log_error("%s: autoactivation failed.", vg->name);
+		log_error_pvscan(cmd, "%s: autoactivation failed.", vg->name);
 		pp->activate_errors++;
 	}
 
@@ -741,7 +762,7 @@ static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
 	int fd;
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
-		log_error("Path %s/%s is too long.", _vgs_online_dir, vgname);
+		log_error_pvscan(cmd, "Path %s/%s is too long.", _vgs_online_dir, vgname);
 		return 0;
 	}
 
@@ -829,15 +850,15 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
 
 		if (file_vgname[0] && strcmp(vgname, file_vgname)) {
-			log_error("Wrong VG found for %d:%d PVID %s: %s vs %s",
-				  file_major, file_minor, pvid, vgname, file_vgname);
+			log_error_pvscan(cmd, "Wrong VG found for %d:%d PVID %s: %s vs %s",
+				         file_major, file_minor, pvid, vgname, file_vgname);
 			goto bad;
 		}
 
 		devno = MKDEV(file_major, file_minor);
 
 		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
-			log_error("No device found for %d:%d PVID %s", file_major, file_minor, pvid);
+			log_error_pvscan(cmd, "No device found for %d:%d PVID %s", file_major, file_minor, pvid);
 			goto bad;
 		}
 
@@ -847,7 +868,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		if (strcmp(name1, name2)) {
 			if (!id_write_format((const struct id *)pvid, uuidstr, sizeof(uuidstr)))
 				uuidstr[0] = '\0';
-			log_print("PVID %s read from %s last written to %s.", uuidstr, name1, name2);
+			log_print_pvscan(cmd, "PVID %s read from %s last written to %s.", uuidstr, name1, name2);
 			goto bad;
 		}
 
@@ -924,7 +945,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	 * The dev_cache gives us struct devices from the devnums.
 	 */
 	if (!_get_devs_from_saved_vg(cmd, vgname, &devs)) {
-		log_print("pvscan[%d] VG %s not using quick activation.", getpid(), vgname);
+		log_print_pvscan(cmd, "VG %s not using quick activation.", vgname);
 		*no_quick = 1;
 		return ECMD_FAILED;
 	}
@@ -943,7 +964,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	 * label rescan are then disabled in vg_read.)
 	 */
 	if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL)) {
-		log_error("pvscan activation for VG %s failed to lock VG.", vgname);
+		log_error_pvscan(cmd, "activation for VG %s failed to lock VG.", vgname);
 		return ECMD_FAILED;
 	}
 
@@ -956,7 +977,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	label_scan_devs(cmd, NULL, &devs);
 
 	if (!(vgid = lvmcache_vgid_from_vgname(cmd, vgname))) {
-		log_error("pvscan activation for VG %s failed to find vgid.", vgname);
+		log_error_pvscan(cmd, "activation for VG %s failed to find vgid.", vgname);
 		return ECMD_FAILED;
 	}
 
@@ -976,7 +997,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 		 * original device arg scan.  There will be very few and unusual
 		 * cases that would be caught here.
 		 */
-		log_error("pvscan activation for VG %s cannot read (%x).", vgname, error_flags);
+		log_error_pvscan(cmd, "activation for VG %s cannot read (%x).", vgname, error_flags);
 		return ECMD_FAILED;
 	}
 
@@ -998,7 +1019,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (dev_in_device_list(pvl->pv->dev, &devs))
 			continue;
-		log_error("pvscan activation for VG %s found different devices.", vgname);
+		log_error_pvscan(cmd, "activation for VG %s found different devices.", vgname);
 		ret = ECMD_FAILED;
 		goto out;
 	}
@@ -1006,7 +1027,7 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 	log_debug("pvscan autoactivating VG %s.", vgname);
 
 	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
-		log_error("%s: autoactivation failed.", vg->name);
+		log_error_pvscan(cmd, "%s: autoactivation failed.", vg->name);
 		pp->activate_errors++;
 	}
 
@@ -1025,7 +1046,7 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 	int ret = ECMD_FAILED;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
-		log_error("Failed to initialize processing handle.");
+		log_error_pvscan(cmd, "Failed to initialize processing handle.");
 		goto out;
 	}
 
@@ -1040,11 +1061,11 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 	 */
 	dm_list_iterate_items_safe(sl, sl2, vgnames) {
 		if (!_online_vg_file_create(cmd, sl->str)) {
-			log_print("pvscan[%d] VG %s skip autoactivation.", getpid(), sl->str);
+			log_print_pvscan(cmd, "VG %s skip autoactivation.", sl->str);
 			str_list_del(vgnames, sl->str);
 			continue;
 		}
-		log_print("pvscan[%d] VG %s run autoactivation.", getpid(), sl->str);
+		log_print_pvscan(cmd, "VG %s run autoactivation.", sl->str);
 	}
 
 	if (dm_list_empty(vgnames)) {
@@ -1192,6 +1213,64 @@ static int _get_args_devs(struct cmd_context *cmd, struct dm_list *pvscan_args,
 	return 1;
 }
 
+static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group *vg)
+{
+	char path[PATH_MAX];
+	char file_vgname[NAME_LEN];
+	char pvid[ID_LEN+1] = { 0 };
+	struct pv_list *pvl;
+	struct device *dev;
+	int major, minor;
+	dev_t devno;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		memcpy(&pvid, &pvl->pv->id.uuid, ID_LEN);
+
+		if (pvl->pv->status & MISSING_PV) {
+			log_debug("set_pv_devices_online vg %s pv %s missing flag already set",
+				  vg->name, pvid);
+			continue;
+		}
+
+		if (!_online_pvid_file_exists(pvid)) {
+			log_debug("set_pv_devices_online vg %s pv %s no online file",
+				  vg->name, pvid);
+			pvl->pv->status |= MISSING_PV;
+			continue;
+		}
+
+		memset(path, 0, sizeof(path));
+		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid);
+
+		major = 0;
+		minor = 0;
+		file_vgname[0] = '\0';
+
+		_online_pvid_file_read(path, &major, &minor, file_vgname);
+
+		if (file_vgname[0] && strcmp(vg->name, file_vgname)) {
+			log_warn("WARNING: VG %s PV %s wrong vgname in online file %s",
+				  vg->name, pvid, file_vgname);
+			pvl->pv->status |= MISSING_PV;
+			continue;
+		}
+
+		devno = MKDEV(major, minor);
+
+		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
+			log_print_pvscan(cmd, "VG %s PV %s no device found for %d:%d",
+					 vg->name, pvid, major, minor);
+			pvl->pv->status |= MISSING_PV;
+			continue;
+		}
+
+		log_debug("set_pv_devices_online vg %s pv %s is online %s",
+			  vg->name, pvid, dev_name(dev));
+
+		pvl->pv->dev = dev;
+	}
+}
+
 static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvscan_devs,
 			int *pv_count, struct dm_list *complete_vgnames)
 {
@@ -1204,15 +1283,20 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 	struct metadata_area *mda1, *mda2;
 	struct volume_group *vg;
 	struct physical_volume *pv;
-	const char *vgname;
-	uint32_t ext_version, ext_flags;
+	const char *vgname = NULL;
 	uint64_t devsize;
+	uint32_t ext_version, ext_flags;
+	int do_cache = arg_is_set(cmd, cache_long_ARG);
 	int do_activate = arg_is_set(cmd, activate_ARG);
-	int do_full_check;
+	int do_list_lvs = arg_is_set(cmd, listlvs_ARG);
+	int do_list_vg = arg_is_set(cmd, listvg_ARG);
+	int do_check_complete = arg_is_set(cmd, checkcomplete_ARG);
+	int do_vgonline = arg_is_set(cmd, vgonline_ARG);
 	int pvs_online;
 	int pvs_offline;
 	int pvs_unknown;
 	int vg_complete;
+	int do_full_check;
 	int ret = 1;
 
 	dm_list_iterate_items_safe(devl, devl2, pvscan_devs) {
@@ -1222,14 +1306,14 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 
 		if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
 			if (!do_all)
-				log_print("pvscan[%d] ignore %s with no lvm info.", getpid(), dev_name(dev));
+				log_print_pvscan(cmd, "ignore %s with no lvm info.", dev_name(dev));
 			continue;
 		}
 
 		ext_version = lvmcache_ext_version(info);
 		ext_flags = lvmcache_ext_flags(info);
 		if ((ext_version >= 2) && !(ext_flags & PV_EXT_USED)) {
-			log_print("pvscan[%d] PV %s not used.", getpid(), dev_name(dev));
+			log_print_pvscan(cmd, "PV %s not used.", dev_name(dev));
 			(*pv_count)++;
 			continue;
 		}
@@ -1253,7 +1337,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 			vg = mda2->ops->vg_read(cmd, fid, "", mda2, NULL, NULL);
 
 		if (!vg) {
-			log_print("pvscan[%d] PV %s has no VG metadata.", getpid(), dev_name(dev));
+			log_print_pvscan(cmd, "PV %s has no VG metadata.", dev_name(dev));
 			if (fid)
 				fmt->ops->destroy_instance(fid);
 			goto online;
@@ -1262,7 +1346,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		set_pv_devices(fid, vg);
 
 		if (!(pv = find_pv(vg, dev))) {
-			log_print("pvscan[%d] PV %s not found in VG %s.", getpid(), dev_name(dev), vg->name);
+			log_print_pvscan(cmd, "PV %s not found in VG %s.", dev_name(dev), vg->name);
 			release_vg(vg);
 			continue;
 		}
@@ -1283,14 +1367,15 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 			if (pv->device_hint && !strncmp(pv->device_hint, "/dev/md", 7))
 				do_full_check = 1;
 		}
+
 		if (do_full_check && dev_is_md_component(cmd, dev, NULL, 1)) {
-			log_print("pvscan[%d] ignore md component %s.", getpid(), dev_name(dev));
+			log_print_pvscan(cmd, "ignore md component %s.", dev_name(dev));
 			release_vg(vg);
 			continue;
 		}
 
 		if (vg_is_shared(vg)) {
-			log_print("pvscan[%d] PV %s ignore shared VG.", getpid(), dev_name(dev));
+			log_print_pvscan(cmd, "PV %s ignore shared VG.", dev_name(dev));
 			release_vg(vg);
 			continue;
 		}
@@ -1300,7 +1385,13 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		    vg_is_foreign(vg)) {
 			log_verbose("Ignore PV %s with VG system id %s with our system id %s",
 				    dev_name(dev), vg->system_id, cmd->system_id);
-			log_print("pvscan[%d] PV %s ignore foreign VG.", getpid(), dev_name(dev));
+			log_print_pvscan(cmd, "PV %s ignore foreign VG.", dev_name(dev));
+			release_vg(vg);
+			continue;
+		}
+
+		if (vg_is_exported(vg)) {
+			log_print_pvscan(cmd, "PV %s ignore exported VG.", dev_name(dev));
 			release_vg(vg);
 			continue;
 		}
@@ -1319,19 +1410,20 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 
 		/*
 		 * Create file named for pvid to record this PV is online.
+		 * The command creates/checks online files only when --cache is used.
 		 */
-		if (!_online_pvid_file_create(dev, vg ? vg->name : NULL)) {
-			log_error("pvscan[%d] PV %s failed to create online file.", getpid(), dev_name(dev));
+		if (do_cache && !_online_pvid_file_create(cmd, dev, vg ? vg->name : NULL)) {
+			log_error_pvscan(cmd, "PV %s failed to create online file.", dev_name(dev));
 			release_vg(vg);
 			ret = 0;
 			continue;
 		}
 
 		/*
-		 * When not activating we don't need to know about vg completeness.
+		 * A plain pvscan --cache <dev> just creates the online file.
 		 */
-		if (!do_activate) {
-			log_print("pvscan[%d] PV %s online.", getpid(), dev_name(dev));
+		if (!do_activate && !do_list_lvs && !do_list_vg) {
+			log_print_pvscan(cmd, "PV %s online.", dev_name(dev));
 			release_vg(vg);
 			continue;
 		}
@@ -1339,58 +1431,159 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		/*
 		 * Check if all the PVs for this VG are online.  If the arrival
 		 * of this dev completes the VG, then save the vgname in
-		 * complete_vgnames so it will be activated.
+		 * complete_vgnames (activation phase will want to know which
+		 * VGs to activate.)
 		 */
-		pvs_online = 0;
-		pvs_offline = 0;
-		pvs_unknown = 0;
-		vg_complete = 0;
-
-		if (vg) {
-			/*
-			 * Use the VG metadata from this PV for a list of all
-			 * PVIDs.  Write a lookup file of PVIDs in case another
-			 * pvscan needs it.  After writing lookup file, recheck
-			 * pvid files to resolve a possible race with another
-			 * pvscan reading the lookup file that missed it.
-			 */
-			log_debug("checking all pvid files from vg %s", vg->name);
-			_count_pvid_files(vg, &pvs_online, &pvs_offline);
+		if (do_activate || do_check_complete) {
+			pvs_online = 0;
+			pvs_offline = 0;
+			pvs_unknown = 0;
+			vg_complete = 0;
 
-			if (pvs_offline && _write_lookup_file(cmd, vg)) {
-				log_debug("rechecking all pvid files from vg %s", vg->name);
+			if (vg) {
+				/*
+				 * Use the VG metadata from this PV for a list of all
+				 * PVIDs.  Write a lookup file of PVIDs in case another
+				 * pvscan needs it.  After writing lookup file, recheck
+				 * pvid files to resolve a possible race with another
+				 * pvscan reading the lookup file that missed it.
+				 */
+				log_debug("checking all pvid files from vg %s", vg->name);
 				_count_pvid_files(vg, &pvs_online, &pvs_offline);
-				if (!pvs_offline)
-					log_print("pvscan[%d] VG %s complete after recheck.", getpid(), vg->name);
+	
+				if (pvs_offline && _write_lookup_file(cmd, vg)) {
+					log_debug("rechecking all pvid files from vg %s", vg->name);
+					_count_pvid_files(vg, &pvs_online, &pvs_offline);
+					if (!pvs_offline)
+						log_print_pvscan(cmd, "VG %s complete after recheck.", vg->name);
+				}
+	
+				vgname = vg->name;
+			} else {
+				/*
+				 * No VG metadata on this PV, so try to use a lookup
+				 * file written by a prior pvscan for a list of all
+				 * PVIDs.  A lookup file may not exist for this PV if
+				 * it's the first to appear from the VG.
+				 */
+				log_debug("checking all pvid files from lookup file");
+				if (!_count_pvid_files_from_lookup_file(cmd, dev, &pvs_online, &pvs_offline, &vgname))
+					pvs_unknown = 1;
+			}
+	
+			if (pvs_unknown) {
+				log_print_pvscan(cmd, "PV %s online, VG unknown.", dev_name(dev));
+				vg_complete = 0;
+	
+			} else if (pvs_offline) {
+				log_print_pvscan(cmd, "PV %s online, VG %s incomplete (need %d).",
+						 dev_name(dev), vgname, pvs_offline);
+				vg_complete = 0;
+	
+			} else {
+				log_print_pvscan(cmd, "PV %s online, VG %s is complete.", dev_name(dev), vgname);
+				if (!str_list_add(cmd->mem, complete_vgnames, dm_pool_strdup(cmd->mem, vgname)))
+					stack;
+				vg_complete = 1;
 			}
+		}
 
+		if (!vgname && vg)
 			vgname = vg->name;
-		} else {
+
+		if (do_list_vg || do_list_lvs) {
+			if (!vgname) {
+				log_print("VG unknown");
+			} else if (!do_check_complete) {
+				log_print("VG %s", vgname);
+			} else if (vg_complete) {
+				if (do_vgonline && !_online_vg_file_create(cmd, vgname)) {
+					log_print("VG %s finished", vgname);
+				} else {
+					/*
+					 * A udev rule imports KEY=val from a program's stdout.
+					 * Other output causes udev to ignore everything.
+					 * Run pvscan from udev rule using --udevoutput to
+					 * enable this printf, and suppress all log output
+					 */
+					if (arg_is_set(cmd, udevoutput_ARG))
+						printf("LVM_VG_NAME_COMPLETE='%s'\n", vgname);
+					else
+						log_print("VG %s complete", vgname);
+				}
+			} else {
+				if (arg_is_set(cmd, udevoutput_ARG))
+					printf("LVM_VG_NAME_INCOMPLETE='%s'\n", vgname);
+				else
+					log_print("VG %s incomplete", vgname);
+			}
+
 			/*
-			 * No VG metadata on this PV, so try to use a lookup
-			 * file written by a prior pvscan for a list of all
-			 * PVIDs.  A lookup file may not exist for this PV if
-			 * it's the first to appear from the VG.
+			 * When the VG is complete|finished, we could print
+			 * a list of devices in the VG, by reading the pvid files
+			 * that were counted, which provides major:minor of each
+			 * device and using that to get the struct dev and dev_name.
+			 * The user could pass this list of devices to --devices
+			 * to optimize a subsequent command (activation) on the VG.
+			 * Just call set_pv_devices_online (if not done othewise)
+			 * since that finds the devs.
 			 */
-			log_debug("checking all pvid files from lookup file");
-			if (!_count_pvid_files_from_lookup_file(cmd, dev, &pvs_online, &pvs_offline, &vgname))
-				pvs_unknown = 1;
 		}
 
-		if (pvs_unknown) {
-			log_print("pvscan[%d] PV %s online, VG unknown.",
-				  getpid(), dev_name(dev));
-		} else if (pvs_offline) {
-			log_print("pvscan[%d] PV %s online, VG %s incomplete (need %d).",
-				  getpid(), dev_name(dev), vgname, pvs_offline);
-		} else {
-			log_print("pvscan[%d] PV %s online, VG %s is complete.", getpid(), dev_name(dev), vgname);
-			if (!str_list_add(cmd->mem, complete_vgnames, dm_pool_strdup(cmd->mem, vgname)))
-				stack;
-			vg_complete = 1;
+		if (do_list_lvs && !vg) {
+			/* require all PVs used for booting have metadata */
+			log_print_pvscan(cmd, "Cannot list LVs from device without metadata.");
+		}
+
+		if (do_list_lvs && vg) {
+			struct dm_list lvs_list;
+			struct lv_list *lvl;
+
+			dm_list_init(&lvs_list);
+
+			/*
+			 * For each vg->pvs entry, get the dev based on the online file
+			 * for the pvid and set pv->dev or pv->status MISSING_PV.
+			 */
+			_set_pv_devices_online(cmd, vg);
+
+			/*
+			 * lvs_list are LVs that use dev.
+			 */
+			if (!get_visible_lvs_using_pv(cmd, vg, dev, &lvs_list))
+				log_print_pvscan(cmd, "Failed to find LVs using %s.", dev_name(dev));
+
+			if (!do_check_complete) {
+				dm_list_iterate_items(lvl, &lvs_list)
+					log_print("LV %s", display_lvname(lvl->lv));
+			} else if (vg_complete) {
+				/*
+				 * A shortcut; the vg complete implies all lvs are complete.
+				 */
+				dm_list_iterate_items(lvl, &lvs_list)
+					log_print("LV %s complete", display_lvname(lvl->lv));
+			} else {
+				/*
+				 * For each LV in VG, check if all devs are present.
+				 * Sets the PARTIAL flag on LVs that are not complete.
+				 */
+				if (!vg_mark_partial_lvs(vg, 1))
+					log_print_pvscan(cmd, "Failed to check partial lvs.");
+
+				dm_list_iterate_items(lvl, &lvs_list) {
+					if (!lv_is_partial(lvl->lv))
+						log_print("LV %s complete", display_lvname(lvl->lv));
+					else
+						log_print("LV %s incomplete", display_lvname(lvl->lv));
+				}
+			}
 		}
 
-		if (!saved_vg && vg && vg_complete && !do_all && (dm_list_size(pvscan_devs) == 1))
+		/*
+		 * When "pvscan --cache -aay <dev>" completes the vg, save the
+		 * struct vg to use for quick activation function.
+		 */
+		if (do_activate && !saved_vg && vg && vg_complete && !do_all && (dm_list_size(pvscan_devs) == 1))
 			saved_vg = vg;
 		else
 			release_vg(vg);
@@ -1484,7 +1677,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 * Specific devs must be matched later with device_ids_match_dev().
 	 */
 	if (!setup_devices_no_file_match(cmd)) {
-		log_error("Failed to set up devices.");
+		log_error_pvscan(cmd, "Failed to set up devices.");
 		return 0;
 	}
 
@@ -1563,8 +1756,8 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print("pvscan[%d] %s excluded by filters: %s.", getpid(),
-				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			log_print_pvscan(cmd, "%s excluded by filters: %s.",
+					 dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 		}
 	}
@@ -1600,7 +1793,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 		if (!has_pvid) {
 			/* Not an lvm device */
-			log_print("pvscan[%d] %s not an lvm device.", getpid(), dev_name(devl->dev));
+			log_print_pvscan(cmd, "%s not an lvm device.", dev_name(devl->dev));
 			dm_list_del(&devl->list);
 			continue;
 		}
@@ -1611,8 +1804,8 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 		 */
 		if (relax_deviceid_filter) {
 			if (!get_du_for_pvid(cmd, devl->dev->pvid)) {
-				log_print("pvscan[%d] %s excluded by devices file (checking PVID).",
-					  getpid(), dev_name(devl->dev));
+				log_print_pvscan(cmd, "%s excluded by devices file (checking PVID).",
+					         dev_name(devl->dev));
 				dm_list_del(&devl->list);
 				continue;
 			}
@@ -1620,8 +1813,8 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 		/* Applies all filters, including those that need data from dev. */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
-			log_print("pvscan[%d] %s excluded by filters: %s.", getpid(),
-				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			log_print_pvscan(cmd, "%s excluded by filters: %s.",
+					 dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
 		}
 	}
@@ -1685,6 +1878,37 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
+	/*
+	 * lvm udev rules call:
+	 *   pvscan --cache --listvg|--listlvs --checkcomplete PV
+	 * when PVs appear, even if event_activation=0 in lvm.conf.
+	 *
+	 * The udev rules will do autoactivation if they see complete
+	 * VGs/LVs reported from the pvscan.
+	 *
+	 * When event_activation=0 we do not want to do autoactivation
+	 * from udev events, so we need the pvscan to not report any
+	 * complete VGs/LVs when event_activation=0 so that the udev
+	 * rules do not attempt to autoactivate.
+	 */
+
+	if (arg_is_set(cmd, checkcomplete_ARG) && !event_activation) {
+		if (arg_is_set(cmd, udevoutput_ARG))
+			printf("LVM_EVENT_ACTIVATION=0\n");
+		else
+			log_print_pvscan(cmd, "Ignoring pvscan with --checkcomplete because event_activation is disabled.");
+		return ECMD_PROCESSED;
+	}
+
+	/*
+	 * If obtain_device_list_from_udev was set to 1, force it to 0.
+	 * Don't ask udev for info since pvscan is running from udev.
+	 * If a pvscan attempts to get dev info from udev, udev can
+	 * repeatedly return errors about the dev not being initialized
+	 * which will stall the pvscan.
+	 */
+	init_obtain_device_list_from_udev(0);
+
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
 
@@ -1695,13 +1919,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	do_all = !argc && !devno_args;
 
-	_online_dir_setup();
+	_online_dir_setup(cmd);
 
 	if (do_all) {
 		if (!_pvscan_cache_all(cmd, argc, argv, &complete_vgnames))
 			return ECMD_FAILED;
 	} else {
-		if (!event_activation) {
+		if (!arg_is_set(cmd, checkcomplete_ARG) && !event_activation) {
 			/* Avoid doing anything for device removal: pvscan --cache <devno> */
 			log_verbose("Ignoring pvscan --cache because event_activation is disabled.");
 			return ECMD_PROCESSED;
diff --git a/tools/toollib.c b/tools/toollib.c
index 357c9f8b8..3682dfa0a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -813,6 +813,24 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		lv_clear_integrity_recalculate_metadata(lv);
 	}
 
+	/*
+	 * When LVs are deactivated, then autoactivation of the VG is
+	 * "re-armed" by removing the vg online file.  So, after deactivation
+	 * of LVs, if PVs are disconnected and reconnected again, event
+	 * activation will trigger autoactivation again.  This secondary
+	 * autoactivation is somewhat different from, and not as important as
+	 * the initial autoactivation during system startup.  The secondary
+	 * autoactivation will happen to a VG on a running system and may be
+	 * mixing with user commands, so the end result is unpredictable.
+	 *
+	 * It's possible that we might want a config setting for usersto  
+	 * disable secondary autoactivations.  Once a system is up, the
+	 * user may want to take charge of activation changes to the VG
+	 * and not have the system autoactivation interfere.
+	 */
+	if (!is_change_activating(activate) && find_config_tree_bool(cmd, global_event_activation_CFG, NULL))
+		online_vg_file_remove(lv->vg->name);
+
 	set_lv_notify(lv->vg->cmd);
 
 	return r;
diff --git a/tools/tools.h b/tools/tools.h
index 708a78d1c..bc98fcb09 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -295,4 +295,6 @@ int lvconvert_cachevol_attach_single(struct cmd_context *cmd,
                                      struct logical_volume *lv,
                                      struct processing_handle *handle);
 
+void online_vg_file_remove(const char *vgname);
+
 #endif


