From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 23:47:41 +0000 (UTC)
Subject: master - systemid: Extend --foreign to reporting commands.
Message-ID: <20150223234742.0A7DC60D68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5793ecd16541961ebb91239395dc82504ad31906
Commit:        5793ecd16541961ebb91239395dc82504ad31906
Parent:        b18feb98e50093d66f03ff63120b6a0f14d7fddd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 23:41:38 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 23:41:38 2015 +0000

systemid: Extend --foreign to reporting commands.

Add --foreign to the remaining reporting and display commands plus
vgcfgbackup.
Add a NEEDS_FOREIGN_VGS flag for vgimport to always set --foreign.
If lvmetad is being used with --foreign, scan foreign VGs (currently
implemented as a full PV scan).
Handle these things centrally in lvmcmdline.c.
Also allow lvchange and vgchange -an/-aln to deactivate any foreign
LVs that happen to be active if something went wrong.
Remember to set the system ID when creating a new VG in vgsplit.
---
 WHATS_NEW          |    4 ++++
 tools/commands.h   |   36 +++++++++++++++++++++++-------------
 tools/lvchange.c   |    5 +++++
 tools/lvmcmdline.c |   17 ++++++++++++++++-
 tools/reporter.c   |   10 ----------
 tools/tools.h      |    2 ++
 tools/vgcreate.c   |    5 +++--
 tools/vgimport.c   |   15 ++-------------
 tools/vgsplit.c    |    1 +
 9 files changed, 56 insertions(+), 39 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 983189c..6220398 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.117 - 
 ====================================
+  Add NEEDS_FOREIGN_VGS flag to vgimport so --foreign is always supplied.
+  Add --foreign to the 6 display and reporting tools and vgcfgbackup.
   Install /etc/lvm/lvmlocal.conf template with local section for systemid.
   Record creation_host_system_id in lvm2 metadata.
   Reinstate recursive config file tag section processing. (2.02.99)
@@ -7,6 +9,8 @@ Version 2.02.117 -
   Fix configure to properly recognize --with-default-raid10-segtype option.
   Do not refresh filters/rescan if no signature is wiped during pvcreate.
   Enforce none external dev info for wiping during pvcreate to avoid races.
+  Add global/system_id_source and system_id_file to lvm.conf.
+  Add --systemid to vgcreate and vchange to set / change a system ID.
   Add support for VG system_id to control host access to VGs.
   Update vgextend to use process_each_vg.
   Add --ignoreskippedcluster to pvchange.
