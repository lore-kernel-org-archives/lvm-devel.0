From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 25 Aug 2012 19:39:25 +0000 (UTC)
Subject: master - config: add silent mode
Message-ID: <20120825193925.D91B723A9@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=438e0050dfed1f8f2d74670a5f7c5e8c8819c777
Commit:        438e0050dfed1f8f2d74670a5f7c5e8c8819c777
Parent:        4047e4dfb16175daec348bf44032c02181bd4c70
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Aug 25 20:35:48 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Aug 25 20:35:48 2012 +0100

config: add silent mode

Accept -q as the short form of --quiet.
Suppress non-essential standard output if -q is given twice.
Treat log/silent in lvm.conf as equivalent to -qq.
Review all log_print messages and change some to
log_print_unless_silent.

When silent, the following commands still produce output:
dumpconfig, lvdisplay, lvmdiskscan, lvs, pvck, pvdisplay,
pvs, version, vgcfgrestore -l, vgdisplay, vgs.
[Needs checking.]

Non-essential messages are shifted from log level 4 to log level 5
for syslog and lvm2_log_fn purposes.
---
 WHATS_NEW                  |    6 ++++-
 doc/example.conf.in        |    9 +++++++
 lib/cache/lvmetad.c        |    2 +-
 lib/commands/toolcontext.c |    5 ++++
 lib/commands/toolcontext.h |    1 +
 lib/config/defaults.h      |    1 +
 lib/display/display.c      |    2 +-
 lib/log/log.h              |    1 +
 lib/metadata/lv_manip.c    |   14 +++++-----
 lib/metadata/metadata.c    |   10 ++++----
 lib/metadata/mirror.c      |    4 +-
 lib/metadata/raid_manip.c  |   13 ++++-----
 lib/misc/lvm-globals.c     |   13 +++++++++-
 lib/misc/lvm-globals.h     |    2 +
 man/lvm.8.in               |    2 +-
 man/lvm.conf.5.in          |    6 ++++
 tools/args.h               |    2 +-
 tools/lvchange.c           |    2 +-
 tools/lvconvert.c          |   30 +++++++++++-----------
 tools/lvcreate.c           |    6 ++--
 tools/lvm.c                |    1 +
 tools/lvmcmdline.c         |    6 ++++-
 tools/lvrename.c           |    4 +-
 tools/lvresize.c           |   40 +++++++++++++++---------------
 tools/lvscan.c             |    8 +++---
 tools/polldaemon.c         |    8 +++---
 tools/pvchange.c           |   10 ++++----
 tools/pvmove.c             |   16 ++++++------
 tools/pvremove.c           |    4 +-
 tools/pvresize.c           |    6 ++--
 tools/pvscan.c             |   58 +++++++++++++++++++------------------------
 tools/toollib.c            |    4 +-
 tools/vgcfgbackup.c        |    2 +-
 tools/vgcfgrestore.c       |    2 +-
 tools/vgchange.c           |   18 +++++++-------
 tools/vgconvert.c          |    2 +-
 tools/vgcreate.c           |    4 +-
 tools/vgexport.c           |    2 +-
 tools/vgextend.c           |    2 +-
 tools/vgimport.c           |    2 +-
 tools/vgmerge.c            |    4 +-
 tools/vgreduce.c           |    6 ++--
 tools/vgrename.c           |    4 +-
 tools/vgscan.c             |    8 +++---
 tools/vgsplit.c            |    6 ++--
 45 files changed, 198 insertions(+), 160 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7d5f54..7d070f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
-Version 2.02.98
+Version 2.02.98 -
 =================================
