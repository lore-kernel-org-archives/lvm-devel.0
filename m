From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:04 +0000 (UTC)
Subject: master - tools: add --setactivationskip and --ignoreactivationskip to vgchange/lvchange
Message-ID: <20130712193904.BBB5C60DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab789c1bcfce3e9ad5032ad85b2f8a3171a6dbfb
Commit:        ab789c1bcfce3e9ad5032ad85b2f8a3171a6dbfb
Parent:        7dc8c84b18cbd71f01ce6350759adbca28df5f9b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 11 12:44:36 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 20:49:57 2013 +0200

tools: add --setactivationskip and --ignoreactivationskip to vgchange/lvchange

The lvchange has both -k/--setactivationskip and
-K/--ignoreactivationskip option available for use.

The vgchange has only -K/--ignoreactivationskip, but
not the -k/--setactivationskip as the ACTIVATION_SKIP
flag is an LV property, not a VG one and so we change it
only by using the lvchange...
---
 man/lvchange.8.in |   14 ++++++++++++++
 man/vgchange.8.in |    4 ++++
 tools/commands.h  |   15 ++++++++++-----
 tools/lvchange.c  |   33 ++++++++++++++++++++++++++++++++-
 tools/vgchange.c  |    6 ++++++
 5 files changed, 66 insertions(+), 6 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 44426ef..3b6c574 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -9,6 +9,8 @@ lvchange \- change attributes of a logical volume
 .RI { y | n }]
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]{ y | n }]
+.RB [ \-k | \-\-setactivationskip { y | n } ]
+.RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-C | \-\-contiguous
@@ -78,6 +80,18 @@ To deactivate only on the local node use -aln.
 Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
+.BR \-k ", " \-\-setactivationskip " {" \fIy | \fIn }
+Controls  whether Logical Volumes are persistently flagged to be
+skipped during activation. By default, thin snapshot volumes are
+flagged for activation skip.  To activate such volumes,
+an extra \fB\-K/\-\-ignoreactivationskip\fP option must be used.
+The flag is not applied during deactivation. To see whether
+the flag is attached, use \fBlvs\fP command where the state
+of the flag is reported within \fBlv_attr\fP bits.
+.TP
+.BR \-K ", " \-\-ignoreactivationskip
+Ignore the flag to skip Logical Volumes during activation.
+.TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Tries to set or reset the contiguous allocation policy for
 logical volumes. It's only possible to change a non-contiguous
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index ab76ed0..97042b1 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -12,6 +12,7 @@ vgchange \- change attributes of a volume group
 .RB [ \-a | \-\-activate
 .RI [ a | e | l ]
 .RI { y | n }]
+.RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-monitor
 .RI { y | n }]
 .RB [ \-\-poll
@@ -84,6 +85,9 @@ on the local node.
 Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
+.BR \-K ", " \-\-ignoreactivationskip
+Ignore the flag to skip Logical Volumes during activation.
+.TP
 .BR \-c ", " \-\-clustered " {" \fIy | \fIn }
 If clustered locking is enabled, this indicates whether this
 Volume Group is shared with other nodes in the cluster or whether
diff --git a/tools/commands.h b/tools/commands.h
index 3d076c9..f4fdb0b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -83,6 +83,8 @@ xx(lvchange,
    "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
+   "\t[-k|--setactivationskip {y|n}]\n"
+   "\t[-K|--ignoreactivationskip] \n"
    "\t[--monitor {y|n}]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
@@ -109,7 +111,8 @@ xx(lvchange,
    discards_ARG, detachprofile_ARG, force_ARG, ignorelockingfailure_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG,
    maxrecoveryrate_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
-   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG,
+   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG,
+   setactivationskip_ARG, ignoreactivationskip_ARG, addtag_ARG,
    deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG, writebehind_ARG,
    writemostly_ARG, zero_ARG)
 
@@ -781,6 +784,7 @@ xx(vgchange,
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
+   "\t[-K|--ignoreactivationskip] \n"
    "\t[--monitor {y|n}]\n"
    "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[--poll {y|n}]\n"
@@ -803,10 +807,11 @@ xx(vgchange,
 
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, activate_ARG,
    available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
-   ignorelockingfailure_ARG, ignoremonitoring_ARG, logicalvolume_ARG,
-   maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
-   vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
-   refresh_ARG, resizeable_ARG, resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
+   ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
+   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
+   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
+   physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
+   resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index f4b5d07..b3207d0 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -216,6 +216,12 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 
 	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
+	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0)) {
+		log_verbose("ACTIVATON_SKIP flag set for LV %s/%s, skipping activation.",
+			    lv->vg->name, lv->name);
+		return 1;
+	}
+
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
 		lv = origin_from_cow(lv);
 
@@ -887,6 +893,23 @@ static int lvchange_profile(struct logical_volume *lv)
 	return 1;
 }
 
+static int lvchange_activation_skip(struct logical_volume *lv)
+{
+	int skip = arg_int_value(lv->vg->cmd, setactivationskip_ARG, 0);
+
+	lv_set_activation_skip(lv, 1, skip);
+
+	log_verbose("Changing activation skip flag to %s for LV %s.",
+		    lv->name, skip ? "enabled" : "disabled");
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	backup(lv->vg);
+
+	return 1;
+}
+
 
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
@@ -1059,6 +1082,13 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+	if (arg_count(cmd, setactivationskip_ARG)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+		doit += lvchange_activation_skip(lv);
+		docmds++;
+	}
+
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
 
@@ -1108,7 +1138,8 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, addtag_ARG) ||
 		arg_count(cmd, deltag_ARG) ||
 		arg_count(cmd, profile_ARG) ||
-		arg_count(cmd, detachprofile_ARG);
+		arg_count(cmd, detachprofile_ARG) ||
+		arg_count(cmd, setactivationskip_ARG);
 	int update_partial_unsafe =
 		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
diff --git a/tools/vgchange.c b/tools/vgchange.c
index d3e93f2..d41ef49 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -131,6 +131,12 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			continue;
 		}
 
+		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0)) {
+			log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
+				    lv->vg->name, lv->name);
+			continue;
+		}
+
 		if ((activate == CHANGE_AAY) &&
 		    !lv_passes_auto_activation_filter(cmd, lv))
 			continue;


