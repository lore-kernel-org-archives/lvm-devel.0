From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 08 Jul 2014 21:28:42 -0500
Subject: [PATCH] Add "degraded" activation mode
Message-ID: <1404872922.26102.6.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Here is my suggested patch for "degraded" activation mode.  Without the
ability to create a new cluster flag (e.g. LCK_DEGRADED_MODE), I may
need to rethink the approach.  RAID LVs are not cluster-aware and can
only be activated exclusively in a cluster.  However, activating a RAID
LV in degraded mode would still be impossible if the activation was
going through clvmd.  The user would be forced to use "partial"
activation in a cluster to activate the RAID LV.

 brassow

activation: Add "degraded" activation mode

Currently, we have two modes of activation an unnamed nominal mode
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
extra flag and I am looking for possible solutions.
Index: lvm2/conf/example.conf.in
===================================================================
--- lvm2.orig/conf/example.conf.in
+++ lvm2/conf/example.conf.in
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
Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
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
@@ -2225,9 +2330,18 @@ static int _lv_activate(struct cmd_conte
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
Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -2067,9 +2067,12 @@ int add_areas_line(struct dev_manager *d
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
Index: lvm2/lib/commands/toolcontext.h
===================================================================
--- lvm2.orig/lib/commands/toolcontext.h
+++ lvm2/lib/commands/toolcontext.h
@@ -86,6 +86,7 @@ struct cmd_context {
 	unsigned handles_unknown_segments:1;
 	unsigned use_linear_target:1;
 	unsigned partial_activation:1;
+	unsigned degraded_activation:1;
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
 	unsigned report_binary_values_as_numeric:1;
Index: lvm2/lib/config/config_settings.h
===================================================================
--- lvm2.orig/lib/config/config_settings.h
+++ lvm2/lib/config/config_settings.h
@@ -212,6 +212,7 @@ cfg(activation_use_mlockall_CFG, "use_ml
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL)
 cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL)
+cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL)
 
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL)
 cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL)
Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -163,6 +163,7 @@
 #define DEFAULT_PROCESS_PRIORITY -18
 
 #define DEFAULT_AUTO_SET_ACTIVATION_SKIP 1
+#define DEFAULT_ACTIVATION_MODE "degraded"
 #define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_RAID_REGION_SIZE   512	/* KB */
