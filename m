From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 10 Jul 2014 03:58:12 +0000 (UTC)
Subject: master - activation: Add "degraded" activation mode
Message-ID: <20140710035812.4EB806016C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be75076dfc842945a03fa42073e9e03f51bd3a3c
Commit:        be75076dfc842945a03fa42073e9e03f51bd3a3c
Parent:        a098cba0ebbd0682570cff2fc756a59533321f03
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jul 9 22:56:11 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jul 9 22:56:11 2014 -0500

activation: Add "degraded" activation mode

Currently, we have two modes of activation, an unnamed nominal mode
(which I will refer to as "complete") and "partial" mode.  The
"complete" mode requires that a volume group be 'complete' - that
is, no missing PVs.  If there are any missing PVs, no affected LVs
are allowed to activate - even RAID LVs which might be able to
tolerate a failure.  The "partial" mode allows anything to be
activated (or at least attempted).  If a non-redundant LV is
missing a portion of its addressable space due to a device failure,
it will be replaced with an error target.  RAID LVs will either
activate or fail to activate depending on how badly their
redundancy is compromised.

This patch adds a third option, "degraded" mode.  This mode can
be selected via the '--activationmode {complete|degraded|partial}'
option to lvchange/vgchange.  It can also be set in lvm.conf.
The "degraded" activation mode allows RAID LVs with a sufficient
level of redundancy to activate (e.g. a RAID5 LV with one device
failure, a RAID6 with two device failures, or RAID1 with n-1
failures).  RAID LVs with too many device failures are not allowed
to activate - nor are any non-redundant LVs that may have been
affected.  This patch also makes the "degraded" mode the default
activation mode.

The degraded activation mode does not yet work in a cluster.  A
new cluster lock flag (LCK_DEGRADED_MODE) will need to be created
to make that work.  Currently, there is limited space for this
extra flag and I am looking for possible solutions.  One possible
solution is to usurp LCK_CONVERT, as it is not used.  When the
locking_type is 3, the degraded mode flag simply gets dropped and
the old ("complete") behavior is exhibited.
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   25 +++++++++
 lib/activate/activate.c      |  120 ++++++++++++++++++++++++++++++++++++++++-
 lib/activate/dev_manager.c   |    9 ++-
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |    1 +
 lib/config/defaults.h        |    1 +
 man/lvchange.8.in            |   19 +++++++
 man/vgchange.8.in            |   18 ++++++
 tools/args.h                 |    2 +
 tools/commands.h             |    8 ++-
 tools/lvmcmdline.c           |   28 +++++++++-
 tools/toollib.c              |    3 +-
 13 files changed, 226 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 21668f2..29a0aa3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Add "degraded" activation mode and make it the default.
   Add separate lv_active_{locally,remotely,exclusively} LV reporting fields.
   Recognize "auto"/"unmanaged" values in selection for appropriate fields only.
   Add report/binary_values_as_numeric lvm.conf option for binary values as 0/1.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index e1afbb6..11f50f0 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1011,6 +1011,31 @@ activation {
     # are no progress reports, but the process is awoken immediately the
     # operation is complete.
     polling_interval = 15
+
+    # 'activation_mode' determines how logical volumes are activated if
+    # devices are missing.  Possible settings are:
+    #
+    #	"complete" -  Only allow activation of an LV if all of the PVs
+    #		      that it uses are available (i.e. the volume group
+    #		      is complete).  There may be a failed PV in the
+    #		      volume group; but if a particular LV is not on that
+    #		      PV, it is still allowed to activate in this mode.
+    #
+    #	"degraded" -  Like "complete", except that RAID logical volumes of
+    #		      segment type "raid{1,4,5,6,10}" are activated if
+    #		      they have sufficient redundancy to present the entire
+    #		      addressable range of the logical volume.
+    #
+    #	"partial"  -  Allow activation for any logical volume - even if
+    #		      a missing or failed PV would cause a portion of the
+    #		      logical volume to be inaccessible.  (E.g. a stripe
+    #		      volume that has lost one of its members would be
+    #		      unable to access a portion of the logical volume.)
+    #		      This setting is not recommended for normal use.
+    #
+    # This setting was introduced in LVM version 2.02.108.  It corresponds
+    # with the '--activationmode' option for lvchange and vgchange.
+    activation_mode = "degraded"
 }
 
 # Report settings.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index adaff52..70777fd 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2203,6 +2203,111 @@ out:
 	return r;
 }
 