diff --git a/tools/commands.h b/tools/commands.h
index 05ee186..00708f6 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -362,6 +362,7 @@ xx(lvdisplay,
    "\t[-c|--colon]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -381,6 +382,7 @@ xx(lvdisplay,
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -399,7 +401,7 @@ xx(lvdisplay,
    "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
+    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
     ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
     noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG, partial_ARG,
     readonly_ARG, segments_ARG, select_ARG, separator_ARG,
@@ -583,6 +585,7 @@ xx(lvs,
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -605,7 +608,7 @@ xx(lvs,
    "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
+   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
    nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
@@ -744,6 +747,7 @@ xx(pvdisplay,
    "\t[-c|--colon]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -763,6 +767,7 @@ xx(pvdisplay,
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -779,7 +784,7 @@ xx(pvdisplay,
    "\t[--version]\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
+   aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG,
    select_ARG, separator_ARG, short_ARG, sort_ARG, unbuffered_ARG,
@@ -835,6 +840,7 @@ xx(pvs,
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -857,7 +863,7 @@ xx(pvs,
    "\t[--version]\n"
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
+   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
    nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, rows_ARG,
    segments_ARG, select_ARG, separator_ARG, sort_ARG, trustcache_ARG,
@@ -907,6 +913,7 @@ xx(vgcfgbackup,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--file filename]\n"
+   "\t[--foreign]\n"
    "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial]\n"
@@ -915,7 +922,7 @@ xx(vgcfgbackup,
    "\t[--version]\n"
    "\t[VolumeGroupName...]\n",
 
-   file_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG)
+   file_ARG, foreign_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG)
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
@@ -955,11 +962,10 @@ xx(vgchange,
    "\t[--[vg]metadatacopies #copies]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
-   "\t[--systemid SystemID]\n"
    "\t[--refresh]\n"
    "\t[-S|--select Selection]\n"
-   "\t[--systemid SystemID]\n"
    "\t[--sysinit]\n"
+   "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-v|--verbose]\n"
@@ -1033,6 +1039,7 @@ xx(vgcreate,
    "\t[--[vg]metadatacopies #copies]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -1055,6 +1062,7 @@ xx(vgdisplay,
    "\t[-c|--colon | -s|--short | -v|--verbose]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -1071,6 +1079,7 @@ xx(vgdisplay,
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -1089,9 +1098,9 @@ xx(vgdisplay,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, noheadings_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, select_ARG,
-   short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
+   noheadings_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
+   select_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -1133,7 +1142,7 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT,
+   ALL_VGS_IS_DEFAULT | NEEDS_FOREIGN_VGS,
    "vgimport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1242,6 +1251,7 @@ xx(vgs,
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
@@ -1263,11 +1273,11 @@ xx(vgs,
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
+   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
    nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    readonly_ARG, rows_ARG, select_ARG, separator_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG, foreign_ARG)
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c9466ec..1ed0dd5 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1178,6 +1178,11 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!update && !arg_count(cmd, refresh_ARG) && !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG) &&
+	     arg_count(cmd, activate_ARG) &&
+	     !is_change_activating((activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+		cmd->include_foreign_vgs = 1;
+
 	/*
 	 * If --sysinit -aay is used and at the same time lvmetad is used,
 	 * we want to rely on autoactivation to take place. Also, we
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6bdb00b..b38039b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1074,7 +1074,9 @@ static int _get_settings(struct cmd_context *cmd)
 	else
 		init_ignorelockingfailure(0);
 
-	cmd->ignore_clustered_vgs = arg_count(cmd, ignoreskippedcluster_ARG) ? 1 : 0;
+	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
+	cmd->include_foreign_vgs =
+	     ((cmd->command->flags & NEEDS_FOREIGN_VGS) || arg_is_set(cmd, foreign_ARG)) ? 1 : 0;
 
 	if (!arg_count(cmd, sysinit_ARG))
 		lvmetad_connect_or_warn();
@@ -1500,6 +1502,19 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	}
 
+	/*
+	 * Other hosts might have changed foreign VGs so enforce a rescan
+	 * before processing any command using them.
+	 */
+	if (cmd->include_foreign_vgs && lvmetad_used() &&
+	    !lvmetad_pvscan_foreign_vgs(cmd, NULL)) {
+		log_error("Failed to scan devices.");
+		return ECMD_FAILED;
+	}
+
+	/*
+	 * FIXME Break up into multiple functions.
+	 */
 	ret = cmd->command->fn(cmd, argc, argv);
 
 	fin_locking();
diff --git a/tools/reporter.c b/tools/reporter.c
index cd0db6f..779e0bd 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -581,16 +581,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int lv_info_needed, lv_segment_status_needed;
 	int lock_global = 0;
 
-	/*
-	 * When reporting foreign VGs we want to refresh our cached
-	 * copy of them, since other hosts have probably made changes
-	 * to their own VGs.  We also want to override the default
-	 * behavior which skips over foreign VGs.
-	 */
-	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG);
-	if (cmd->include_foreign_vgs && lvmetad_used())
-		lvmetad_pvscan_all_devs(cmd, NULL);
-
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
 	headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
diff --git a/tools/tools.h b/tools/tools.h
index 109834a..be4b166 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -108,6 +108,8 @@ struct arg_value_group_list {
 #define ENABLE_ALL_DEVS		0x00000008	
 /* Exactly one VG name argument required. */
 #define ONE_VGNAME_ARG		0x00000010
+/* Processes foreign VGs by default */
+#define NEEDS_FOREIGN_VGS	0x00000020
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 5e03845..0a6ad6f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -124,8 +124,9 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	backup(vg);
 
-	log_print_unless_silent("%s%colume group \"%s\" successfully created",
-				clustered_message, *clustered_message ? 'v' : 'V', vg->name);
+	log_print_unless_silent("%s%colume group \"%s\" successfully created%s%s",
+				clustered_message, *clustered_message ? 'v' : 'V', vg->name,
+				vg->system_id ? " with system ID " : "", vg->system_id ? : "");
 
 	release_vg(vg);
 	return ECMD_PROCESSED;
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 41fd393..7000284 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -15,7 +15,7 @@
 
 #include "tools.h"
 
-static int vgimport_single(struct cmd_context *cmd __attribute__((unused)),
+static int vgimport_single(struct cmd_context *cmd,
 			   const char *vg_name,
 			   struct volume_group *vg,
 			   struct processing_handle *handle __attribute__((unused)))
@@ -37,7 +37,7 @@ static int vgimport_single(struct cmd_context *cmd __attribute__((unused)),
 		goto_bad;
 
 	vg->status &= ~EXPORTED_VG;
-	vg->system_id = cmd->system_id ? dm_pool_strdup(cmd->mem, cmd->system_id) : NULL;
+	vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
@@ -85,17 +85,6 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 	}
 
-	/*
-	 * Rescan devices and update lvmetad.  lvmetad may hold a copy of the
-	 * VG from before it was exported, if it was exported by another host.
-	 * We need to reread it to see that it's been exported before we can
-	 * import it.
-	 */
-	if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL)) {
-		log_error("Failed to scan devices.");
-		return ECMD_FAILED;
-	}
-
 	return process_each_vg(cmd, argc, argv,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 607f8e0..53f3975 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -570,6 +570,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
 		    !vg_set_alloc_policy(vg_to, vp_new.alloc) ||
 		    !vg_set_clustered(vg_to, vp_new.clustered) ||
+		    !vg_set_system_id(vg_to, vp_new.system_id) ||
 		    !vg_set_mda_copies(vg_to, vp_new.vgmetadatacopies))
 			goto_bad;
 	}


