From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:04 +0200
Subject: [PATCH 4/6] thin: lvchange spare lv manipulation
In-Reply-To: <cover.1372161214.git.zkabelac@redhat.com>
References: <cover.1372161214.git.zkabelac@redhat.com>
Message-ID: <8bc501a78ec22479818786b5147b8afbdb4b9763.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow lvchange of spare flag for an LV.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/args.h     |  1 +
 tools/commands.h |  5 ++--
 tools/lvchange.c | 86 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 89 insertions(+), 3 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 2fed97e..b8d0ad6 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -76,6 +76,7 @@ arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
 arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
+arg(spare_ARG, '\0', "spare", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 2d99d5a..ca29b81 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -92,6 +92,7 @@ xx(lvchange,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[--spare {y|n}]\n"
    "\t[--syncaction {check|repair}\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
@@ -106,8 +107,8 @@ xx(lvchange,
    alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
    discards_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
-   noudevsync_ARG, partial_ARG,
-   permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
+   noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
+   poll_ARG, readahead_ARG, resync_ARG, spare_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
    writebehind_ARG, writemostly_ARG, zero_ARG)
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c88d8ef..f7fcf44 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -101,6 +101,77 @@ out:
 	return r;
 }
 
+static int lvchange_spare(struct cmd_context *cmd,
+			  struct logical_volume *lv)
+{
+	struct lv_list *lvl;
+	uint64_t max_size = 0;
+	unsigned spare = arg_uint_value(cmd, spare_ARG, 0);
+
+	if (lv_is_active(lv)) {
+		log_error("Cannot change spare for active logical volume \"%s\".",
+			  lv->name);
+		return 0;
+	}
+
+	if (spare) {
+		if (lv_is_spare(lv)) {
+			log_error("Logical volume \"%s\" is already spare volume.",
+				  lv->name);
+			return 0;
+		}
+
+		if (!(lv->status & LVM_WRITE)) {
+			log_error("Cannot use read-only logical volume \"%s\" for spare.",
+				  lv->name);
+			return 0;
+		}
+
+		if (!lv_is_visible(lv)) {
+			log_error("Cannot use invisible logical volume \"%s\" for spare.",
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
+			log_error("Logical volume \"%s\" must have@least %s for spare.",
+				  lv->name, display_size(lv->vg->cmd, max_size));
+			return 0;
+		}
+
+		if (lv->vg->spare) {
+			log_print_unless_silent("Replacing spare logical volume \"%s\".",
+						lv->vg->spare->name);
+			lv->vg->spare->status &= ~SPARE_LV;
+		}
+
+		lv->vg->spare = lv;
+		lv->status |= SPARE_LV;
+	} else {
+		if (!lv_is_spare(lv)) {
+			log_error("Logical volume \"%s\" is not a spare volume.",
+				  lv->name);
+			return 0;
+		}
+
+		lv->vg->spare = NULL;
+		lv->status &= ~SPARE_LV;
+	}
+
+	log_very_verbose("Updating spare logical volume \"%s\" on disk(s).", lv->name);
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	backup(lv->vg);
+	return 1;
+}
+
 static int lvchange_pool_update(struct cmd_context *cmd,
 				struct logical_volume *lv)
 {
@@ -930,7 +1001,9 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
-	if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
+	if (!lv_is_visible(lv) &&
+	    !lv_is_spare(lv) &&
+	    !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
@@ -997,6 +1070,16 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (arg_count(cmd, spare_ARG)) {
+		if (!archived && !archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		archived = 1;
+		doit += lvchange_spare(cmd, lv);
+		docmds++;
+	}
+
 	if (arg_count(cmd, discards_ARG) ||
 	    arg_count(cmd, zero_ARG)) {
 		if (!archived && !archive(lv->vg)) {
@@ -1120,6 +1203,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, contiguous_ARG) ||
 		arg_count(cmd, permission_ARG) ||
 		arg_count(cmd, readahead_ARG) ||
+		arg_count(cmd, spare_ARG) ||
 		arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) ||
 		arg_count(cmd, deltag_ARG);
-- 
1.8.2.1