Index: lvm2/man/lvchange.8.in
===================================================================
--- lvm2.orig/man/lvchange.8.in
+++ lvm2/man/lvchange.8.in
@@ -9,6 +9,8 @@ lvchange \(em change attributes of a log
 .RI { y | n }]
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]{ y | n }]
+.RB [ \-\-activationmode
+.IR { complete | degraded | partial } ]
 .RB [ \-k | \-\-setactivationskip { y | n } ]
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
@@ -18,6 +20,7 @@ lvchange \(em change attributes of a log
 .RB [ \-C | \-\-contiguous
 .RI { y | n }]
 .RB [ \-d | \-\-debug ]
+.RB [ \-\-degraded ]
 .RB [ \-\-deltag
 .IR Tag ]
 .RB [ \-\-detachprofile ]
@@ -97,6 +100,22 @@ To deactivate only on the local node use
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
Index: lvm2/man/vgchange.8.in
===================================================================
--- lvm2.orig/man/vgchange.8.in
+++ lvm2/man/vgchange.8.in
@@ -12,6 +12,8 @@ vgchange \(em change attributes of a vol
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
Index: lvm2/tools/args.h
===================================================================
--- lvm2.orig/tools/args.h
+++ lvm2/tools/args.h
@@ -109,6 +109,8 @@ arg(ignoreskippedcluster_ARG, '\0', "ign
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
 arg(readonly_ARG, '\0', "readonly", NULL, 0)
 arg(atomic_ARG, '\0', "atomic", NULL, 0)
+arg(activationmode_ARG, '\0', "activationmode", string_arg, 0)
+
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: lvm2/tools/commands.h
===================================================================
--- lvm2.orig/tools/commands.h
+++ lvm2/tools/commands.h
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
Index: lvm2/tools/lvmcmdline.c
===================================================================
--- lvm2.orig/tools/lvmcmdline.c
+++ lvm2/tools/lvmcmdline.c
@@ -866,6 +866,8 @@ int version(struct cmd_context *cmd __at
 
 static int _get_settings(struct cmd_context *cmd)
 {
+	const char *activation_mode;
+
 	cmd->current_settings = cmd->default_settings;
 
 	if (arg_count(cmd, debug_ARG))
@@ -903,10 +905,34 @@ static int _get_settings(struct cmd_cont
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
Index: lvm2/tools/toollib.c
===================================================================
--- lvm2.orig/tools/toollib.c
+++ lvm2/tools/toollib.c
@@ -1431,7 +1431,8 @@ int lv_change_activate(struct cmd_contex
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
-		log_error("Refusing refresh of partial LV %s. Use --partial to override.",
+		log_error("Refusing refresh of partial LV %s."
+			  " Use '--activationmode partial' to override.",
 			  lv->name);
 		return 0;
 	}
Index: lvm2/test/shell/lvchange-activationmode.sh
===================================================================
--- /dev/null
+++ lvm2/test/shell/lvchange-activationmode.sh
@@ -0,0 +1,139 @@
+#!/bin/bash
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+# No cluster support until LCK_DEGRADED_MODE is implemented
+test -e LOCAL_CLVMD && skip
+
+aux have_raid 1 3 2 || skip
+
+aux prepare_vg 4
+
+lvcreate -l 1 -n linear $vg "$dev1"
+lvcreate --type raid1 -m 1 -l 1 -n raid1 $vg "$dev1" "$dev2"
+lvcreate --type raid5 -i 2 -l 2 -n raid5 $vg "$dev1" "$dev2" "$dev3"
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+
+# Device failure affects all LVs
+# Only "--partial | --activationmode partial" will activate linear
+# "--activationmode partial|degraded" will activate raid[15]
+aux disable_dev "$dev1"
+not lvchange -aey $vg/linear --activationmode complete
+not lvchange -aey $vg/linear --activationmode degraded
+lvchange -aey $vg/linear --activationmode partial
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+
+not lvchange -aey $vg/raid1 --activationmode complete
+lvchange -aey $vg/raid1 --activationmode degraded
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+lvchange -aey $vg/raid1 --activationmode partial
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+
+not lvchange -aey $vg/raid5 --activationmode complete
+lvchange -aey $vg/raid5 --activationmode degraded
+check lv_attr_bit state $vg/raid5 "a"
+lvchange -an $vg/raid5
+lvchange -aey $vg/raid5 --activationmode partial
+check lv_attr_bit state $vg/raid5 "a"
+lvchange -an $vg/raid5
+
+aux enable_dev "$dev1"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+# Device failure affects only RAID LVs
+# Anything should activate linear
+# "--activationmode partial|degraded" will activate raid[15]
+aux disable_dev "$dev2"
+lvchange -aey $vg/linear --activationmode complete
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+lvchange -aey $vg/linear --activationmode degraded
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+lvchange -aey $vg/linear --activationmode partial
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+
+not lvchange -aey $vg/raid1 --activationmode complete
+check lv_attr_bit state $vg/raid1 "-"
+lvchange -aey $vg/raid1 --activationmode degraded
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+lvchange -aey $vg/raid1 --activationmode partial
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+
+not lvchange -aey $vg/raid5 --activationmode complete
+check lv_attr_bit state $vg/raid5 "-"
+lvchange -aey $vg/raid5 --activationmode degraded
+check lv_attr_bit state $vg/raid5 "a"
+lvchange -an $vg/raid5
+lvchange -aey $vg/raid5 --activationmode partial
+check lv_attr_bit state $vg/raid5 "a"
+lvchange -an $vg/raid5
+
+aux enable_dev "$dev2"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+# Device failure affects only RAID5
+# Anything should activate linear
+# Anything should activate raid1
+# "--activationmode partial|degraded" will activate raid5
+aux disable_dev "$dev3"
+lvchange -aey $vg/linear --activationmode complete
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+lvchange -aey $vg/linear --activationmode degraded
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+lvchange -aey $vg/linear --activationmode partial
+check lv_attr_bit state $vg/linear "a"
+lvchange -an $vg/linear
+
+lvchange -aey $vg/raid1 --activationmode complete
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+lvchange -aey $vg/raid1 --activationmode degraded
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+lvchange -aey $vg/raid1 --activationmode partial
+check lv_attr_bit state $vg/raid1 "a"
+lvchange -an $vg/raid1
+
+not lvchange -aey $vg/raid5 --activationmode complete
+check lv_attr_bit state $vg/raid5 "-"
+lvchange -aey $vg/raid5 --activationmode degraded
+check lv_attr_bit state $vg/raid5 "a"
+lvchange -an $vg/raid5
+lvchange -aey $vg/raid5 --activationmode partial
+check lv_attr_bit state $vg/raid5 "a"
+lvchange -an $vg/raid5
+
+aux enable_dev "$dev3"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+# FIXME: Test "degraded | partial" with too many failures for RAID
Index: lvm2/test/shell/vgchange-activationmode.sh
===================================================================
--- /dev/null
+++ lvm2/test/shell/vgchange-activationmode.sh
@@ -0,0 +1,247 @@
+#!/bin/bash
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+# No cluster support until LCK_DEGRADED_MODE is implemented
+test -e LOCAL_CLVMD && skip
+
+aux have_thin 1 0 0 || skip
+aux have_raid 1 3 2 || skip
+
+aux prepare_vg 4
+
+lvcreate -l 1 -n linear $vg "$dev1"
+lvcreate --nosync --type raid1 -m 1 -l 1 -n raid1 $vg "$dev1" "$dev2"
+lvcreate --nosync --type raid5 -i 2 -l 2 -n raid5 $vg "$dev1" "$dev2" "$dev3"
+vgchange -an $vg
+
+#
+# REMEMBER:  A vgchange that fails to activate any LVs returns an error
+#
+
+
+# Device failure affects all LVs
+# Only "--partial | --activationmode partial" will activate linear
+# "--activationmode partial|degraded" will activate raid[15]
+aux disable_dev "$dev1"
+not vgchange -aey $vg --activationmode complete
+check lv_attr_bit state $vg/linear "-"
+check lv_attr_bit state $vg/raid1 "-"
+check lv_attr_bit state $vg/raid5 "-"
+not vgchange -aey $vg --activationmode degraded
+check lv_attr_bit state $vg/linear "-"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "a"
+vgchange -an $vg
+vgchange -aey $vg --activationmode partial
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "a"
+vgchange -an $vg
+
+aux enable_dev "$dev1"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+# Device failure affects only RAID LVs
+# Anything should activate linear
+# "--activationmode partial|degraded" will activate raid[15]
+aux disable_dev "$dev2"
+not vgchange -aey $vg --activationmode complete
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "-"
+check lv_attr_bit state $vg/raid5 "-"
+vgchange -an $vg
+vgchange -aey $vg --activationmode degraded
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "a"
+vgchange -an $vg
+vgchange -aey $vg --activationmode partial
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "a"
+vgchange -an $vg
+
+aux enable_dev "$dev2"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+
+# Device failure affects only RAID5
+# Anything should activate linear
+# Anything should activate raid1
+# "--activationmode partial|degraded" will activate raid5
+aux disable_dev "$dev3"
+not vgchange -aey $vg --activationmode complete
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "-"
+vgchange -an $vg
+vgchange -aey $vg --activationmode degraded
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "a"
+vgchange -an $vg
+vgchange -aey $vg --activationmode partial
+check lv_attr_bit state $vg/linear "a"
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "a"
+vgchange -an $vg
+
+aux enable_dev "$dev3"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+
+
+#
+# Bad activationmode argument
+#
+not vgchange -aey $vg --activationmode badarg
+
+
+#
+# '--partial' is mutually exclusive with '--activationmode complete|degraded'
+#
+not vgchange -aey $vg --partial --activationmode complete
+not vgchange -aey $vg --partial --activationmode degraded
+vgchange -aey $vg --partial --activationmode partial
+vgchange -an $vg
+
+
+#
+# '--config' should be overridden by '--activationmode'
+#
+aux disable_dev "$dev1"
+for config in "complete" "degraded" "partial"; do
+    for mode in "complete" "degraded" "partial"; do
+	echo "config = $config, mode = $mode"
+	full_config="--config 'activation { activation_mode = \"$config\" }'"
+	full_mode="--activationmode $mode"
+	if [ $mode -eq "partial" ]; then
+	    vgchange -aey $vg $full_mode $full_config
+	    check lv_attr_bit state $vg/linear "a"
+	    check lv_attr_bit state $vg/raid1 "a"
+	    check lv_attr_bit state $vg/raid5 "a"
+	elif [ $mode -eq "degraded" ]; then
+	    not vgchange -aey $vg $full_mode $full_config
+	    check lv_attr_bit state $vg/linear "-"
+	    check lv_attr_bit state $vg/raid1 "a"
+	    check lv_attr_bit state $vg/raid5 "a"
+	else
+	    not vgchange -aey $vg $full_mode $full_config
+	    check lv_attr_bit state $vg/linear "-"
+	    check lv_attr_bit state $vg/raid1 "-"
+	    check lv_attr_bit state $vg/raid5 "-"
+	fi
+    done
+done
+
+aux enable_dev "$dev1"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+vgchange -an $vg
+lvremove -ff $vg
+
+
+#
+# Test thin on degraded RAID
+#
+lvcreate -aey --nosync -L10M --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey --nosync -L8M --type raid1 -m 1 -n $lv2 $vg "$dev3" "$dev4"
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+vgchange -an $vg
+
+aux disable_dev "$dev1"
+aux disable_dev "$dev3"
+
+not vgchange -aey $vg --activationmode complete
+vgchange -an $vg
+vgchange -aey $vg --activationmode degraded
+vgchange -an $vg
+vgchange -aey $vg --activationmode partial
+vgchange -an $vg
+
+aux enable_dev "$dev1"
+aux enable_dev "$dev3"
+lvremove -ff $vg
+
+#
+# Test "degraded" with too many failures for RAID
+#  - raid1/5 should fail to activate (unless "--activationmode partial")
+#  - raid10 should succeed when dev{1,3} are failed, but fail to
+#    activate when dev{1,2} are failed.
+#
+# FIXME:  Improve this test.
+#         1) Distinguish between the two different controled failures.
+#            "complete" should fail because the LVs are PARTIAL_LV
+#            "degraded" should fail because there are too many failed RAID LVs
+#         2) Partial should succeed, but the unrecoverable portions of the
+#            RAID LV should be replaced with error target.
+lvcreate --nosync --type raid1 -m 1 -l 1 -n raid1 $vg "$dev1"         "$dev3"
+lvcreate --nosync --type raid5 -i 2 -l 2 -n raid5 $vg "$dev1" "$dev2" "$dev3"
+lvcreate --nosync --type raid10 -i 2 -m 1 -l 4 -n raid10 $vg \
+    "$dev1" "$dev2" "$dev3" "$dev4"
+vgchange -an $vg
+aux disable_dev "$dev1"
+aux disable_dev "$dev3"
+not vgchange -aey $vg --activationmode complete
+check lv_attr_bit state $vg/raid1 "-"
+check lv_attr_bit state $vg/raid5 "-"
+check lv_attr_bit state $vg/raid10 "-"
+
+dmsetup ls
+
+not vgchange -aey $vg --activationmode degraded
+check lv_attr_bit state $vg/raid1 "-"
+check lv_attr_bit state $vg/raid5 "-"
+check lv_attr_bit state $vg/raid10 "a"
+vgchange -an $vg
+
+dmsetup ls
+
+# "--activationmode partial" of RAID LVs that have insufficient redundancy
+# does not work and has never worked.  It leaves behind all kinds of DM
+# sub-devices - failing to clean-up properly.
+#vgchange -aey $vg --activationmode partial
+#check lv_attr_bit state $vg/raid1 "a"
+#check lv_attr_bit state $vg/raid5 "a"
+#check lv_attr_bit state $vg/raid10 "a"
+
+aux enable_dev "$dev1"
+aux enable_dev "$dev3"
+vgchange -aey $vg
+aux wait_for_sync $vg raid1
+aux wait_for_sync $vg raid5
+aux wait_for_sync $vg raid10
+vgchange -an $vg
+
+dmsetup ls
+
+aux disable_dev "$dev1"
+aux disable_dev "$dev2"
+not vgchange -aey $vg --activationmode degraded
+check lv_attr_bit state $vg/raid1 "a"
+check lv_attr_bit state $vg/raid5 "-"
+check lv_attr_bit state $vg/raid10 "-"
+vgchange -an $vg
+
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+lvremove -ff $vg