+static int _lv_raid_is_redundant(struct logical_volume *lv)
+{
+	struct lv_segment *raid_seg = first_seg(lv);
+	uint32_t copies;
+	uint32_t i, s, rebuilds_per_group = 0;
+	uint32_t failed_components = 0;
+
+	if (!(lv->status & PARTIAL_LV)) {
+		/*
+		 * Redundant, but this function shouldn't
+		 * be called in this case.
+		 */
+		log_error(INTERNAL_ERROR "%s is not a partial LV", lv->name);
+		return 1;
+	}
+
+	if (!lv_is_raid(lv))
+		return 0; /* Not RAID, not redundant */
+
+	if (!strcmp(raid_seg->segtype->name, "raid10")) {
+                /* FIXME: We only support 2-way mirrors in RAID10 currently */
+		copies = 2;
+                for (i = 0; i < raid_seg->area_count * copies; i++) {
+                        s = i % raid_seg->area_count;
+                        if (!(i % copies))
+                                rebuilds_per_group = 0;
+                        if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
+                            (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+                            lv_is_virtual(seg_lv(raid_seg, s)) ||
+                            lv_is_virtual(seg_metalv(raid_seg, s)))
+                                rebuilds_per_group++;
+                        if (rebuilds_per_group >= copies) {
+				log_debug("An entire mirror group "
+					  "has failed in %s", lv->name);
+                                return 0; /* Not redundant */
+			}
+                }
+		return 1; /* Redundant */
+        }
+
+	for (s = 0; s < raid_seg->area_count; s++) {
+		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
+		    (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+		    lv_is_virtual(seg_lv(raid_seg, s)) ||
+		    lv_is_virtual(seg_metalv(raid_seg, s)))
+			failed_components++;
+	}
+        if (failed_components == raid_seg->area_count) {
+		log_debug("All components in %s have failed", lv->name);
+                return 0;
+        } else if (raid_seg->segtype->parity_devs &&
+                   (failed_components > raid_seg->segtype->parity_devs)) {
+                log_debug("More than %u components from (%s) %s/%s have failed",
+                          raid_seg->segtype->parity_devs,
+                          raid_seg->segtype->ops->name(raid_seg),
+                          lv->vg->name, lv->name);
+                return 0;
+        }
+
+	return 1;
+}
+
+static int _lv_is_not_degraded_capable(struct logical_volume *lv, void *data)
+{
+	int *not_capable = (int *)data;
+	uint32_t s;
+	struct lv_segment *seg;
+
+	if (!(lv->status & PARTIAL_LV))
+		return 1;
+
+	if (lv_is_raid(lv))
+		return _lv_raid_is_redundant(lv);
+
+	/* Ignore RAID sub-LVs. */
+	if (lv_is_raid_type(lv))
+		return 1;
+
+	dm_list_iterate_items(seg, &lv->segments)
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_type(seg, s) != AREA_LV) {
+				log_debug("%s is not capable of degraded mode",
+					  lv->name);
+				*not_capable = 1;
+			}
+
+	return 1;
+}
+
+static int lv_is_degraded_capable(struct logical_volume *lv)
+{
+	int not_capable = 0;
+
+	if (!(lv->status & PARTIAL_LV))
+		return 1;
+
+	if (!_lv_is_not_degraded_capable(lv, &not_capable) || not_capable)
+		return 0;
+
+	if (!for_each_sub_lv(lv, _lv_is_not_degraded_capable, &not_capable))
+		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
+
+	return !not_capable;
+}
+
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 			struct lv_activate_opts *laopts, int filter,
 	                struct logical_volume *lv)
@@ -2225,9 +2330,18 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	}
 
 	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