+  Add log/silent to lvm.conf equivalent to -qq.
+  Suppress non-essential stdout with -qq.
+  Switch non-essential log_print messages to log_print_unless_silent.
+  Use -q as short form of --quiet.
   Add RAID10 support.
   Reuse _reload_lv() in more lvconvert functions.
   Fix dereference of NULL in lvmetad error path logging.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 576397b..479b74b 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -234,6 +234,15 @@ log {
     # There are three levels of verbosity, 3 being the most verbose.
     verbose = 0
 
+    # Set to 1 to suppress all non-essential messages from stdout.
+    # This has the same effect as -qq.
+    # When this is set, the following commands still produce output:
+    # dumpconfig, lvdisplay, lvmdiskscan, lvs, pvck, pvdisplay, 
+    # pvs, version, vgcfgrestore -l, vgdisplay, vgs.
+    # Non-essential messages are shifted from log level 4 to log level 5
+    # for syslog and lvm2_log_fn purposes.
+    silent = 0
+
     # Should we send log messages through syslog?
     # 1 is yes; 0 is no.
     syslog = 1
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6e1759b..feab361 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -710,7 +710,7 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
 	}
 
 	if (!label_read(dev, &label, 0)) {
-		log_print("No PV label found on %s.", dev_name(dev));
+		log_print_unless_silent("No PV label found on %s.", dev_name(dev));
 		if (!lvmetad_pv_gone_by_dev(dev, handler))
 			goto_bad;
 		return 1;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 529bd51..57667b6 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -144,6 +144,11 @@ static void _init_logging(struct cmd_context *cmd)
 	    find_config_tree_int(cmd, "log/level", DEFAULT_LOGLEVEL);
 	init_debug(cmd->default_settings.debug);
 
+	/* Suppress all non-essential stdout? */
+	cmd->default_settings.silent = 
+	    find_config_tree_int(cmd, "log/silent", DEFAULT_SILENT);
+	init_silent(cmd->default_settings.silent);
+
 	/* Verbose level for tty output */
 	cmd->default_settings.verbose =
 	    find_config_tree_int(cmd, "log/verbose", DEFAULT_VERBOSE);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 6fba686..e0ef041 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -27,6 +27,7 @@
 struct config_info {
 	int debug;
 	int verbose;
+	int silent;
 	int test;
 	int syslog;
 	int activation;
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index bee3d56..9730a2d 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -111,6 +111,7 @@
 
 #define DEFAULT_SYSLOG 1
 #define DEFAULT_VERBOSE 0
+#define DEFAULT_SILENT 0
 #define DEFAULT_LOGLEVEL 0
 #define DEFAULT_INDENT 1
 #define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
diff --git a/lib/display/display.c b/lib/display/display.c
index 8ceb449..2422b51 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -935,7 +935,7 @@ char yes_no_prompt(const char *prompt, ...)
 	sigint_restore();
 
 	if (c != '\n')
-		printf("\n");
+		fprintf(stderr, "\n");
 
 	return ret;
 }
diff --git a/lib/log/log.h b/lib/log/log.h
index 0071a33..f0da64f 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -68,6 +68,7 @@
 #define log_very_verbose(args...) log_info(args)
 #define log_verbose(args...) log_notice(args)
 #define log_print(args...) LOG_LINE(_LOG_WARN, args)
+#define log_print_unless_silent(args...) LOG_LINE(silent_mode() ? _LOG_NOTICE : _LOG_WARN, args)
 #define log_error(args...) log_err(args)
 #define log_error_suppress(s, args...) log_err_suppress(s, args)
 #define log_error_once(args...) log_err_once(args)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 59e1429..d591b7b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2152,8 +2152,8 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 			size = ((uint64_t)lv->vg->extent_size * extents + size - 1) /
 				size * size / lv->vg->extent_size;
 			if (size != extents) {
-				log_print("Rounding size (%d extents) up to chunk boundary "
-					  "size (%d extents).", extents, size);
+				log_print_unless_silent("Rounding size (%d extents) up to chunk boundary "
+							"size (%d extents).", extents, size);
 				extents = size;
 			}
 		}
@@ -2738,7 +2738,7 @@ int lv_extend(struct logical_volume *lv,
 			percent_t sync_percent = PERCENT_INVALID;
 
 			if (!lv_is_active(lv)) {
-				log_print("%s/%s is not active."
+				log_error("%s/%s is not active."
 					  "  Unable to get sync percent.",
 					  lv->vg->name, lv->name);
 				if (yes_no_prompt("Do full resync of extended "
@@ -3378,7 +3378,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	backup(vg);
 
 	if (visible)
-		log_print("Logical volume \"%s\" successfully removed", lv->name);
+		log_print_unless_silent("Logical volume \"%s\" successfully removed", lv->name);
 
 	return 1;
 }
@@ -4207,8 +4207,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	}
 
 	if ((size_rest = lp->extents % lp->stripes)) {
-		log_print("Rounding size (%d extents) up to stripe boundary "
-			  "size (%d extents)", lp->extents,
+		log_print_unless_silent("Rounding size (%d extents) up to stripe boundary "
+					"size (%d extents)", lp->extents,
 			  lp->extents - size_rest + lp->stripes);
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
@@ -4650,7 +4650,7 @@ int lv_create_single(struct volume_group *vg,
 		return_0;
 
 out:
-	log_print("Logical volume \"%s\" created", lv->name);
+	log_print_unless_silent("Logical volume \"%s\" created", lv->name);
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 205f77e..220e0c1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -623,7 +623,7 @@ int vg_remove(struct volume_group *vg)
 		stack;
 
 	if (ret)
-		log_print("Volume group \"%s\" successfully removed", vg->name);
+		log_print_unless_silent("Volume group \"%s\" successfully removed", vg->name);
 	else
 		log_error("Volume group \"%s\" not properly removed", vg->name);
 
@@ -988,8 +988,8 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 {
 	if (size % extent_size) {
 		size += extent_size - size % extent_size;
-		log_print("Rounding up size to full physical extent %s",
-			  display_size(cmd, size));
+		log_print_unless_silent("Rounding up size to full physical extent %s",
+			  		display_size(cmd, size));
 	}
 
 	if (size > (uint64_t) MAX_EXTENT_COUNT * extent_size) {
@@ -1305,7 +1305,7 @@ static int _wipe_sb(struct device *dev, const char *type, const char *name,
 		return 0;
 	}
 
-	log_print("Wiping %s on %s.", type, name);
+	log_print_unless_silent("Wiping %s on %s.", type, name);
 	if (!dev_set(dev, superblock, wipe_len, 0)) {
 		log_error("Failed to wipe %s on %s.", type, name);
 		return 0;
@@ -1477,7 +1477,7 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_create *pvc)
 		return 0;
 	}
 
-	log_print("Physical volume \"%s\" successfully created", pv_name);
+	log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);
 	return 1;
 }
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index e3662c1..c4683df 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -168,8 +168,8 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;
-		log_print("Using reduced mirror region size of %" PRIu32
-			  " sectors", region_size);
+		log_print_unless_silent("Using reduced mirror region size of %" PRIu32
+					" sectors", region_size);
 	}
 
 	return region_size;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0d4640f..1188891 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1311,8 +1311,8 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return 0;
 	}
 
-	log_print("%s split from %s for read-only purposes.",
-		  seg_lv(seg, s)->name, lv->name);
+	log_print_unless_silent("%s split from %s for read-only purposes.",
+				seg_lv(seg, s)->name, lv->name);
 
 	/* Resume original LV */
 	if (!resume_lv(lv->vg->cmd, lv)) {
@@ -1325,8 +1325,8 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	if (!_activate_sublv_preserving_excl(lv, seg_lv(seg, s)))
 		return 0;
 
-	log_print("Use 'lvconvert --merge %s/%s' to merge back into %s",
-		  lv->vg->name, seg_lv(seg, s)->name, lv->name);
+	log_print_unless_silent("Use 'lvconvert --merge %s/%s' to merge back into %s",
+				lv->vg->name, seg_lv(seg, s)->name, lv->name);
 	return 1;
 }
 
@@ -1410,9 +1410,8 @@ int lv_raid_merge(struct logical_volume *image_lv)
 		return 0;
 	}
 
-	log_print("%s/%s successfully merged back into %s/%s",
-		  vg->name, image_lv->name,
-		  vg->name, lv->name);
+	log_print_unless_silent("%s/%s successfully merged back into %s/%s",
+				vg->name, image_lv->name, vg->name, lv->name);
 	return 1;
 }
 
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 1c72f85..fe38008 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -23,6 +23,7 @@
 #include <stdarg.h>
 
 static int _verbose_level = VERBOSE_BASE_LEVEL;
+static int _silent = 0;
 static int _test = 0;
 static int _md_filtering = 0;
 static int _pvmove = 0;
@@ -54,10 +55,15 @@ void init_verbose(int level)
 	_verbose_level = level;
 }
 
