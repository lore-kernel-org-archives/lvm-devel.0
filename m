From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 18 Apr 2014 01:48:07 +0000 (UTC)
Subject: master - tools: Add --readonly support.
Message-ID: <20140418014807.EB9F760317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5f8f452ac563ef07513e770b3202c6dc209443c
Commit:        b5f8f452ac563ef07513e770b3202c6dc209443c
Parent:        17e304e0ac24ba0d1887badfb51afa731aa138e9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 18 02:46:34 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 18 02:46:34 2014 +0100

tools: Add --readonly support.

Offer lock-free access to display virtual machine or clustered VG metadata
while it might be in use.
---
 WHATS_NEW                   |    2 ++
 conf/example.conf.in        |    9 +++++++++
 lib/activate/activate.c     |    7 +++++--
 lib/activate/activate.h     |    2 +-
 lib/commands/toolcontext.c  |    2 +-
 lib/locking/locking.c       |    5 +++++
 lib/locking/locking_types.h |    7 +++++--
 lib/locking/no_locking.c    |   14 +++++++++++---
 man/lvm.8.in                |   11 +++++++++++
 tools/args.h                |    1 +
 tools/commands.h            |   37 +++++++++++++++++++++++++++----------
 tools/lvmcmdline.c          |   20 ++++++++++++++++++--
 12 files changed, 96 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ac18601..dfa50e8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.107 - 
 ==================================
+  Add --readonly to reporting and display tools for lock-free metadata access.
+  Add locking_type 5 for dummy locking for tools that do not need any locks.
   Fix _recover_vg() error path when lock conversion fails.
   Use X for LV attributes that are unknown when activation disabled.
   Only output lvdisplay 'LV Status' field when activation is enabled.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 2ed3fd6..d5ddb1c 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -520,6 +520,15 @@ global {
     # Type 3 uses built-in clustered locking.
     # Type 4 uses read-only locking which forbids any operations that might 
     # change metadata.
+    # Type 5 offers dummy locking for tools that do not need any locks.
+    # You should not need to set this directly: the tools will select when
+    # to use it instead of the configured locking_type.  Do not use lvmetad or
+    # the kernel device-mapper driver with this locking type.
+    # It is used by the --readonly option that offers read-only access to
+    # Volume Group metadata that cannot be locked safely because it belongs to
+    # an inaccessible domain and might be in use, for example a virtual machine
+    # image or a disk that is shared by a clustered machine.  
+    #
     # N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet
     # supported in clustered environment. If use_lvmetad=1 and locking_type=3
     # is set at the same time, LVM always issues a warning message about this
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4d3f8fe..a7ec751 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -431,7 +431,7 @@ int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 
 static int _activation = 1;
 
-void set_activation(int act)
+void set_activation(int act, int silent)
 {
 	if (act == _activation)
 		return;
@@ -440,9 +440,12 @@ void set_activation(int act)
 	if (_activation)
 		log_verbose("Activation enabled. Device-mapper kernel "
 			    "driver will be used.");
-	else
+	else if (!silent)
 		log_warn("WARNING: Activation disabled. No device-mapper "
 			  "interaction will be attempted.");
+	else
+		log_verbose("Activation disabled. No device-mapper "
+			    "interaction will be attempted.");
 }
 
 int activation(void)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 435cac5..946494e 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -52,7 +52,7 @@ struct lv_activate_opts {
 				 * that follows. */
 };
 
-void set_activation(int activation);
+void set_activation(int activation, int silent);
 int activation(void);
 
 int driver_version(char *version, size_t size);
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c76f281..d62fb8a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -348,7 +348,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	/* activation? */
 	cmd->default_settings.activation = find_config_tree_bool(cmd, global_activation_CFG, NULL);
-	set_activation(cmd->default_settings.activation);
+	set_activation(cmd->default_settings.activation, 0);
 
 	cmd->auto_set_activation_skip = find_config_tree_bool(cmd, activation_auto_set_activation_skip_CFG, NULL);
 
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9433e40..b5250c1 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -284,6 +284,11 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 			break;
 		return 1;
 
+	case 5:
+		init_dummy_locking(&_locking, cmd, suppress_messages);
+		log_verbose("Locking disabled for read-only access.");
+		return 1;
+
 	default:
 		log_error("Unknown locking type requested.");
 		return 0;
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 3009490..6e4adcc 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -38,8 +38,11 @@ struct locking_type {
 /*
  * Locking types
  */
-int init_no_locking(struct locking_type *locking, struct cmd_context *cmd,
-		    int suppress_messages);
+void init_no_locking(struct locking_type *locking, struct cmd_context *cmd,
+		     int suppress_messages);
+
+void init_dummy_locking(struct locking_type *locking, struct cmd_context *cmd,
+			int suppress_messages);
 
 int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd,
 			  int suppress_messages);
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index dac2f80..f7718be 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -91,7 +91,7 @@ static int _readonly_lock_resource(struct cmd_context *cmd,
 	return _no_lock_resource(cmd, resource, flags, lv);
 }
 
-int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
+void init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
 		    int suppress_messages)
 {
 	locking->lock_resource = _no_lock_resource;
@@ -99,8 +99,6 @@ int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attr
 	locking->reset_locking = _no_reset_locking;
 	locking->fin_locking = _no_fin_locking;
 	locking->flags = LCK_CLUSTERED;
-
-	return 1;
 }
 
 int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
