From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jul 2012 12:39:24 +0000 (UTC)
Subject: master - thin: add lvchange for discard and zero change
Message-ID: <20120718123924.478ADBBF@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48367c5be9b39cd118caeb6b8e554be347d2fd8c
Commit:        48367c5be9b39cd118caeb6b8e554be347d2fd8c
Parent:        46b9cc1248941cc43f953e1a6b285ebe64a62077
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 28 14:52:23 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 18 14:38:34 2012 +0200

thin: add lvchange for discard and zero change

Update lvchange to allow change of 'zero' flag for thinpool.
Add support for changing discard handling.

N.B.  from/to  ignore could be only changed for inactive pool.
---
 WHATS_NEW         |    1 +
 man/lvchange.8.in |   14 ++++++++-
 tools/commands.h  |    7 +++-
 tools/lvchange.c  |   88 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 106 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7811b6d..925ae23 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Support changing of discard and zeroing for thin pool.
   Report used discard for thin pool and volume.
   Add support for controlling discard behavior of thin pool.
   Detect features for new 1.1 thin pool target.
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index bf9ef48..beb77a8 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -16,6 +16,8 @@ lvchange \- change attributes of a logical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
+.RB [ \-\-discard
+.RI { ignore | nopassdown | passdown }]
 .RB [ \-\-resync ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
@@ -37,7 +39,9 @@ lvchange \- change attributes of a logical volume
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-\-refresh ]
 .RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
 .I LogicalVolumePath
 .RI [ LogicalVolumePath ...]
 .SH DESCRIPTION
@@ -68,6 +72,9 @@ logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
+.BR \-\-discard " {" \fIignore | \fInopassdown | \fIpassdown }
+Change discard behavior.
+.TP
 .B \-\-resync
 Forces the complete resynchronization of a mirror.  In normal
 circumstances you should not need this option because synchronization
@@ -142,6 +149,11 @@ If the logical volume is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
+.TP
+.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
+Set zeroing mode for thin pool. Note: already provisioned blocks from pool
+in non-zero mode are not cleared in unwritten parts when setting zero to
+\fIy\fP.
 .SH Examples
 Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .sp
diff --git a/tools/commands.h b/tools/commands.h
index fe7403d..88c170a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -69,6 +69,7 @@ xx(lvchange,
    "\t[--deltag Tag]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--discard {ignore|nopassdown|passdown}]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
@@ -84,14 +85,16 @@ xx(lvchange,
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
+   "\t[-Z|--zero {y|n}]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
    force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG,
    minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
    persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG,
-   addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG)
+   addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG,
+   discard_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 9054ac7..a24d26c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -89,6 +89,77 @@ out:
 	return r;
 }
 
+static int lvchange_pool_update(struct cmd_context *cmd,
+				struct logical_volume *lv)
+{
+	int r = 0;
+	int update = 0;
+	unsigned val;
+	thin_discard_t discard;
+
+	if (!lv_is_thin_pool(lv)) {
+		log_error("Logical volume \"%s\" is not a thinpool.", lv->name);
+		return 0;
+	}
+
+	if (arg_count(cmd, discard_ARG)) {
+		discard = arg_uint_value(cmd, discard_ARG, 0);
+		if (discard != first_seg(lv)->discard) {
+			if (((discard == THIN_DISCARD_IGNORE) ||
+			     (first_seg(lv)->discard == THIN_DISCARD_IGNORE)) &&
+			    lv_is_active(lv))
+				log_error("Cannot change discard state for active "
+					  "logical volume \"%s\".", lv->name);
+			else {
+				first_seg(lv)->discard = discard;
+				update++;
+			}
+		} else
+			log_error("Logical volume \"%s\" already uses discard %s.",
+				  lv->name, get_pool_discard_name(discard));
+	}
+
+	if (arg_count(cmd, zero_ARG)) {
+		val = arg_uint_value(cmd, zero_ARG, 1);
+		if (val != first_seg(lv)->zero_new_blocks) {
+			first_seg(lv)->zero_new_blocks = val;
+			update++;
+		} else
+			log_error("Logical volume \"%s\" already %szero new blocks.",
+				  lv->name, val ? "" : "does not ");
+	}
+
+	if (!update)
+		return 0;
+
+	log_very_verbose("Updating logical volume \"%s\" on disk(s).", lv->name);
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!suspend_lv_origin(cmd, lv)) {
+		log_error("Failed to update active %s/%s (deactivation is needed).",
+			  lv->vg->name, lv->name);
+		vg_revert(lv->vg);
+		goto out;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv_origin(cmd, lv))
+			stack;
+		goto_out;
+	}
+
+	if (!resume_lv_origin(cmd, lv)) {
+		log_error("Problem reactivating %s.", lv->name);
+		goto out;
+	}
+
+	r = 1;
+out:
+	backup(lv->vg);
+	return r;
+}
+
 static int lvchange_monitoring(struct cmd_context *cmd,
 			       struct logical_volume *lv)
 {
@@ -545,6 +616,8 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
+	     arg_count(cmd, discard_ARG) ||
+	     arg_count(cmd, zero_ARG) ||
 	     arg_count(cmd, alloc_ARG))) {
 		log_error("Only -a permitted with read-only volume "
 			  "group \"%s\"", lv->vg->name);
@@ -670,6 +743,17 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (arg_count(cmd, discard_ARG) ||
+	    arg_count(cmd, zero_ARG)) {
+		if (!archived && !archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		archived = 1;
+		doit += lvchange_pool_update(cmd, lv);
+		docmds++;
+	}
+
 	/* add tag */
 	if (arg_count(cmd, addtag_ARG)) {
 		if (!archived && !archive(lv->vg)) {
@@ -747,7 +831,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
-		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG);
+		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG) ||
+		arg_count(cmd, discard_ARG) ||
+		arg_count(cmd, zero_ARG);
 
 	if (!update &&
             !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&


