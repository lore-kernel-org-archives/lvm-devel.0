From: David Teigland <teigland@sourceware.org>
Date: Fri, 15 Jun 2018 17:01:06 -0400
Subject: master - Drop --ignoreskippedcluster option
Message-ID: <201806152101.w5FL166V025039@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=428514a07f4bd270f6a137f08be1b2818312bdbd
Commit:        428514a07f4bd270f6a137f08be1b2818312bdbd
Parent:        ccab4a1994f4218810f1a6152cf6c71caa00977e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 15 15:43:59 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 15 15:59:34 2018 -0500

Drop --ignoreskippedcluster option

It's no longer needed.  Clustered VGs are now handled in
the same way as foreign VGs, and as shared VGs that
can't be accessed:

- A command processing all VGs sees a clustered VG,
  prints a message ("Skipping clustered VG foo."),
  skips it, and does not fail.

- A command where the clustered VG is explicitly
  named on the command line, prints a message and fails.
  "Cannot access clustered VG foo, see lvmlockd(8)."

The option is listed in the set of ignored options for
the commands that previously accepted it.  (Removing it
entirely would cause commands/scripts to fail if they
set it.)
---
 lib/commands/toolcontext.c                         |    1 -
 lib/commands/toolcontext.h                         |    1 -
 lib/metadata/metadata.c                            |    5 +--
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    4 +-
 tools/args.h                                       |    3 +-
 tools/command-lines.in                             |   45 +++++++++++++-------
 tools/lvmcmdline.c                                 |    1 -
 tools/toollib.c                                    |   19 ++++----
 9 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 723f882..50474c1 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1762,7 +1762,6 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	cmd->threaded = threaded ? 1 : 0;
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
-	cmd->ignore_clustered_vgs = 0;
 	cmd->hosttags = 0;
 	dm_list_init(&cmd->arg_value_groups);
 	dm_list_init(&cmd->formats);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 9849e5f..2b730ea 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -144,7 +144,6 @@ struct cmd_context {
 	unsigned report_binary_values_as_numeric:1;
 	unsigned report_mark_hidden_devices:1;
 	unsigned metadata_read_only:1;
-	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;			/* set if running within a thread e.g. clvmd */
 	unsigned unknown_system_id:1;
 	unsigned include_historical_lvs:1;	/* also process/report/display historical LVs */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 34b1ec7..0ff38a2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4698,10 +4698,7 @@ static int _access_vg_clustered(struct cmd_context *cmd, const struct volume_gro
 			return 1;
 		}
 
-		if (!cmd->ignore_clustered_vgs)
-			log_error("Skipping clustered volume group %s", vg->name);
-		else
-			log_verbose("Skipping clustered volume group %s", vg->name);
+		log_verbose("Skipping clustered VG %s.", vg->name);
 		return 0;
 	}
 
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 7791e64..b3d18d2 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -175,7 +175,7 @@ static int generate_unit(struct generator *gen, int unit)
 		      "Wants=systemd-udev-settle.service\n\n" "[Service]\n", f);
 	}
 
-	fputs("ExecStart=" LVM_PATH " vgchange -aay --ignoreskippedcluster", f);
+	fputs("ExecStart=" LVM_PATH " vgchange -aay", f);
 	if (gen->cfg.sysinit_needed)
 		fputs(" --sysinit", f);
 	fputs("\nType=oneshot\n", f);
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index ebc069e..4144862 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -10,8 +10,8 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
-ExecStart=@SBINDIR@/lvm vgchange --monitor y --ignoreskippedcluster
-ExecStop=@SBINDIR@/lvm vgchange --monitor n --ignoreskippedcluster
+ExecStart=@SBINDIR@/lvm vgchange --monitor y
+ExecStop=@SBINDIR@/lvm vgchange --monitor n
 RemainAfterExit=yes
 
 [Install]
diff --git a/tools/args.h b/tools/args.h
index 2434f4b..e574bc7 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -243,8 +243,7 @@ arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", 0, 0, 0,
     "Do not use this if dmeventd is already monitoring a device.\n")
 
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", 0, 0, 0,
-    "Use to avoid exiting with an non-zero status code if the command is run\n"
-    "without clustered locking and clustered VGs are skipped.\n")
+    "No longer used.\n")
 
 arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", 0, 0, 0,
     "Exclude unsupported configuration settings from the output. These settings are\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0f9ed47..0155b33 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -194,7 +194,7 @@ OO_ALL: --commandprofile String, --config String, --debug,
 # options for pvs, lvs, vgs, fullreport
 #
 OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
---ignorelockingfailure, --ignoreskippedcluster, --logonly,
+--ignorelockingfailure, --logonly,
 --nameprefixes, --noheadings, --nosuffix,
 --options String, --readonly, --reportformat ReportFmt, --rows,
 --select String, --separator String, --shared, --sort String,
@@ -213,8 +213,7 @@ OO_CONFIG: --atversion String, --typeconfig ConfigType, --file String, --ignorea
 # None of these can function as a required option for lvchange.
 
 OO_LVCHANGE: --autobackup Bool, --force, --ignoremonitoring,