+void init_silent(int silent)
+{
+	_silent = silent;
+}
+
 void init_test(int level)
 {
 	if (!_test && level)
-		log_print("Test mode: Metadata will NOT be updated and volumes will not be (de)activated.");
+		log_warn("TEST MODE: Metadata will NOT be updated and volumes will not be (de)activated.");
 	_test = level;
 }
 
@@ -267,6 +273,11 @@ int debug_level(void)
 	return _debug_level;
 }
 
+int silent_mode(void)
+{
+	return _silent;
+}
+
 unsigned is_static(void)
 {
 	return _is_static;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 3ffdec4..7fe3288 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -21,6 +21,7 @@
 #define PV_MIN_SIZE_KB 512
 
 void init_verbose(int level);
+void init_silent(int silent);
 void init_test(int level);
 void init_md_filtering(int level);
 void init_pvmove(int level);
@@ -55,6 +56,7 @@ int full_scan_done(void);
 int obtain_device_list_from_udev(void);
 int trust_cache(void);
 int verbose_level(void);
+int silent_mode(void);
 int debug_level(void);
 int ignorelockingfailure(void);
 int lockingfailed(void);
diff --git a/man/lvm.8.in b/man/lvm.8.in
index a2108ed..2ce0065 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -165,7 +165,7 @@ Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
 Overrides config file setting.
 .TP
-.B \-\-quiet
+.BR \-q ", "  \-\-quiet
 Suppress output and log messages.
 Overrides \fB\-d\fP and \fB\-v\fP.
 .TP
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 47ee9f1..79044fc 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -226,6 +226,12 @@ is invoked.  By default tools append messages to the log file.
 \fBverbose\fP \(em Default level (0-3) of messages sent to stdout or stderr.
 3 is the most verbose; 0 should produce the least output.
 .IP
+\fBsilent\fP \(em Set to 1 to suppress all non-essential tool output.
+When set, display and reporting tools will still write the requested
+device properties to standard output, but messages confirming that
+something was or wasn't changed will be reduced to the 'verbose' level
+and not appear unless -v is supplied.
+.IP
 \fBsyslog\fP \(em Set to 1 (the default) to send log messages through syslog.
 Turn off by setting to 0.  If you set to an integer greater than one,
 this is used - unvalidated - as the facility.  The default is LOG_USER.
diff --git a/tools/args.h b/tools/args.h
index 796fc51..d436db4 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -18,7 +18,6 @@
  */
 /* *INDENT-OFF* */
 arg(version_ARG, '\0', "version", NULL, 0)
-arg(quiet_ARG, '\0', "quiet", NULL, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
@@ -131,6 +130,7 @@ arg(permission_ARG, 'p', "permission", permission_arg, 0)
 arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0)
 arg(partial_ARG, 'P', "partial", NULL, 0)
 arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0)
+arg(quiet_ARG, 'q', "quiet", NULL, ARG_COUNTABLE)
 arg(readahead_ARG, 'r', "readahead", readahead_arg, 0)
 arg(resizefs_ARG, 'r', "resizefs", NULL, 0)
 arg(reset_ARG, 'R', "reset", NULL, 0)
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 73a37fd..1f32d5c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -784,7 +784,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (doit)
-		log_print("Logical volume \"%s\" changed", lv->name);
+		log_print_unless_silent("Logical volume \"%s\" changed", lv->name);
 
 	if (arg_count(cmd, resync_ARG))
 		if (!lvchange_resync(cmd, lv)) {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2bfde24..ddda2f1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -548,7 +548,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 	if (!(_reload_lv(cmd, vg, lv)))
 		return_0;
 
-	log_print("Logical volume %s converted.", lv->name);
+	log_print_unless_silent("Logical volume %s converted.", lv->name);
 
 	return 1;
 }
@@ -564,7 +564,7 @@ static int _finish_lvconvert_merge(struct cmd_context *cmd,
 		return 0;
 	}
 
-	log_print("Merge of snapshot into logical volume %s has finished.", lv->name);
+	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.", lv->name);
 	if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT)) {
 		log_error("Could not remove snapshot %s merged into %s.",
 			  snap_seg->cow->name, lv->name);
@@ -593,8 +593,8 @@ static progress_t _poll_merge_progress(struct cmd_context *cmd,
 	}
 
 	if (parms->progress_display)
-		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title,
-			  100.0 - percent_to_float(percent));
+		log_print_unless_silent("%s: %s: %.1f%%", lv->name, parms->progress_title,
+					100.0 - percent_to_float(percent));
 	else
 		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
 			    100.0 - percent_to_float(percent));