@@ -114,3 +112,13 @@ int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd
 
 	return 1;
 }
+
+void init_dummy_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
+		    int suppress_messages)
+{
+	locking->lock_resource = _readonly_lock_resource;
+	locking->query_resource = _no_query_resource;
+	locking->reset_locking = _no_reset_locking;
+	locking->fin_locking = _no_fin_locking;
+	locking->flags = LCK_CLUSTERED;
+}
diff --git a/man/lvm.8.in b/man/lvm.8.in
index f6335ed..e273935 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -223,6 +223,17 @@ Use to avoid exiting with an non-zero status code if the command is run
 without clustered locking and some clustered Volume Groups have to be
 skipped over.
 .TP
+.B \-\-readonly
+Run the command in a special read-only mode which will read on-disk
+metadata without needing to take any locks.  This can be used to peek
+inside metadata used by a virtual machine image while the virtual
+machine is running.
+It can also be used to peek inside the metadata of clustered Volume
+Groups when clustered locking is not configured or running.  No attempt
+will be made to communicate with the device-mapper kernel driver, so
+this option is unable to report whether or not Logical Volumes are 
+actually in use.
+.TP
 .B \-\-addtag \fITag
 Add the tag \fITag\fP to a PV, VG or LV.
 Supply this argument multiple times to add more than one tag at once.