---ignoreskippedcluster, --noudevsync, --reportformat ReportFmt,
---select String
+--noudevsync, --reportformat ReportFmt, --select String
 
 # Any of these can function as a required option for lvchange.
 # profile is also part of OO_ALL, but is repeated in OO_LVCHANGE_META
@@ -235,6 +234,7 @@ OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
 
 lvchange OO_LVCHANGE_META VG|LV|Tag|Select ...
 OO: --activate Active, --poll Bool, --monitor Bool, OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_properties
 DESC: Change a general LV attribute.
 DESC: For options listed in parentheses, any one is
@@ -257,6 +257,7 @@ RULE: --alloc --discards --zero --cachemode --cachepolicy --cachesettings not lv
 
 lvchange --resync VG|LV_raid_mirror|Tag|Select ...
 OO: --activate Active, OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_resync
 DESC: Resyncronize a mirror or raid LV.
 RULE: all not lv_is_pvmove lv_is_locked
@@ -264,12 +265,14 @@ RULE: all not LV_raid0
 
 lvchange --syncaction SyncAction VG|LV_raid|Tag|Select ...
 OO: OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_syncaction
 DESC: Resynchronize or check a raid LV.
 RULE: all not LV_raid0
 
 lvchange --rebuild PV VG|LV_raid|Tag|Select ...
 OO: OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_rebuild
 DESC: Reconstruct data on specific PVs of a raid LV.
 RULE: all not LV_raid0
@@ -277,27 +280,32 @@ RULE: all not LV_raid0
 lvchange --activate Active VG|LV|Tag|Select ...
 OO: --activationmode ActivationMode, --partial, --poll Bool, --monitor Bool,
 --ignoreactivationskip, --ignorelockingfailure, --sysinit, OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_activate
 DESC: Activate or deactivate an LV.
 
 lvchange --refresh VG|LV|Tag|Select ...
 OO: --activationmode ActivationMode, --partial, --poll Bool, --monitor Bool, OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_refresh
 DESC: Reactivate an LV using the latest metadata.
 
 lvchange --monitor Bool VG|LV|Tag|Select ...
 OO: OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_monitor
 DESC: Start or stop monitoring an LV from dmeventd.
 RULE: all not lv_is_pvmove
 
 lvchange --poll Bool VG|LV|Tag|Select ...
 OO: --monitor Bool, OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_poll
 DESC: Start or stop processing an LV conversion.
 
 lvchange --persistent y --minor Number LV
 OO: --major Number, --activate Active, --poll Bool, --monitor Bool, OO_LVCHANGE
+IO: --ignoreskippedcluster
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
 RULE: all not LV_thinpool LV_cachepool
@@ -1193,12 +1201,12 @@ FLAGS: SECONDARY_SYNTAX
 lvdisplay
 OO: --aligned, --all, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --history, --ignorelockingfailure,
---ignoreskippedcluster, --logonly, --maps, --noheadings,
+--logonly, --maps, --noheadings,
 --nosuffix, --options String, --sort String, --readonly,
 --reportformat ReportFmt, --segments, --select String, --separator String,
 --shared, --unbuffered, --units Units
 OP: VG|LV|Tag ...
-IO: --partial
+IO: --partial, --ignoreskippedcluster
 ID: lvdisplay_general
 
 ---
@@ -1312,7 +1320,7 @@ DESC: Resize a pool metadata SubLV by a specified size.
 lvs
 OO: --history, --segments, OO_REPORT
 OP: VG|LV|Tag ...
-IO: --partial
+IO: --partial, --ignoreskippedcluster
 ID: lvs_general
 
 ---
@@ -1333,8 +1341,7 @@ ID: lvscan_cache
 ---
 
 # None of these can function as a required option for pvchange.
-OO_PVCHANGE: --autobackup Bool, --force, --ignoreskippedcluster,
---reportformat ReportFmt, --uuid
+OO_PVCHANGE: --autobackup Bool, --force, --reportformat ReportFmt, --uuid
 
 # Any of these can function as a required option for pvchange.
 OO_PVCHANGE_META: --allocatable Bool, --addtag Tag, --deltag Tag,
@@ -1342,11 +1349,13 @@ OO_PVCHANGE_META: --allocatable Bool, --addtag Tag, --deltag Tag,
 
 pvchange OO_PVCHANGE_META --all
 OO: OO_PVCHANGE
+IO: --ignoreskippedcluster
 ID: pvchange_properties_all
 DESC: Change properties of all PVs.
 
 pvchange OO_PVCHANGE_META PV|Select ...
 OO: --select String, OO_PVCHANGE
+IO: --ignoreskippedcluster
 ID: pvchange_properties_some
 DESC: Change properties of specified PVs.
 
@@ -1381,11 +1390,12 @@ RULE: --bootloaderareasize not --restorefile
 
 pvdisplay
 OO: --aligned, --all, --binary, --colon, --columns, --configreport ConfigReport,