@@ -1511,7 +1511,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 
 	if (!lp->need_polling)
-		log_print("Logical volume %s converted.", lv->name);
+		log_print_unless_silent("Logical volume %s converted.", lv->name);
 
 	backup(lv->vg);
 	return 1;
@@ -1638,8 +1638,8 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 				return 0;
 			}
 
-			log_print("Faulty devices in %s/%s successfully"
-				  " replaced.", lv->vg->name, lv->name);
+			log_print_unless_silent("Faulty devices in %s/%s successfully"
+						" replaced.", lv->vg->name, lv->name);
 			return 1;
 		}
 
@@ -1703,7 +1703,7 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	if (!_reload_lv(cmd, lv->vg, lv))
 		return_0;
 
-	log_print("Logical volume %s converted to snapshot.", lv->name);
+	log_print_unless_silent("Logical volume %s converted to snapshot.", lv->name);
 
 	return 1;
 }
@@ -1747,7 +1747,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	}
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (info.open_count) {
-			log_print("Can't merge when snapshot is open");
+			log_print_unless_silent("Can't merge when snapshot is open");
 			merge_on_activate = 1;
 		}
 	}
@@ -1763,8 +1763,8 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		if (!vg_commit(lv->vg))
 			return_0;
 		r = 1;
-		log_print("Merging of snapshot %s will start "
-			  "next activation.", lv->name);
+		log_print_unless_silent("Merging of snapshot %s will start "
+					"next activation.", lv->name);
 		goto out;
 	}
 
@@ -1790,7 +1790,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	lp->lv_to_poll = origin;
 
 	r = 1;
-	log_print("Merging of volume %s started.", lv->name);
+	log_print_unless_silent("Merging of volume %s started.", lv->name);
 out:
 	backup(lv->vg);
 	return r;
@@ -1892,8 +1892,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 		return_0;
 
-	log_print("Converted %s/%s to thin pool.",
-		  pool_lv->vg->name, pool_lv->name);
+	log_print_unless_silent("Converted %s/%s to thin pool.",
+				pool_lv->vg->name, pool_lv->name);
 	if (was_active && !activate_lv(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s/%s.",
 			  pool_lv->vg->name, pool_lv->name);
@@ -2065,7 +2065,7 @@ static int poll_logical_volume(struct cmd_context *cmd, struct logical_volume *l
 	struct lvinfo info;
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
-		log_print("Conversion starts after activation.");
+		log_print_unless_silent("Conversion starts after activation.");
 		return ECMD_PROCESSED;
 	}
 	return lvconvert_poll(cmd, lv, wait_completion ? 0 : 1U);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index aac8c22..45a117f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -301,8 +301,8 @@ static int _update_extents_params(struct volume_group *vg,
 	if ((lcp->percent != PERCENT_NONE) && lp->stripes &&
 	    (size_rest = lp->extents % (lp->stripes * stripesize_extents)) &&
 	    (vg->free_count < lp->extents - size_rest + (lp->stripes * stripesize_extents))) {
-		log_print("Rounding size (%d extents) down to stripe boundary "
-			  "size (%d extents)", lp->extents,
+		log_print_unless_silent("Rounding size (%d extents) down to stripe boundary "
+					"size (%d extents)", lp->extents,
 			  lp->extents - size_rest);
 		lp->extents = lp->extents - size_rest;
 	}
@@ -750,7 +750,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 				log_error("--mirrors must be at least 1 with segment type %s.", lp->segtype->name);
 				return 0;
 			}
-			log_print("Redundant mirrors argument: default is 0");
+			log_print_unless_silent("Redundant mirrors argument: default is 0");
 		}
 
 		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, "raid10")) {
diff --git a/tools/lvm.c b/tools/lvm.c
index e002a76..425549a 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -199,6 +199,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		/* EOF */
 		if (!input) {
+			/* readline sends prompt to stdout */
 			printf("\n");
 			break;
 		}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index eea874e..f3704d6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -847,6 +847,9 @@ static int _get_settings(struct cmd_context *cmd)
 		cmd->current_settings.verbose = 0;
 	}
 