-		log_error("Refusing activation of partial LV %s. Use --partial to override.",
-			  lv->name);
-		goto out;
+		if (!lv_is_degraded_capable(lv)) {
+			log_error("Refusing activation of partial LV %s.  "
+				  "Use '--activationmode partial' to override.",
+				  lv->name);
+			goto out;
+		} else if (!lv->vg->cmd->degraded_activation) {
+			log_error("Refusing activation of partial LV %s.  "
+				  "Try '--activationmode degraded'.",
+				  lv->name);
+			goto out;
+		}
+		log_print_unless_silent("Attempting activation of partial RAID LV, %s.", lv->name);
 	}
 
 	if (lv_has_unknown_segments(lv)) {
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e30b176..0305bb4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2067,9 +2067,12 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 		       stat(name, &info) < 0 || !S_ISBLK(info.st_mode))) ||
 		    (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s))) {
 			if (!seg->lv->vg->cmd->partial_activation) {
-				log_error("Aborting.  LV %s is now incomplete "
-					  "and --partial was not specified.", seg->lv->name);
-				return 0;
+				if (!seg->lv->vg->cmd->degraded_activation ||
+				    !lv_is_raid_type(seg->lv)) {
+					log_error("Aborting.  LV %s is now incomplete "
+						  "and '--activationmode partial' was not specified.", seg->lv->name);
+					return 0;
+				}
 			}
 			if (!_add_error_area(dm, node, seg, s))
 				return_0;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 162af55..d06dd7d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -86,6 +86,7 @@ struct cmd_context {
 	unsigned handles_unknown_segments:1;
 	unsigned use_linear_target:1;
 	unsigned partial_activation:1;
+	unsigned degraded_activation:1;
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
 	unsigned report_binary_values_as_numeric:1;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2ddf888..7289a04 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -212,6 +212,7 @@ cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL)
 cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL)
+cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL)
 
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL)
 cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 4200dc8..086f7fd 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -163,6 +163,7 @@
 #define DEFAULT_PROCESS_PRIORITY -18
 
 #define DEFAULT_AUTO_SET_ACTIVATION_SKIP 1
+#define DEFAULT_ACTIVATION_MODE "degraded"
 #define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_RAID_REGION_SIZE   512	/* KB */
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index f7aee8f..39187f0 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -9,6 +9,8 @@ lvchange \(em change attributes of a logical volume
 .RI { y | n }]
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]{ y | n }]
+.RB [ \-\-activationmode
+.IR { complete | degraded | partial } ]
 .RB [ \-k | \-\-setactivationskip { y | n } ]
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
@@ -18,6 +20,7 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-C | \-\-contiguous
 .RI { y | n }]
 .RB [ \-d | \-\-debug ]
+.RB [ \-\-degraded ]
 .RB [ \-\-deltag
 .IR Tag ]
 .RB [ \-\-detachprofile ]
@@ -97,6 +100,22 @@ To deactivate only on the local node use -aln.
 Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
+.BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
+The activation mode determines whether logical volumes are allowed to
+activate when there are physical volumes missing (e.g. due to a device
+failure).  \fIcomplete is the most restrictive; allowing only those
+logical volumes to be activated that are not affected by the missing
+PVs.  \fIdegraded allows RAID logical volumes to be activated even if
+they have PVs missing.  (Note that the "mirror" segment type is not
+considered a RAID logical volume.  The "raid1" segment type should
+be used instead.)  Finally, \fIpartial allows any logical volume to
+be activated even if portions are missing due to a missing or failed
+PV.  This last option should only be used when performing recovery or
+repair operations.  \fIdegraded is the default mode.  To change it, modify
+.B activation_mode
+in
+.BR lvm.conf (5).
+.TP
 .BR \-k ", " \-\-setactivationskip " {" \fIy | \fIn }
 Controls  whether Logical Volumes are persistently flagged to be
 skipped during activation. By default, thin snapshot volumes are
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 9ea2f65..150b77d 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -12,6 +12,8 @@ vgchange \(em change attributes of a volume group
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]
 .RI { y | n }]
+.RB [ \-\-activationmode
+.IR { complete | degraded | partial } ]
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-monitor
 .RI { y | n }]
@@ -98,6 +100,22 @@ on the local node.
 Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
