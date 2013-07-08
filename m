From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:56 +0200
Subject: [PATCH 4/7] thin: add lvchange spare lv manipulation
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <04c1e2d134def3ffda8889b7f476550ee9ec5f1e.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow lvchange of pool metadata spare flag for the LV.

User could remove flag from already existing spare LV
(--poolmetadata n) - needs to specify name of invisible LV.

Also it's possible to select any other LV name and replace
the existing spare LV with a new LV.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/lvchange.8.in |  5 ++++
 tools/args.h      |  1 +
 tools/commands.h  |  4 ++-
 tools/lvchange.c  | 79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 87 insertions(+), 2 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 44426ef..5e23b7c 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -44,6 +44,8 @@ lvchange \- change attributes of a logical volume
 .RB [ \-P | \-\-partial ]
 .RB [ \-p | \-\-permission
 .RI { r | rw }]
+.RB [ \-\-poolmetadataspare
+.RI { y | n }]
 .RB [ \-r | \-\-readahead
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-\-refresh ]
@@ -182,6 +184,9 @@ Set to y to make the minor number specified persistent.
 .BR \-p ", " \-\-permission " {" \fIr | \fIrw }
 Change access permission to read-only or read/write.
 .TP
+.IR \fB\-\-poolmetadataspare " {" y | n }
+Change status of pool metadata spare volume.
+.TP
 .BR \-r ", " \-\-readahead " {" \fIReadAheadSectors | \fIauto | \fInone }
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
diff --git a/tools/args.h b/tools/args.h
index 73312ca..2768640 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -74,6 +74,7 @@ arg(originname_ARG, '\0', "originname", string_arg, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
+arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0)
 arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index f84aa35..89d8764 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -93,6 +93,7 @@ xx(lvchange,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[--poolmetadataspare {y|n}]\n"
    "\t[--syncaction {check|repair}\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
@@ -108,7 +109,8 @@ xx(lvchange,
    discards_ARG, detachprofile_ARG, force_ARG, ignorelockingfailure_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG,
    maxrecoveryrate_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
-   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG,
+   persistent_ARG, poll_ARG, poolmetadataspare_ARG,
+   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG,
    deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG, writebehind_ARG,
    writemostly_ARG, zero_ARG)
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index f7ce7fd..13b2e22 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -101,6 +101,73 @@ out:
 	return r;
 }
 
+static int _lvchange_spare(struct cmd_context *cmd,
+			   struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+	uint64_t max_size = 0;
+	unsigned spare = arg_uint_value(cmd, poolmetadataspare_ARG, 0);
+
+	if (lv_is_active(lv)) {
+		log_error("Cannot change pool metadata spare status for active logical volume \"%s\".",
+			  lv->name);
+		return 0;
+	}
+
+	if (!spare) {
+		if (!lv_is_pool_metadata_spare(lv)) {
+			log_error("Logical volume \"%s\" is not a pool metadata spare volume.",
+				  lv->name);
+			return 0;
+		}
+
+		if (!vg_remove_pool_metadata_spare(lv->vg))
+			return_0;
+	} else {
+		if (lv_is_pool_metadata_spare(lv)) {
+			log_error("Logical volume \"%s\" is already pool metadata spare volume.",
+				  lv->name);
+			return 0;
+		}
+
+		if (!(lv->status & LVM_WRITE)) {
+			log_error("Cannot use read-only logical volume \"%s\" for pool metadata spare.",
+				  lv->name);
+			return 0;
+		}
+
+		if (!lv_is_visible(lv)) {
+			log_error("Cannot use invisible logical volume \"%s\" for pool metadata spare.",
+				  lv->name);
+			return 0;
+		}
+
+		/* FIXME: validate size */
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_thin_pool_metadata(lvl->lv) &&
+			    (max_size < lvl->lv->size))
+				max_size = lvl->lv->size;
+
+		if (lv->size < max_size) {
+			log_error("Logical volume \"%s\" must have@least %s for pool metadata spare.",
+				  lv->name, display_size(lv->vg->cmd, max_size));
+			return 0;
+		}
+
+		if (!vg_set_pool_metadata_spare(lv))
+			return_0;
+	}
+
+	log_very_verbose("Updating spare logical volume \"%s\" on disk(s).", lv->name);
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	backup(lv->vg);
+
+	return 1;
+}
+
 static int lvchange_pool_update(struct cmd_context *cmd,
 				struct logical_volume *lv)
 {
@@ -955,7 +1022,9 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
-	if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
+	if (!lv_is_visible(lv) &&
+	    !lv_is_pool_metadata_spare(lv) &&
+	    !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
@@ -1008,6 +1077,13 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, poolmetadataspare_ARG)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+		doit += _lvchange_spare(cmd, lv);
+		docmds++;
+	}
+
 	if (arg_count(cmd, discards_ARG) ||
 	    arg_count(cmd, zero_ARG)) {
 		if (!archive(lv->vg))
@@ -1102,6 +1178,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, contiguous_ARG) ||
 		arg_count(cmd, permission_ARG) ||
 		arg_count(cmd, readahead_ARG) ||
+		arg_count(cmd, poolmetadataspare_ARG) ||
 		arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) ||
 		arg_count(cmd, deltag_ARG) ||
-- 
1.8.3.1