+	if (arg_count(cmd, quiet_ARG) > 1)
+		cmd->current_settings.silent = 1;
+
 	if (arg_count(cmd, test_ARG))
 		cmd->current_settings.test = arg_count(cmd, test_ARG);
 
@@ -863,7 +866,7 @@ static int _get_settings(struct cmd_context *cmd)
 
 	if (arg_count(cmd, partial_ARG)) {
 		cmd->partial_activation = 1;
-		log_print("Partial mode. Incomplete logical volumes will be processed.");
+		log_warn("PARTIAL MODE. Incomplete logical volumes will be processed.");
 	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))
@@ -966,6 +969,7 @@ static void _apply_settings(struct cmd_context *cmd)
 {
 	init_debug(cmd->current_settings.debug);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
+	init_silent(cmd->current_settings.silent);
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
diff --git a/tools/lvrename.c b/tools/lvrename.c
index ef67682..3dc21dc 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -133,8 +133,8 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!lv_rename(cmd, lvl->lv, lv_name_new))
 		goto error;
 
-	log_print("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
-		  lv_name_old, lv_name_new, vg_name);
+	log_print_unless_silent("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
+				lv_name_old, lv_name_new, vg_name);
 
 	r = ECMD_PROCESSED;
 error:
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 05041af..5052bfb 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -466,8 +466,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 				lp->size += vg->extent_size -
 				    (lp->size % vg->extent_size);
 
-			log_print("Rounding size to boundary between physical extents: %s",
-				  display_size(cmd, lp->size));
+			log_print_unless_silent("Rounding size to boundary between physical extents: %s",
+						display_size(cmd, lp->size));
 		}
 
 		lp->extents = lp->size / vg->extent_size;
@@ -580,8 +580,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		}
 
 		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
-			log_print("Extending %" PRIu32 " mirror images.",
-				  seg_mirrors);
+			log_print_unless_silent("Extending %" PRIu32 " mirror images.",
+						seg_mirrors);
 			lp->mirrors = seg_mirrors;
 		}
 		if ((arg_count(cmd, mirrors_ARG) || seg_mirrors) &&
@@ -636,16 +636,16 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 		if (!lp->stripe_size && lp->stripes > 1) {
 			if (seg_stripesize) {
-				log_print("Using stripesize of last segment %s",
-					  display_size(cmd, (uint64_t) seg_stripesize));
+				log_print_unless_silent("Using stripesize of last segment %s",
+							display_size(cmd, (uint64_t) seg_stripesize));
 				lp->stripe_size = seg_stripesize;
 			} else {
 				lp->stripe_size =
 					find_config_tree_int(cmd,
 							"metadata/stripesize",
 							DEFAULT_STRIPESIZE) * 2;
-				log_print("Using default stripesize %s",
-					  display_size(cmd, (uint64_t) lp->stripe_size));
+				log_print_unless_silent("Using default stripesize %s",
+							display_size(cmd, (uint64_t) lp->stripe_size));
 			}
 		}
 	}
@@ -703,16 +703,16 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     !lp->percent ||
 		     (vg->free_count >= (lp->extents - lv->le_count - size_rest +
 					 (lp->stripes * stripesize_extents))))) {
-			log_print("Rounding size (%d extents) up to stripe "
-				  "boundary size for segment (%d extents)",
-				  lp->extents, lp->extents - size_rest +
-				  (lp->stripes * stripesize_extents));
+			log_print_unless_silent("Rounding size (%d extents) up to stripe "
+						"boundary size for segment (%d extents)",
+						lp->extents, lp->extents - size_rest +
+						(lp->stripes * stripesize_extents));
 			lp->extents = lp->extents - size_rest +
 				      (lp->stripes * stripesize_extents);
 		} else if (size_rest) {
-			log_print("Rounding size (%d extents) down to stripe "
-				  "boundary size for segment (%d extents)",
-				  lp->extents, lp->extents - size_rest);
+			log_print_unless_silent("Rounding size (%d extents) down to stripe "
+						"boundary size for segment (%d extents)",
+						lp->extents, lp->extents - size_rest);
 			lp->extents = lp->extents - size_rest;
 		}
 	}
