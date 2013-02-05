From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:06 +0100
Subject: [PATCH 5/6] thin: lvconvert support for external origin
In-Reply-To: <cover.1360072297.git.zkabelac@redhat.com>
References: <cover.1360072297.git.zkabelac@redhat.com>
Message-ID: <34e450af1a19b88013d559e559c6e715f86d37d0.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add basic support for converting LV into an external origin volume.

Syntax:

lvconvert --thinpool vg/pool  --originname renamed_origin -T origin

It will convert volume  'origin' into a thin volume, which will
use 'renamed_origin' as an external read-only origin.
All read/write into origin will go via 'pool'.

renamed_origin volume is read-only volume, that could be activated
only in read-only mode, and cannot be modified.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |   6 +-
 man/lvconvert.8.in      |  32 +++++++++
 tools/args.h            |   3 +-
 tools/commands.h        |   7 +-
 tools/lvconvert.c       | 173 ++++++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 210 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6187828..f19dff7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1580,6 +1580,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
+	/* Converting non-thin LV to thin external origin ? */
+	if (!lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
+		lockfs = 1; /* Sync before conversion */
+
 	if (laopts->origin_only && lv_is_thin_volume(lv) && lv_is_thin_volume(lv_pre))
 		lockfs = 1;
 
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 578047b..c5929c2 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -99,6 +99,10 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
+.RB [ \-T | \-\-thin
+.IR ExternalOriginLogicalVolume { Name | Path }
+.RB [ \-\-originname
+.IR NewExternalOriginVolumeName ]]
 .RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
 .sp
 
@@ -230,6 +234,13 @@ merge finishes, the merged snapshot is removed.  Multiple snapshots may
 be specified on the commandline or a @tag may be used to specify
 multiple snapshots be merged to their respective origin.
 .TP
+.B \-\-originname \fINewExternalOriginVolumeName\fP
+The name for converted external origin volume.
+.br
+Without this option a default names of "lvol#" will be generated where
+# is the LVM internal number of the logical volume.
+Converted volume will be read-only.
+.TP
 .BR \-\-poolmetadata " " \fIThinPoolMetadataLogicalVolume { \fIName | \fIPath }
 Specifies thin pool metadata logical volume.
 The size should be in between 2MiB and 16GiB.
@@ -288,6 +299,13 @@ StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
 .TP
+.IR \fB\-T ", " \fB\-\-thin " " ExternalOriginLogicalVolume { Name | Path }
+Changes the logical volume into a thin volume for the thin pool
+specified with the option \fB\-\-thinpool\fP. \fIExternalOriginLogicalVolume\fP
+is converted into a new read-only logical volume which will be used as an
+external origin volume for unprovisioned areas.
+The non-default name for this new volume can be specified with \fB\-\-originname\fP.
+.TP
 .IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
 Changes logical volume into a thin pool volume. The volume
 will store the pool's data.
@@ -379,6 +397,20 @@ available in the volume group.
 .sp
 .B lvconvert \-\-replace /dev/sdb1 vg00/my_raid1 /dev/sdf1
 
+Convert the logical volume "vg00/lvpool" into a thin pool with chunk size 128KiB
+and convert "vg00/lv1" into a thin volume using this pool. Original "vg00/lv1"
+is used as an external read-only origin, where all writes to such volume
+are stored in the "vg00/lvpool".
+.sp
+.B lvconvert \-\-thinpool vg00/lvpool -c 128 -T lv1
+
+Convert the logical volume "vg00/origin" into a thin volume from the thin pool
+"vg00/lvpool". This thin volume will use "vg00/origin" as an external origin
+volume for unprovisioned areas in this volume.
+For the read-only external origin use the new name "vg00/external".
+.sp
+.B lvconvert \-\-thinpool vg00/lvpool \-\-originname external -T vg00/origin
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
diff --git a/tools/args.h b/tools/args.h
index d4d6c40..b140cdb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -69,6 +69,7 @@ arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
+arg(originname_ARG, '\0', "originname", string_arg, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 986539e..32d3c96 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -151,6 +151,8 @@ xx(lvconvert,
    "\t [--poolmetadatasize size]\n"
    "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
+   "\t[-T|--thin ExternalLogicalVolume[Path]\n"
+   "\t [--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n",
 
@@ -158,7 +160,8 @@ xx(lvconvert,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
    readahead_ARG, regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
-   chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG, thinpool_ARG,
+   chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
+   originname_ARG, thin_ARG, thinpool_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0e15888..133b456 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -57,6 +57,7 @@ struct lvconvert_params {
 	struct logical_volume *lv_to_poll;
 
 	uint64_t poolmetadata_size;
+	const char *origin_lv_name;
 	const char *pool_data_lv_name;
 	const char *pool_metadata_lv_name;
 	thin_discards_t discards;
@@ -68,6 +69,7 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 {
 	char *ptr;
 	const char *vg_name = NULL;
+	const char *tmp_str;
 
 	if (lp->merge)
 		return 1;
@@ -94,16 +96,35 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 
 	if (lp->pool_data_lv_name) {
 		if (*pargc) {
-			log_error("More then one logical volume name name specified.");
-			return 0;
+			if (!arg_count(cmd, thin_ARG)) {
+				log_error("More then one logical volume name specified.");
+				return 0;
+			}
+		} else {
+			if (arg_count(cmd, thin_ARG)) {
+				log_error("External thin volume name is missing.");
+				return 0;
+			}
+
+			if (!lp->vg_name || !validate_name(lp->vg_name)) {
+				log_error("Please provide a valid volume group name.");
+				return 0;
+			}
+
+			lp->lv_name = lp->pool_data_lv_name;
+			return 1;
 		}
+	}
 
-		if (!lp->vg_name || !validate_name(lp->vg_name)) {
-			log_error("Please provide a valid volume group name.");
-			return 0;
+	if (lp->origin_lv_name) {
+		/* FIXME: Using generic routine */
+		if (strchr(lp->origin_lv_name, '/')) {
+			if (!(lp->vg_name = extract_vgname(cmd, lp->origin_lv_name)))
+				return_0;
+			/* Strip VG from origin_lv_name */
+			if ((tmp_str = strrchr(lp->origin_lv_name, '/')))
+				lp->origin_lv_name = tmp_str + 1;
 		}
-		lp->lv_name = lp->pool_data_lv_name;
-		return 1; /* Create metadata LV on it's own */
 	}
 
 	if (!*pargc) {
@@ -219,6 +240,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+	} else if (arg_count(cmd, thin_ARG)) {
+		log_error("--thin is only valid with --thinpool.");
+		return 0;
 	} else if (arg_count(cmd, discards_ARG)) {
 		log_error("--discards is only valid with --thinpool.");
 		return 0;
@@ -376,6 +400,13 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			lp->pool_data_lv_name = tmp_str + 1;
 		}
 
+		if (arg_count(cmd, originname_ARG)) {
+			if (!(lp->origin_lv_name = arg_str_value(cmd, originname_ARG, NULL))) {
+				log_error("--originname is invalid.");
+				return 0;
+			}
+		}
+
 		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "thin-pool"));
 		if (!lp->segtype)
 			return_0;
@@ -1827,6 +1858,115 @@ out:
 	return r;
 }
 
+/* Swap lvid and LV names */
+static int _swap_lv(struct cmd_context *cmd,
+		    struct logical_volume *a, struct logical_volume *b)
+{
+	union lvid lvid;
+	const char *name;
+
+	lvid = a->lvid;
+	a->lvid = b->lvid;
+	b->lvid = lvid;
+
+	name = a->name;
+	a->name = b->name;
+	if (!lv_rename_update(cmd, b, name, 0))
+		return_0;
+
+	return 1;
+}
+
+static int _lvconvert_thinpool_external(struct cmd_context *cmd,
+					struct logical_volume *pool_lv,
+					struct logical_volume *external_lv,
+					struct lvconvert_params *lp)
+{
+	struct logical_volume *torigin_lv;
+	struct volume_group *vg = pool_lv->vg;
+	struct lvcreate_params lvc = { 0 };
+
+	dm_list_init(&lvc.tags);
+
+	if (!(lvc.segtype = get_segtype_from_string(cmd, "thin")))
+		return_0;
+
+	lvc.activate = CHANGE_AE;
+	lvc.alloc = ALLOC_INHERIT;
+	lvc.lv_name = lp->origin_lv_name;
+	lvc.major = -1;
+	lvc.minor = -1;
+	lvc.permission = LVM_READ;
+	lvc.pool = pool_lv->name;
+	lvc.pvh = &vg->pvs;
+	lvc.read_ahead = DM_READ_AHEAD_AUTO;
+	lvc.stripes = 1;
+	lvc.vg_name = vg->name;
+	lvc.voriginextents = external_lv->le_count;
+	lvc.voriginsize = external_lv->size;
+
+	/* New thin LV needs to be created (all messages sent to pool) */
+	if (!(torigin_lv = lv_create_single(vg, &lvc)))
+		return_0;
+
+	/* Activate again via -torigin, so this active LV is not needed */
+	if (!deactivate_lv(cmd, torigin_lv)) {
+		log_error("Aborting. Unable to deactivate new LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	/*
+	 * Crashing till this point will leave plain thin volume
+	 * which could be easily removed by the user after i.e. power-off
+	 */
+
+	if (!_swap_lv(cmd, torigin_lv, external_lv)) {
+		stack;
+		goto revert_new_lv;
+	}
+
+	/* FIXME: is that useful to preserve status here ? */
+	torigin_lv->status |= (external_lv->status & LVM_WRITE);
+
+	if (!attach_thin_external_origin(first_seg(torigin_lv), external_lv)) {
+		goto revert_new_lv;
+	}
+
+	if (!_reload_lv(cmd, vg, torigin_lv)) {
+		stack;
+		goto deactivate_and_revert_new_lv;
+	}
+
+	log_print_unless_silent("Converted %s/%s to thin external origin.",
+				vg->name, external_lv->name);
+
+	return 1;
+
+deactivate_and_revert_new_lv:
+	if (!_swap_lv(cmd, torigin_lv, external_lv))
+		stack;
+
+	if (!deactivate_lv(cmd, torigin_lv)) {
+		log_error("Unable to deactivate failed new LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	if (!detach_thin_external_origin(first_seg(torigin_lv)))
+		return_0;
+
+revert_new_lv:
+	/* FIXME Better to revert to backup of metadata? */
+	if (!lv_remove(torigin_lv) || !vg_write(vg) || !vg_commit(vg))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned LV(s) before retrying.");
+	else
+		backup(vg);
+
+	return 0;
+}
+
 /*
  * Thin lvconvert version which
  *  rename metadata
@@ -1845,6 +1985,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	struct logical_volume *data_lv;
 	struct logical_volume *metadata_lv;
 	struct logical_volume *pool_metadata_lv;
+	struct logical_volume *external_lv = NULL;
 
 	if (!lv_is_visible(pool_lv)) {
 		log_error("Can't convert internal LV %s/%s.",
@@ -1852,6 +1993,19 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (arg_count(cmd, thin_ARG)) {
+		external_lv = pool_lv;
+		if (!(pool_lv = find_lv(external_lv->vg, lp->pool_data_lv_name))) {
+			log_error("Can't find pool LV %s/%s.",
+				  external_lv->vg->name, lp->pool_data_lv_name);
+			return 0;
+		}
+		if (lv_is_thin_pool(pool_lv)) {
+			r = 1; /* Already existing thin pool */
+			goto out;
+		}
+	}
+
 	if (lv_is_thin_type(pool_lv) && !lp->pool_metadata_lv_name) {
 		log_error("Can't use thin logical volume %s/%s for thin pool data.",
 			  pool_lv->vg->name, pool_lv->name);
@@ -2066,7 +2220,12 @@ mda_write:
 
 	r = 1;
 out:
+	if (r && external_lv &&
+	    !(r = _lvconvert_thinpool_external(cmd, pool_lv, external_lv, lp)))
+		stack;
+
 	backup(pool_lv->vg);
+
 	return r;
 }
 
-- 
1.8.1.2


