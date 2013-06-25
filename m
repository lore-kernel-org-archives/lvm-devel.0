From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:05 +0200
Subject: [PATCH 5/6] thin: add spare lvcreate support
In-Reply-To: <cover.1372161214.git.zkabelac@redhat.com>
References: <cover.1372161214.git.zkabelac@redhat.com>
Message-ID: <6c0b2af111b25a953cb44c88218006b1c726593b.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add --spare option and create and hanle spare lv
when thin pool is created.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |  1 +
 tools/commands.h                 | 10 +++--
 tools/lvcreate.c                 | 83 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 88 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 453b98b..a368dca 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -615,6 +615,7 @@ struct lvcreate_params {
 	int minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
+	int spare; /* thin pool */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 	thin_discards_t discards;     /* thin */
 
diff --git a/tools/commands.h b/tools/commands.h
index ca29b81..d1cef36 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -208,6 +208,7 @@ xx(lvcreate,
    "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
    "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
+   "\t  [--spare {y|n}]\n"
    "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -251,10 +252,11 @@ xx(lvcreate,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, permission_ARG,
-   persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
-   stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
-   virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
+   noudevsync_ARG, permission_ARG, persistent_ARG, poolmetadatasize_ARG,
+   readahead_ARG, regionsize_ARG,
+   size_ARG, snapshot_ARG, spare_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, thin_ARG, thinpool_ARG, type_ARG,
+   virtualoriginsize_ARG,virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 80ca1bc..a149c64 100644
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
@@ -887,6 +887,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
+	if (lp->create_thin_pool) {
+		lp->spare = arg_uint_value(cmd, spare_ARG, 1); /* TODO: lvm.conf default */
+	} else if (arg_count(cmd, spare_ARG)) {
+		log_error("--spare is only available with thin pool creation.");
+		return 0;
+	}
 	/*
 	 * Allocation parameters
 	 */
@@ -945,6 +951,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			contiguous_ARG,
 			discards_ARG,
 			poolmetadatasize_ARG,
+			spare_ARG,
 			stripes_ARG,
 			stripesize_ARG,
 			zero_ARG
@@ -1043,6 +1050,71 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 	return r;
 }
 
+/* Create spare LV */
+static int _handle_spare(struct volume_group *vg, uint32_t extents,
+			 struct dm_list *pvh)
+{
+	struct logical_volume *lv = vg->spare;
+	uint32_t seg_mirrors;
+	struct lv_segment *seg;
+	struct lvcreate_params lp = {
+		.activate = CHANGE_ALY,
+		.alloc = ALLOC_INHERIT,
+		.extents = extents,
+		.lv_name = "spare_%d",
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
+	/* vg_write & vg_commit with pool creation */
+	/* FIXME: resolve archive */
+	if (lv) {
+		seg = last_seg(lv);
+		seg_mirrors = lv_mirror_count(lv);
+
+		/* Check spare is big enough and preserve segtype */
+		if ((lv->le_count < extents) && seg &&
+		    !lv_extend(lv,
+			       seg->segtype,
+			       seg->area_count / seg_mirrors,
+			       seg->stripe_size,
+			       seg_mirrors,
+			       seg->region_size,
+			       extents - lv->le_count, NULL,
+			       pvh, lv->alloc))
+			return_0;
+
+		return 1;
+	}
+
+	/* FIXME: Maybe using silent mode ? */
+	if (!(lv = lv_create_single(vg, &lp)))
+		return_0;
+
+	/* no need to keep active */
+	if (!deactivate_lv(vg->cmd, lv)) {
+		log_error("Unable to deactivate spare LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	lv->status |= SPARE_LV;
+	vg->spare = lv;
+
+	return 1;
+}
+
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_PROCESSED;
@@ -1090,9 +1162,16 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	}
 
-	if (lp.create_thin_pool)
+	if (lp.create_thin_pool) {
+		if (!lp.spare)
+			log_warn("WARNING: recovery without spare LV for "
+				 "pool %s is not automated.", lp.pool);
+		else if (!_handle_spare(vg, lp.poolmetadataextents, lp.pvh))
+			return_0;
+
 		log_verbose("Making thin pool %s in VG %s using segtype %s",
 			    lp.pool ? : "with generated name", lp.vg_name, lp.segtype->name);
+	}
 
 	if (lp.thin)
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
-- 
1.8.2.1