@@ -802,10 +802,10 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	log_print("%sing logical volume %s to %s",
-		  (lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
-		  lp->lv_name,
-		  display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+	log_print_unless_silent("%sing logical volume %s to %s",
+				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
+				lp->lv_name,
+				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
 
 	if (lp->resize == LV_REDUCE) {
 		if (!lv_reduce(lv, lv->le_count - lp->extents)) {
@@ -871,7 +871,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	log_print("Logical volume %s successfully resized", lp->lv_name);
+	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
 	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 753b00d..636ac45 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -59,10 +59,10 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 	else
 		snapshot_str = "        ";
 
-	log_print("%s%s '%s%s/%s' [%s] %s", active_str, snapshot_str,
-		  cmd->dev_dir, lv->vg->name, lv->name,
-		  display_size(cmd, lv->size),
-		  get_alloc_string(lv->alloc));
+	log_print_unless_silent("%s%s '%s%s/%s' [%s] %s", active_str, snapshot_str,
+				cmd->dev_dir, lv->vg->name, lv->name,
+				display_size(cmd, lv->size),
+				get_alloc_string(lv->alloc));
 
 	return ECMD_PROCESSED;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index f57484e..a9138a1 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -108,8 +108,8 @@ progress_t poll_mirror_progress(struct cmd_context *cmd,
 
 	overall_percent = copy_percent(lv);
 	if (parms->progress_display)
-		log_print("%s: %s: %.1f%%", name, parms->progress_title,
-			  percent_to_float(overall_percent));
+		log_print_unless_silent("%s: %s: %.1f%%", name, parms->progress_title,
+					percent_to_float(overall_percent));
 	else
 		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
 			    percent_to_float(overall_percent));
@@ -213,8 +213,8 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 		lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid, parms->lv_type);
 
 		if (!lv && parms->lv_type == PVMOVE) {
-			log_print("%s: no pvmove in progress - already finished or aborted.",
-				  name);
+			log_print_unless_silent("%s: no pvmove in progress - already finished or aborted.",
+						name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 1;
 		}
diff --git a/tools/pvchange.c b/tools/pvchange.c
index f6d1abd..70f1e62 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -168,7 +168,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	log_print("Physical volume \"%s\" changed", pv_name);
+	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
 
 	return 1;
 }
@@ -269,10 +269,10 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		unlock_vg(cmd, VG_GLOBAL);
 	}
 
-	log_print("%d physical volume%s changed / %d physical volume%s "
-		  "not changed",
-		  done, done == 1 ? "" : "s",
-		  total - done, (total - done) == 1 ? "" : "s");
+	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s "
+				"not changed",
+				done, done == 1 ? "" : "s",
+				total - done, (total - done) == 1 ? "" : "s");
 
 	return (total == done) ? ECMD_PROCESSED : ECMD_FAILED;
 }
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 05ef33c..9649f11 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -215,35 +215,35 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		}
 		if (lv_is_origin(lv) || lv_is_cow(lv)) {
 			lv_skipped = 1;
-			log_print("Skipping snapshot-related LV %s", lv->name);
+			log_print_unless_silent("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRRORED) {
 			lv_skipped = 1;
-			log_print("Skipping mirror LV %s", lv->name);
+			log_print_unless_silent("Skipping mirror LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRROR_LOG) {
 			lv_skipped = 1;
-			log_print("Skipping mirror log LV %s", lv->name);
+			log_print_unless_silent("Skipping mirror log LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRROR_IMAGE) {
 			lv_skipped = 1;
-			log_print("Skipping mirror image LV %s", lv->name);
+			log_print_unless_silent("Skipping mirror image LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & LOCKED) {
 			lv_skipped = 1;
-			log_print("Skipping locked LV %s", lv->name);
+			log_print_unless_silent("Skipping locked LV %s", lv->name);
 			continue;
 		}
 
 		if (vg_is_clustered(vg) &&
 		    lv_is_active_exclusive_remotely(lv)) {
 			lv_skipped = 1;
-			log_print("Skipping LV %s which is activated "
-				  "exclusively on remote node.", lv->name);
+			log_print_unless_silent("Skipping LV %s which is activated "
+						"exclusively on remote node.", lv->name);
 			continue;
 		}
 
@@ -512,7 +512,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	exclusive = _pvmove_is_exclusive(cmd, vg);
 
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
-		log_print("Detected pvmove in progress for %s", pv_name);
+		log_print_unless_silent("Detected pvmove in progress for %s", pv_name);
 		if (argc || lv_name)
 			log_error("Ignoring remaining command line arguments");
 
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 7d05758..823c069 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -131,8 +131,8 @@ static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	if (!lvmetad_pv_gone_by_dev(dev, NULL))
 		goto_out;
 
-	log_print("Labels on physical volume \"%s\" successfully wiped",
-		  pv_name);
+	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
+				pv_name);
 
 	ret = ECMD_PROCESSED;
 
diff --git a/tools/pvresize.c b/tools/pvresize.c
index ff19811..2f0693a 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -118,7 +118,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		backup(vg);
 	}
 
-	log_print("Physical volume \"%s\" changed", pv_name);
+	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
 	r = 1;
 
 out:
@@ -176,8 +176,8 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, 0, &params,
 			      _pvresize_single);
 
-	log_print("%d physical volume(s) resized / %d physical volume(s) "
-		  "not resized", params.done, params.total - params.done);
+	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
+				"not resized", params.done, params.total - params.done);
 
 	return ret;
 }
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6c634e3..9287388 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -34,7 +34,7 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
-		log_print("%s", pv_dev_name(pv));
+		log_print_unless_silent("%s", pv_dev_name(pv));
 		return;
 	}
 
