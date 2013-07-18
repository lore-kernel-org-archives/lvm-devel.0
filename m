From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:54 +0000 (UTC)
Subject: master - thin: add spare lvcreate support
Message-ID: <20130718162654.616E961019@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=307578495511e35398e0f9ef3f796641dfa5038e
Commit:        307578495511e35398e0f9ef3f796641dfa5038e
Parent:        a916bf7eeb9130435c78573ddb51da9318f68411
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 13:34:31 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:44 2013 +0200

thin: add spare lvcreate support

Add --poolmetadataspare option and creates and handles
pool metadata spare lv when thin pool is created.
With default setting 'y' it tries to ensure, spare has
at least the size of created LV.
---
 lib/config/defaults.h            |    1 +
 lib/metadata/metadata-exported.h |    3 +
 lib/metadata/thin_manip.c        |   99 ++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in                |   11 ++++-
 tools/commands.h                 |    4 +-
 tools/lvcreate.c                 |   18 ++++++-
 6 files changed, 132 insertions(+), 4 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index a789a9c..34ce2ea 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -73,6 +73,7 @@
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
+#define DEFAULT_POOL_METADATA_SPARE 1
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 65999cd..67dc7f7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -667,6 +667,8 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   uint32_t stripes, uint32_t stripe_size,
 					   uint64_t size, alloc_policy_t alloc,
 					   struct dm_list *pvh);
+int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
+			       struct dm_list *pvh, int poolmetadataspare);
 int vg_set_pool_metadata_spare(struct logical_volume *lv);
 int vg_remove_pool_metadata_spare(struct volume_group *vg);
 
@@ -710,6 +712,7 @@ struct lvcreate_params {
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+	int poolmetadataspare; /* thin pool */
 #define ACTIVATION_SKIP_SET		0x01 /* request to set LV activation skip flag state */
 #define ACTIVATION_SKIP_SET_ENABLED	0x02 /* set the LV activation skip flag state to 'enabled' */
 #define ACTIVATION_SKIP_IGNORE		0x04 /* request to ignore LV activation skip flag (if any) */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 9ee8a55..5ac356f 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -728,6 +728,102 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 	return metadata_lv;
 }
 
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
+	return 1;
+}
+
 int vg_set_pool_metadata_spare(struct logical_volume *lv)
 {
 	char new_name[NAME_LEN];
@@ -797,5 +893,8 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
 		return_0;
 
+	/* To display default warning */
+	(void) handle_pool_metadata_spare(vg, 0, 0, 0);
+
 	return 1;
 }
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 64319c1..ecbf363 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -64,7 +64,9 @@ lvcreate \- create a logical volume in an existing volume group
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
@@ -293,6 +295,13 @@ Supported values are in range between 2MiB and 16GiB.
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
index f4fdb0b..3c9ed82 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -214,6 +214,7 @@ xx(lvcreate,
    "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
    "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
+   "\t  [--poolmetadataspare {y|n}]\n"
    "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -260,9 +261,10 @@ xx(lvcreate,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
    noudevsync_ARG, ignoreactivationskip_ARG, setactivationskip_ARG,
+   poolmetadatasize_ARG, poolmetadataspare_ARG,
    permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
    snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   type_ARG, virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG,
+   type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
    zero_ARG)
 
 xx(lvdisplay,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d9578aa..2e8c65f 100644
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
@@ -904,6 +904,14 @@ static int _lvcreate_params(struct lvcreate_params *lp,
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
@@ -962,6 +970,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			contiguous_ARG,
 			discards_ARG,
 			poolmetadatasize_ARG,
+			poolmetadataspare_ARG,
 			stripes_ARG,
 			stripesize_ARG,
 			zero_ARG
@@ -1096,9 +1105,14 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
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


