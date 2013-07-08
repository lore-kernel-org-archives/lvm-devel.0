From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:57 +0200
Subject: [PATCH 5/7] thin: add spare lvcreate support
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <9e3e633bc805a7766e40da9694662ba233ede439.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add --poolmetadataspare option and creates and handles
pool metadata spare lv when thin pool is created.
With default setting 'y' it tries to ensure, spare has
at least the size of created LV.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/defaults.h            |  1 +
 lib/metadata/metadata-exported.h |  3 ++
 lib/metadata/thin_manip.c        | 99 ++++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in                | 11 ++++-
 tools/commands.h                 | 10 ++--
 tools/lvcreate.c                 | 18 +++++++-
 6 files changed, 135 insertions(+), 7 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 7ee89ec..3cd92a6 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -73,6 +73,7 @@
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
+#define DEFAULT_POOL_METADATA_SPARE 1
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0250941..de69fd7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -668,6 +668,8 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   struct dm_list *pvh);
 int vg_set_pool_metadata_spare(struct logical_volume *lv);
 int vg_remove_pool_metadata_spare(struct volume_group *vg);
+int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
+			       struct dm_list *pvh, int poolmetadataspare);
 
 /*
  * Activation options
@@ -692,6 +694,7 @@ struct lvcreate_params {
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+	int poolmetadataspare; /* thin pool */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 	thin_discards_t discards;     /* thin */
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 721c1e2..72496d9 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -790,5 +790,104 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
 		return_0;
 
+	/* To display default warning */
+	(void) handle_pool_metadata_spare(vg, 0, 0, 0);
+
+	return 1;
+}
+
+static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg,
+							 uint32_t extents,
+							 struct dm_list *pvh)
+{
+	struct logical_volume *lv;
+
+	/* FIXME: Make lvm2api usable */
+	struct lvcreate_params lp = {
+		.activate = CHANGE_ALY,
+		.alloc = ALLOC_INHERIT,
+		.extents = extents,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = pvh ? : &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_AUTO,
+		.stripes = 1,
+		.vg_name = vg->name,
+		.zero = 1,
+	};
+
+	dm_list_init(&lp.tags);
+
+	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
+		return_0;
+
+	/* FIXME: Maybe using silent mode ? */
+	if (!(lv = lv_create_single(vg, &lp)))
+		return_0;
+
+	/* Spare LV should not be active */
+	if (!deactivate_lv_local(vg->cmd, lv)) {
+		log_error("Unable to deactivate pool metadata spare LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	if (!vg_set_pool_metadata_spare(lv))
+		return_0;
+
+	return lv;
+}
+
+/*
+ * Create/resize pool metadata spare LV
+ * Caller does vg_write(), vg_commit() with pool creation
+ * extents is 0, max size is determined
+ */
+int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
+			       struct dm_list *pvh, int poolmetadataspare)
+{
+	struct logical_volume *lv = vg->pool_metadata_spare_lv;
+	uint32_t seg_mirrors;
+	struct lv_segment *seg;
+	const struct lv_list *lvl;
+
+	if (!extents)
+		/* Find maximal size of metadata LV */
+		dm_list_iterate_items(lvl, &vg->lvs)
+			if (lv_is_thin_pool_metadata(lvl->lv) &&
+			    (lvl->lv->le_count > extents))
+				extents = lvl->lv->le_count;
+
+	if (!poolmetadataspare) {
+		/* TODO: Not showing when lvm.conf would define 'n' ? */
+		if (DEFAULT_POOL_METADATA_SPARE && extents)
+			/* Warn if there would be any user */
+			log_warn("WARNING: recovery of pools without pool "
+				 "metadata spare LV is not automated.");
+		return 1;
+	}
+
+	if (!lv) {
+		if (!_alloc_pool_metadata_spare(vg, extents, pvh))
+			return_0;
+
+		return 1;
+	}
+
+	seg = last_seg(lv);
+	seg_mirrors = lv_mirror_count(lv);
+
+	/* Check spare LV is big enough and preserve segtype */
+	if ((lv->le_count < extents) && seg &&
+	    !lv_extend(lv, seg->segtype,
+		       seg->area_count / seg_mirrors,
+		       seg->stripe_size,
+		       seg_mirrors,
+		       seg->region_size,
+		       extents - lv->le_count, NULL,
+		       pvh, lv->alloc))
+		return_0;
+
 	return 1;
 }
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ac5cf65..163b2f4 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -61,7 +61,9 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadatasize
-.IR MetadataVolumeSize [ bBsSkKmMgG ]]]
+.IR MetadataVolumeSize [ bBsSkKmMgG ]]
+.RB [ \-\-poolmetadataspare
+.RI { y | n }]]
 .RB [ \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }
 .RB [ \-s | \-\-snapshot
@@ -277,6 +279,13 @@ Supported values are in range between 2MiB and 16GiB.
 Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
 .TP
+.IR \fB\-\-poolmetadataspare " {"  y | n }
+Controls creation and maintanence of pool metadata spare logical volume
+that will be used for automated thin pool recovery.
+Only one such volume is maintained within a volume group
+with the size of the biggest thin metadata volume.
+Default is \fIy\fPes.
+.TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Sets read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
diff --git a/tools/commands.h b/tools/commands.h
index 89d8764..3aec4bc 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -210,6 +210,7 @@ xx(lvcreate,
    "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
    "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
+   "\t  [--poolmetadataspare {y|n}]\n"
    "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -253,10 +254,11 @@ xx(lvcreate,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, permission_ARG,
-   persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
-   stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
-   virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
+   noudevsync_ARG, permission_ARG, persistent_ARG, poolmetadatasize_ARG,
+   poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
+   size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, thin_ARG, thinpool_ARG, type_ARG,
+   virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 698d72f..caecc46 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -887,6 +887,14 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
+	if (lp->create_thin_pool) {
+		/* TODO: add lvm.conf default y|n */
+		lp->poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG,
+						      DEFAULT_POOL_METADATA_SPARE);
+	} else if (arg_count(cmd, poolmetadataspare_ARG)) {
+		log_error("--poolmetadataspare is only available with thin pool creation.");
+		return 0;
+	}
 	/*
 	 * Allocation parameters
 	 */
@@ -945,6 +953,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			contiguous_ARG,
 			discards_ARG,
 			poolmetadatasize_ARG,
+			poolmetadataspare_ARG,
 			stripes_ARG,
 			stripesize_ARG,
 			zero_ARG
@@ -1079,9 +1088,14 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (seg_is_thin(&lp) && !_validate_internal_thin_processing(&lp))
 		goto_out;
 
-	if (lp.create_thin_pool)
+	if (lp.create_thin_pool) {
+		if (!handle_pool_metadata_spare(vg, lp.poolmetadataextents,
+						lp.pvh, lp.poolmetadataspare))
+			goto_out;
+
 		log_verbose("Making thin pool %s in VG %s using segtype %s",
 			    lp.pool ? : "with generated name", lp.vg_name, lp.segtype->name);
+	}
 
 	if (lp.thin)
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
-- 
1.8.3.1