@@ -64,37 +64,31 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 	}
 
 	if (is_orphan(pv)) {
-		log_print("PV %-*s    %-*s %s [%s]",
-			  pv_max_name_len, pv_tmp_name,
-			  vg_max_name_len, " ",
-			  pv->fmt ? pv->fmt->name : "    ",
-			  display_size(cmd, pv_size(pv)));
+		log_print_unless_silent("PV %-*s    %-*s %s [%s]",
+					pv_max_name_len, pv_tmp_name,
+					vg_max_name_len, " ",
+					pv->fmt ? pv->fmt->name : "    ",
+					display_size(cmd, pv_size(pv)));
 		return;
 	}
 
 	if (pv_status(pv) & EXPORTED_VG) {
 		strncpy(vg_name_this, pv_vg_name(pv), vg_name_len);
-		log_print("PV %-*s  is in exported VG %s "
-			  "[%s / %s free]",
-			  pv_max_name_len, pv_tmp_name,
-			  vg_name_this,
-			  display_size(cmd, (uint64_t) pv_pe_count(pv) *
-				       pv_pe_size(pv)),
-			  display_size(cmd, (uint64_t) (pv_pe_count(pv) -
-						pv_pe_alloc_count(pv))
-				       * pv_pe_size(pv)));
+		log_print_unless_silent("PV %-*s  is in exported VG %s "
+					"[%s / %s free]",
+					pv_max_name_len, pv_tmp_name,
+					vg_name_this,
+					display_size(cmd, (uint64_t) pv_pe_count(pv) * pv_pe_size(pv)),
+					display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
 		return;
 	}
 
 	sprintf(vg_tmp_name, "%s", pv_vg_name(pv));
-	log_print("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
-		  pv_tmp_name, vg_max_name_len, vg_tmp_name,
-		  pv->fmt ? pv->fmt->name : "    ",
-		  display_size(cmd, (uint64_t) pv_pe_count(pv) *
-					       pv_pe_size(pv)),
-		  display_size(cmd, (uint64_t) (pv_pe_count(pv) -
-						pv_pe_alloc_count(pv)) *
-					   pv_pe_size(pv)));
+	log_print_unless_silent("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
+				pv_tmp_name, vg_max_name_len, vg_tmp_name,
+				pv->fmt ? pv->fmt->name : "    ",
+				display_size(cmd, (uint64_t) pv_pe_count(pv) * pv_pe_size(pv)),
+				display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
 }
 
 static int _auto_activation_handler(struct volume_group *vg, int partial,
@@ -223,8 +217,8 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 				break;
 			}
 
-			log_print("Device %s not found. "
-				  "Cleared from lvmetad cache.", buf ? : "");
+			log_print_unless_silent("Device %s not found. "
+						"Cleared from lvmetad cache.", buf ? : "");
 			if (buf)
 				dm_free(buf);
 			continue;
@@ -355,17 +349,17 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!pvs_found) {
-		log_print("No matching physical volumes found");
+		log_print_unless_silent("No matching physical volumes found");
 		unlock_vg(cmd, VG_GLOBAL);
 		return ECMD_PROCESSED;
 	}
 
-	log_print("Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]",
-		  pvs_found,
-		  display_size(cmd, size_total),
-		  pvs_found - new_pvs_found,
-		  display_size(cmd, (size_total - size_new)),
-		  new_pvs_found, display_size(cmd, size_new));
+	log_print_unless_silent("Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]",
+				pvs_found,
+				display_size(cmd, size_total),
+				pvs_found - new_pvs_found,
+				display_size(cmd, (size_total - size_new)),
+				new_pvs_found, display_size(cmd, size_new));
 
 	unlock_vg(cmd, VG_GLOBAL);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index d6fc951..1916bfd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1527,13 +1527,13 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 				   uint32_t *stripe_size)
 {
 	if (*stripes == 1 && *stripe_size) {
-		log_print("Ignoring stripesize argument with single stripe");
+		log_print_unless_silent("Ignoring stripesize argument with single stripe");
 		*stripe_size = 0;
 	}
 
 	if (*stripes > 1 && !*stripe_size) {
 		*stripe_size = find_config_tree_int(cmd, "metadata/stripesize", DEFAULT_STRIPESIZE) * 2;
-		log_print("Using default stripesize %s",
+		log_print_unless_silent("Using default stripesize %s",
 			  display_size(cmd, (uint64_t) *stripe_size));
 	}
 
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index c5d712f..32948d8 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -81,7 +81,7 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
-	log_print("Volume group \"%s\" successfully backed up.", vg_name);
+	log_print_unless_silent("Volume group \"%s\" successfully backed up.", vg_name);
 	return ECMD_PROCESSED;
 }
 
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 9715c93..d62df99 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -70,7 +70,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	log_print("Restored volume group %s", vg_name);
+	log_print_unless_silent("Restored volume group %s", vg_name);
 
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vg_name);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index c59d58e..34f6167 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -194,9 +194,9 @@ static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg
 	    dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
 		if (!_monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored))
 			r = 0;
-		log_print("%d logical volume(s) in volume group "
-			    "\"%s\" %smonitored",
-			    monitored, vg->name, (dmeventd_monitor_mode()) ? "" : "un");
+		log_print_unless_silent("%d logical volume(s) in volume group "
+					"\"%s\" %smonitored",
+					monitored, vg->name, (dmeventd_monitor_mode()) ? "" : "un");
 	}
 
 	return r;
@@ -209,9 +209,9 @@ static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_g
 	if (lvs_in_vg_activated(vg) && background_polling()) {
 	        polled = _poll_lvs_in_vg(cmd, vg);
 		if (polled)
-			log_print("Background polling started for %d logical volume(s) "
-				  "in volume group \"%s\"",
-				  polled, vg->name);
+			log_print_unless_silent("Background polling started for %d logical volume(s) "
+						"in volume group \"%s\"",
+						polled, vg->name);
 	}
 
 	return 1;
@@ -260,8 +260,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* Print message only if there was not found a missing VG */
 	if (!vg->cmd_missing_vgs)