+.BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
+The activation mode determines whether logical volumes are allowed to
+activate when there are physical volumes missing (e.g. due to a device
+failure).  \fIcomplete is the most restrictive; allowing only those
+logical volumes to be activated that are not affected by the missing
+PVs.  \fIdegraded allows RAID logical volumes to be activated even if
+they have PVs missing.  (Note that the "mirror" segment type is not
+considered a RAID logical volume.  The "raid1" segment type should
+be used instead.)  Finally, \fIpartial allows any logical volume to
+be activated even if portions are missing due to a missing or failed
+PV.  This last option should only be used when performing recovery or
+repair operations.  \fIdegraded is the default mode.  To change it, modify
+.B activation_mode
+in
+.BR lvm.conf (5).
+.TP
 .BR \-K ", " \-\-ignoreactivationskip
 Ignore the flag to skip Logical Volumes during activation.
 .TP
diff --git a/tools/args.h b/tools/args.h
index d4a8643..9632478 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -109,6 +109,8 @@ arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
 arg(readonly_ARG, '\0', "readonly", NULL, 0)
 arg(atomic_ARG, '\0', "atomic", NULL, 0)
+arg(activationmode_ARG, '\0', "activationmode", string_arg, 0)
+
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 7d36bc5..5fae835 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -103,6 +103,7 @@ xx(lvchange,
    "lvchange\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-a|--activate [a|e|l]{y|n}]\n"
+   "\t[--activationmode {complete|degraded|partial}"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
@@ -141,7 +142,8 @@ xx(lvchange,
    "\t[-Z|--zero {y|n}]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
+   activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
+   available_ARG,
    contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
@@ -933,6 +935,7 @@ xx(vgchange,
    "\t[-v|--verbose] " "\n"
    "\t[--version]" "\n"
    "\t{-a|--activate [a|e|l]{y|n}  |" "\n"
+   "\t[--activationmode {complete|degraded|partial}]" "\n"
    "\t -c|--clustered {y|n} |" "\n"
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
@@ -942,7 +945,8 @@ xx(vgchange,
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
 
-   addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, activate_ARG,
+   activationmode_ARG, addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG,
+   activate_ARG,
    available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
    ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    ignoreskippedcluster_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 780e9d0..fc51c4a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -866,6 +866,8 @@ int version(struct cmd_context *cmd __attribute__((unused)),
 
 static int _get_settings(struct cmd_context *cmd)
 {
+	const char *activation_mode;
+
 	cmd->current_settings = cmd->default_settings;
 
 	if (arg_count(cmd, debug_ARG))
@@ -903,10 +905,34 @@ static int _get_settings(struct cmd_context *cmd)
 	}
 
 	cmd->partial_activation = 0;
+	cmd->degraded_activation = 0;
+	activation_mode = find_config_tree_str(cmd, activation_mode_CFG, NULL);
+	if (!activation_mode)
+		activation_mode = DEFAULT_ACTIVATION_MODE;
+
+	if (arg_count(cmd, activationmode_ARG)) {
+		activation_mode = arg_str_value(cmd, activationmode_ARG,
+						activation_mode);
+
+		/* complain only if the two arguments conflict */
+		if (arg_count(cmd, partial_ARG) &&
+		    strcmp(activation_mode, "partial")) {
+			log_error("--partial and --activationmode are mutually"
+				  " exclusive arguments");
+			return EINVALID_CMD_LINE;
+		}
+	} else if (arg_count(cmd, partial_ARG))
+		activation_mode = "partial";
 
-	if (arg_count(cmd, partial_ARG)) {
+	if (!strcmp(activation_mode, "partial")) {
 		cmd->partial_activation = 1;
 		log_warn("PARTIAL MODE. Incomplete logical volumes will be processed.");
+	} else if (!strcmp(activation_mode, "degraded")) {
+		cmd->degraded_activation = 1;
+		log_debug("DEGRADED MODE. Incomplete RAID LVs will be processed.");
+	} else if (strcmp(activation_mode, "complete")) {
+		log_error("Invalid activation mode given.");
+		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))
diff --git a/tools/toollib.c b/tools/toollib.c
index d4c915d..34db90c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1431,7 +1431,8 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
-		log_error("Refusing refresh of partial LV %s. Use --partial to override.",
+		log_error("Refusing refresh of partial LV %s."
+			  " Use '--activationmode partial' to override.",
 			  lv->name);
 		return 0;
 	}