diff --git a/tools/args.h b/tools/args.h
index f1a4ef4..2e63adb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -104,6 +104,7 @@ arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
+arg(readonly_ARG, '\0', "readonly", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index b0bad9d..21a2075 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -335,6 +335,7 @@ xx(lvdisplay,
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
@@ -352,6 +353,7 @@ xx(lvdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -362,8 +364,8 @@ xx(lvdisplay,
 
     aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG, 
     ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-    options_ARG, sort_ARG, partial_ARG, segments_ARG, separator_ARG,
-    unbuffered_ARG, units_ARG)
+    options_ARG, sort_ARG, partial_ARG, readonly_ARG, segments_ARG,
+    separator_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -414,9 +416,10 @@ xx(lvmdiskscan,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-l|--lvmpartition]\n"
+   "\t[--readonly]\n"
    "\t[--version]" "\n",
 
-   lvmpartition_ARG)
+   lvmpartition_ARG, readonly_ARG)
 
 xx(lvmsadc,
    "Collect activity data",
@@ -539,6 +542,7 @@ xx(lvs,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
@@ -553,6 +557,7 @@ xx(lvs,
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
+   readonly_ARG,
    rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
    unbuffered_ARG, units_ARG, unquoted_ARG)
 
@@ -566,10 +571,12 @@ xx(lvscan,
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG)
+   all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG,
+   readonly_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -681,6 +688,7 @@ xx(pvdisplay,
    "\t[--ignoreskippedcluster]\n"
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
+   "\t[--readonly]\n"
    "\t[-s|--short]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
@@ -698,6 +706,7 @@ xx(pvdisplay,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
@@ -707,7 +716,8 @@ xx(pvdisplay,
 
    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-   options_ARG, separator_ARG, short_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   options_ARG, readonly_ARG, separator_ARG, short_ARG, sort_ARG,
+   unbuffered_ARG, units_ARG)
 
 xx(pvmove,
    "Move extents from one physical volume to another",
@@ -763,6 +773,7 @@ xx(pvs,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
@@ -776,7 +787,7 @@ xx(pvs,
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
+   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
    trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
@@ -790,6 +801,7 @@ xx(pvscan,
    "\t[-h|-?|--help]" "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[-s|--short] " "\n"
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -797,7 +809,7 @@ xx(pvscan,
 
    activate_ARG, available_ARG, backgroundfork_ARG, cache_ARG,
    exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
-   novolumegroup_ARG, partial_ARG, short_ARG, uuid_ARG)
+   novolumegroup_ARG, partial_ARG, readonly_ARG, short_ARG, uuid_ARG)
 
 xx(segtypes,
    "List available segment types",
@@ -818,11 +830,12 @@ xx(vgcfgbackup,
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
    "\t[VolumeGroupName...]\n",
 
-   file_ARG, ignorelockingfailure_ARG, partial_ARG)
+   file_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG)
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
@@ -955,6 +968,7 @@ xx(vgdisplay,
    "\t[--ignoreskippedcluster]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--version]" "\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n"
@@ -970,6 +984,7 @@ xx(vgdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
@@ -979,8 +994,8 @@ xx(vgdisplay,
 
    activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, noheadings_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, short_ARG, separator_ARG,
-   sort_ARG, unbuffered_ARG, units_ARG)
+   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, short_ARG,
+   separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -1127,6 +1142,7 @@ xx(vgs,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -1140,6 +1156,7 @@ xx(vgs,
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
+   readonly_ARG,
    rows_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
    unquoted_ARG)
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b7d69ef..758c429 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -894,6 +894,13 @@ static int _get_settings(struct cmd_context *cmd)
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
 	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
+
+	if (arg_count(cmd, readonly_ARG)) {
+		cmd->current_settings.activation = 0;
+		cmd->current_settings.archive = 0;
+		cmd->current_settings.backup = 0;
+	}
+
 	cmd->partial_activation = 0;
 
 	if (arg_count(cmd, partial_ARG)) {
@@ -1022,7 +1029,7 @@ static void _apply_settings(struct cmd_context *cmd)
 	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
 
-	set_activation(cmd->current_settings.activation);
+	set_activation(cmd->current_settings.activation, cmd->metadata_read_only);
 
 	cmd->fmt = get_format_by_name(cmd, arg_str_value(cmd, metadatatype_ARG,
 				      cmd->current_settings.fmt_name));
@@ -1141,6 +1148,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			return_ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, readonly_ARG))
+		cmd->metadata_read_only = 1;
+
 	if ((ret = _get_settings(cmd)))
 		goto_out;
 	_apply_settings(cmd);
@@ -1168,7 +1178,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (arg_count(cmd, nolocking_ARG))
+	if (arg_count(cmd, readonly_ARG)) {
+		locking_type = 5;
+		if (lvmetad_used()) {
+			lvmetad_set_active(0);
+			log_verbose("Disabling use of lvmetad because read-only is set.");
+		}
+	} else if (arg_count(cmd, nolocking_ARG))
 		locking_type = 0;
 	else
 		locking_type = -1;