-		log_print("%d logical volume(s) in volume group \"%s\" now active",
-			  lvs_in_vg_activated(vg), vg->name);
+		log_print_unless_silent("%d logical volume(s) in volume group \"%s\" now active",
+					lvs_in_vg_activated(vg), vg->name);
 	return r;
 }
 
@@ -508,7 +508,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 		backup(vg);
 
-		log_print("Volume group \"%s\" successfully changed", vg->name);
+		log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
 	}
 
 	if (arg_count(cmd, activate_ARG)) {
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 1106724..2ba4095 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -186,7 +186,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			  "archived metadata.");
 		return ECMD_FAILED;
 	}
-	log_print("Volume group %s successfully converted", vg_name);
+	log_print_unless_silent("Volume group %s successfully converted", vg_name);
 
 	backup(vg);
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index dcce544..2b9fb2f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -119,8 +119,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	backup(vg);
 
-	log_print("%s%colume group \"%s\" successfully created",
-		  clustered_message, *clustered_message ? 'v' : 'V', vg->name);
+	log_print_unless_silent("%s%colume group \"%s\" successfully created",
+				clustered_message, *clustered_message ? 'v' : 'V', vg->name);
 
 	release_vg(vg);
 	return ECMD_PROCESSED;
diff --git a/tools/vgexport.c b/tools/vgexport.c
index a1043d2..c573619 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -44,7 +44,7 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 
 	backup(vg);
 
-	log_print("Volume group \"%s\" successfully exported", vg->name);
+	log_print_unless_silent("Volume group \"%s\" successfully exported", vg->name);
 
 	return ECMD_PROCESSED;
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 161796c..2ce7edb 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -134,7 +134,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		goto_bad;
 
 	backup(vg);
-	log_print("Volume group \"%s\" successfully extended", vg_name);
+	log_print_unless_silent("Volume group \"%s\" successfully extended", vg_name);
 	r = ECMD_PROCESSED;
 
 bad:
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 284f536..5badcb5 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -48,7 +48,7 @@ static int vgimport_single(struct cmd_context *cmd __attribute__((unused)),
 
 	backup(vg);
 
-	log_print("Volume group \"%s\" successfully imported", vg->name);
+	log_print_unless_silent("Volume group \"%s\" successfully imported", vg->name);
 
 	return ECMD_PROCESSED;
 
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 7b2183f..2cecb05 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -148,8 +148,8 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	/* FIXME Remove /dev/vgfrom */
 
 	backup(vg_to);
-	log_print("Volume group \"%s\" successfully merged into \"%s\"",
-		  vg_from->name, vg_to->name);
+	log_print_unless_silent("Volume group \"%s\" successfully merged into \"%s\"",
+				vg_from->name, vg_to->name);
 	r = ECMD_PROCESSED;
 bad:
 	/*
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 975b9ea..1b04a49 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -193,7 +193,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	backup(vg);
 
-	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
+	log_print_unless_silent("Removed \"%s\" from volume group \"%s\"", name, vg->name);
 	r = ECMD_PROCESSED;
 bad:
 	if (pvl)
@@ -304,8 +304,8 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		backup(vg);
 
 		if (fixed) {
-			log_print("Wrote out consistent volume group %s",
-				  vg_name);
+			log_print_unless_silent("Wrote out consistent volume group %s",
+						vg_name);
 			ret = ECMD_PROCESSED;
 		} else
 			ret = ECMD_FAILED;
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 56031ec..451d085 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -177,8 +177,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	unlock_vg(cmd, vg_name_new);
 	unlock_and_release_vg(cmd, vg, vg_name_old);
 
-	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
-		  vg_name_old, vg_name_new);
+	log_print_unless_silent("Volume group \"%s\" successfully renamed to \"%s\"",
+				vg_name_old, vg_name_new);
 
 	/* FIXME lvmcache corruption - vginfo duplicated instead of renamed */
 	persistent_filter_wipe(cmd->filter);
diff --git a/tools/vgscan.c b/tools/vgscan.c
index f82c71f..a34f3ba 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -21,9 +21,9 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle __attribute__((unused)))
 {
-	log_print("Found %svolume group \"%s\" using metadata type %s",
-		  vg_is_exported(vg) ? "exported " : "", vg_name,
-		  vg->fid->fmt->name);
+	log_print_unless_silent("Found %svolume group \"%s\" using metadata type %s",
+				vg_is_exported(vg) ? "exported " : "", vg_name,
+				vg->fid->fmt->name);
 
 	check_current_backup(vg);
 
@@ -64,7 +64,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	log_print("Reading all physical volumes.  This may take a while...");
+	log_print_unless_silent("Reading all physical volumes.  This may take a while...");
 
 	maxret = process_each_vg(cmd, argc, argv, 0, NULL,
 				 &vgscan_single);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 73f94a8..3bbb9fa 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -493,9 +493,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	backup(vg_to);
 
-	log_print("%s volume group \"%s\" successfully split from \"%s\"",
-		  existing_vg ? "Existing" : "New",
-		  vg_to->name, vg_from->name);
+	log_print_unless_silent("%s volume group \"%s\" successfully split from \"%s\"",
+				existing_vg ? "Existing" : "New",
+				vg_to->name, vg_from->name);
 
 	r = ECMD_PROCESSED;
 