---foreign, --ignorelockingfailure, --ignoreskippedcluster,
+--foreign, --ignorelockingfailure,
 --logonly, --maps, --noheadings, --nosuffix, --options String,
 --readonly, --reportformat ReportFmt, --select String, --separator String, --shared,
 --short, --sort String, --unbuffered, --units Units
 OP: PV|Tag ...
+IO: --ignoreskippedcluster
 ID: pvdisplay_general
 
 ---
@@ -1413,7 +1423,7 @@ ID: pvremove_general
 pvs
 OO: --segments, OO_REPORT
 OP: PV|Tag ...
-IO: --partial
+IO: --partial, --ignoreskippedcluster
 ID: pvs_general
 
 ---
@@ -1473,7 +1483,7 @@ DESC: List one VG metadata backup file.
 
 # None of these can function as a required option for vgchange.
 
-OO_VGCHANGE: --autobackup Bool, --ignoremonitoring, --ignoreskippedcluster,
+OO_VGCHANGE: --autobackup Bool, --ignoremonitoring,
 --noudevsync, --reportformat ReportFmt, --select String, --force
 
 # Any of these can function as a required option for vgchange.
@@ -1489,6 +1499,7 @@ OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
 vgchange OO_VGCHANGE_META
 OO: --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
+IO: --ignoreskippedcluster
 ID: vgchange_properties
 DESC: Change a general VG attribute.
 DESC: For options listed in parentheses, any one is
@@ -1497,12 +1508,14 @@ DESC: required, after which the others are optional.
 vgchange --monitor Bool
 OO: --sysinit, --ignorelockingfailure, --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
+IO: --ignoreskippedcluster
 ID: vgchange_monitor
 DESC: Start or stop monitoring LVs from dmeventd.
 
 vgchange --poll Bool
 OO: --ignorelockingfailure, OO_VGCHANGE
 OP: VG|Tag|Select ...
+IO: --ignoreskippedcluster
 ID: vgchange_poll
 DESC: Start or stop processing LV conversions.
 
@@ -1510,12 +1523,14 @@ vgchange --activate Active
 OO: --activationmode ActivationMode, --ignoreactivationskip, --partial, --sysinit,
 --ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
+IO: --ignoreskippedcluster
 ID: vgchange_activate
 DESC: Activate or deactivate LVs.
 
 vgchange --refresh
 OO: --sysinit, --ignorelockingfailure, --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
+IO: --ignoreskippedcluster
 ID: vgchange_refresh
 DESC: Reactivate LVs using the latest metadata.
 
@@ -1562,11 +1577,11 @@ ID: vgcreate_general
 vgdisplay
 OO: --activevolumegroups, --aligned, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --ignorelockingfailure,
---ignoreskippedcluster, --logonly, --noheadings, --nosuffix,
+--logonly, --noheadings, --nosuffix,
 --options String, --readonly, --reportformat ReportFmt, --select String,
 --shared, --short, --separator String, --sort String, --unbuffered, --units Units
 OP: VG|Tag ...
-IO: --partial
+IO: --partial, --ignoreskippedcluster
 ID: vgdisplay_general
 
 ---
@@ -1668,7 +1683,7 @@ DESC: Rename a VG by specifying the VG UUID.
 vgs
 OO: OO_REPORT
 OP: VG|Tag ...
-IO: --partial
+IO: --partial, --ignoreskippedcluster
 ID: vgs_general
 
 ---
@@ -1723,7 +1738,7 @@ ID: devtypes_general
 fullreport
 OO: OO_REPORT
 OP: VG ...
-IO: --partial
+IO: --partial, --ignoreskippedcluster
 ID: fullreport_general
 
 lastlog
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 2578113..3e617c1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2323,7 +2323,6 @@ static int _get_current_settings(struct cmd_context *cmd)
 		return EINVALID_CMD_LINE;
 	}
 
-	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
 	cmd->include_shared_vgs = arg_is_set(cmd, shared_ARG) ? 1 : 0;
 	cmd->include_historical_lvs = arg_is_set(cmd, history_ARG) ? 1 : 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index c81d1c2..ebf2509 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -204,10 +204,15 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	if ((read_error & FAILED_INCONSISTENT) && (read_flags & READ_ALLOW_INCONSISTENT))
 		read_error &= ~FAILED_INCONSISTENT; /* Check for other errors */
 
-	if ((read_error & FAILED_CLUSTERED) && vg->cmd->ignore_clustered_vgs) {
-		read_error &= ~FAILED_CLUSTERED; /* Check for other errors */
-		log_verbose("Skipping volume group %s", vg_name);
-		*skip = 1;
+	if (read_error & FAILED_CLUSTERED) {
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
+			log_error("Cannot access clustered VG %s, see lvmlockd(8).", vg->name);
+			return 1;
+		} else {
+			log_warn("Skipping clustered VG %s.", vg_name);
+			*skip = 1;
+			return 0;
+		}
 	}
 
 	/*
@@ -254,12 +259,6 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		}
 	}
 
-	if (read_error == FAILED_CLUSTERED) {
-		*skip = 1;
-		stack;	/* Error already logged */
-		return 1;
-	}
-
 	if (read_error != SUCCESS) {
 		*skip = 0;
 		if (is_orphan_vg(vg_name))


