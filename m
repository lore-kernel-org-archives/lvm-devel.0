From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 14 Oct 2014 17:15:08 +0000 (UTC)
Subject: master - vgcreate: Permit non-power-of-2 extent sizes.
Message-ID: <20141014171508.2EB9161004@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e6e2d6b1b984b83929dd23e75c0512e564d184f
Commit:        5e6e2d6b1b984b83929dd23e75c0512e564d184f
Parent:        02628413ca99648e70e38406384be69e20a2a6ce
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 14 18:12:15 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 14 18:12:15 2014 +0100

vgcreate: Permit non-power-of-2 extent sizes.

Relax validation to permit extent sizes > 128KB that are not powers of 2
with lvm2 format.  Existing code was already capable of handling this.
---
 WHATS_NEW                        |    1 +
 lib/format1/disk-rep.h           |    2 -
 lib/format1/format1.c            |   21 +------
 lib/format_text/format-text.c    |   14 +++--
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.h          |    2 +
 lib/metadata/vg.c                |  124 ++++++++++++++++++++++++--------------
 lib/metadata/vg.h                |    1 +
 man/vgchange.8.in                |    9 ++-
 man/vgcreate.8.in                |    9 ++-
 tools/vgconvert.c                |    3 +
 11 files changed, 107 insertions(+), 81 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2a0adf4..d7a00fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Permit extent sizes > 128KB that are not power of 2 with lvm2 format.
   Remove workaround for lvm2-monitor.service hang on stop if lvmetad stopped.
   Change vgremove to use process_each_lv_in_vg.
   Introduce WARN_ flags to control some metadata warning messages.
diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 43e2e57..729601e 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -26,8 +26,6 @@
 #define LVM_BLK_MAJOR 58
 
 #define MAX_PV_SIZE	((uint32_t) -1)	/* 2TB in sectors - 1 */
-#define MIN_PE_SIZE	(8192L >> SECTOR_SHIFT)	/* 8 KB in sectors */
-#define MAX_PE_SIZE	(16L * 1024L * (1024L >> SECTOR_SHIFT) * 1024L)
 #define PE_SIZE_PV_SIZE_REL 5	/* PV size must be at least 5 times PE size */
 #define	MAX_LE_TOTAL	65534	/* 2^16 - 2 */
 #define	MAX_PE_TOTAL	((uint32_t) -2)
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 8ee2f48..b0943b1 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -493,25 +493,8 @@ static int _format1_vg_setup(struct format_instance *fid, struct volume_group *v
 	if (!vg->max_pv || vg->max_pv >= MAX_PV)
 		vg->max_pv = MAX_PV - 1;
 
-	if (vg->extent_size > MAX_PE_SIZE || vg->extent_size < MIN_PE_SIZE) {
-		log_error("Extent size must be between %s and %s",
-			  display_size(fid->fmt->cmd, (uint64_t) MIN_PE_SIZE),
-			  display_size(fid->fmt->cmd, (uint64_t) MAX_PE_SIZE));
-
-		return 0;
-	}
-
-	if (vg->extent_size % MIN_PE_SIZE) {
-		log_error("Extent size must be multiple of %s",
-			  display_size(fid->fmt->cmd, (uint64_t) MIN_PE_SIZE));
-		return 0;
-	}
-
-	/* Redundant? */
-	if (vg->extent_size & (vg->extent_size - 1)) {
-		log_error("Extent size must be power of 2");
-		return 0;
-	}
+	if (!vg_check_new_extent_size(vg->fid->fmt, vg->extent_size))
+		return_0;
 
 	return 1;
 }
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9b894fa..c142e1b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -72,13 +72,14 @@ void rlocn_set_ignored(struct raw_locn *rlocn, unsigned mda_ignored)
  * NOTE: Currently there can be only one vg per text file.
  */
 
-static int _text_vg_setup(struct format_instance *fid __attribute__((unused)),
+/*
+ * Only used by vgcreate.
+ */
+static int _text_vg_setup(struct format_instance *fid,
 			  struct volume_group *vg)
 {
-	if (vg->extent_size & (vg->extent_size - 1)) {
-		log_error("Extent size must be power of 2");
-		return 0;
-	}
+	if (!vg_check_new_extent_size(vg->fid->fmt, vg->extent_size))
+		return_0;
 
 	return 1;
 }
@@ -2440,7 +2441,8 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
-			FMT_UNLIMITED_STRIPESIZE | FMT_BAS | FMT_CONFIG_PROFILE;
+			FMT_UNLIMITED_STRIPESIZE | FMT_BAS | FMT_CONFIG_PROFILE |
+			FMT_NON_POWER2_EXTENTS;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
 		log_error("Failed to allocate dir_list");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0d8db7d..bf6f1c1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -35,6 +35,7 @@
 #define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
 #define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MAX_EXTENT_SIZE ((uint32_t) -1)
+#define MIN_NON_POWER2_EXTENT_SIZE (128U * 2U)	/* 128KB in sectors */
 
 /* Layer suffix */
 #define MIRROR_SYNC_LAYER "_mimagetmp"
@@ -132,6 +133,7 @@
 #define FMT_BAS			0x000000400U	/* Supports bootloader areas? */
 #define FMT_CONFIG_PROFILE	0x000000800U	/* Supports configuration profiles? */
 #define FMT_OBSOLETE		0x000001000U	/* Obsolete format? */
+#define FMT_NON_POWER2_EXTENTS	0x000002000U	/* Non-power-of-2 extent sizes? */
 
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f847ddb..1dd8867 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -33,6 +33,8 @@
 //#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
+#define MIN_PE_SIZE     (8192L >> SECTOR_SHIFT) /* 8 KB in sectors - format1 only */
+#define MAX_PE_SIZE     (16L * 1024L * (1024L >> SECTOR_SHIFT) * 1024L) /* format1 only */
 #define MIRROR_LOG_OFFSET	2	/* sectors */
 #define VG_MEMPOOL_CHUNK	10240	/* in bytes, hint only */
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 7b6cb85..71b894b 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -278,18 +278,18 @@ char *vg_profile_dup(const struct volume_group *vg)
 }
 
 static int _recalc_extents(uint32_t *extents, const char *desc1,
-			   const char *desc2, uint32_t old_size,
-			   uint32_t new_size)
+			   const char *desc2, uint32_t old_extent_size,
+			   uint32_t new_extent_size)
 {
-	uint64_t size = (uint64_t) old_size * (*extents);
+	uint64_t size = (uint64_t) old_extent_size * (*extents);
 
-	if (size % new_size) {
+	if (size % new_extent_size) {
 		log_error("New size %" PRIu64 " for %s%s not an exact number "
 			  "of new extents.", size, desc1, desc2);
 		return 0;
 	}
 
-	size /= new_size;
+	size /= new_extent_size;
 
 	if (size > MAX_EXTENT_COUNT) {
 		log_error("New extent count %" PRIu64 " for %s%s exceeds "
@@ -302,9 +302,48 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	return 1;
 }
 
-int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
+int vg_check_new_extent_size(const struct format_type *fmt, uint32_t new_extent_size)
 {
-	uint32_t old_size = vg->extent_size;
+	if (!new_extent_size) {
+		log_error("Physical extent size may not be zero");
+		return 0;
+	}
+
+	if ((fmt->features & FMT_NON_POWER2_EXTENTS)) {
+		if ((new_extent_size & (new_extent_size - 1)) &&
+		    (new_extent_size % MIN_NON_POWER2_EXTENT_SIZE)) {
+			log_error("Physical Extent size must be a multiple of %s when not a power of 2.",
+				  display_size(fmt->cmd, (uint64_t) MIN_NON_POWER2_EXTENT_SIZE));
+			return 0;
+		}
+		return 1;
+	}
+
+	/* Apply original format1 restrictions */
+	if ((new_extent_size & (new_extent_size - 1))) {
+		log_error("Metadata format only supports Physical Extent sizes that are powers of 2.");
+		return 0;
+	}
+
+	if (new_extent_size > MAX_PE_SIZE || new_extent_size < MIN_PE_SIZE) {
+		log_error("Extent size must be between %s and %s",
+			  display_size(fmt->cmd, (uint64_t) MIN_PE_SIZE),
+			  display_size(fmt->cmd, (uint64_t) MAX_PE_SIZE));
+		return 0;
+	}
+
+	if (new_extent_size % MIN_PE_SIZE) {
+		log_error("Extent size must be multiple of %s",
+			  display_size(fmt->cmd, (uint64_t) MIN_PE_SIZE));
+		return 0;
+	}
+
+ 	return 1;
+}
+
+int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size)
+{
+	uint32_t old_extent_size = vg->extent_size;
 	struct pv_list *pvl;
 	struct lv_list *lvl;
 	struct physical_volume *pv;
@@ -319,52 +358,45 @@ int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 		return 0;
 	}
 
-	if (!new_size) {
-		log_error("Physical extent size may not be zero");
-		return 0;
-	}
-
-	if (new_size == vg->extent_size)
+	if (new_extent_size == vg->extent_size)
 		return 1;
 
-	if (new_size & (new_size - 1)) {
-		log_error("Physical extent size must be a power of 2.");
-		return 0;
-	}
+	if (!vg_check_new_extent_size(vg->fid->fmt, new_extent_size))
+		return_0;
 
-	if (new_size > vg->extent_size) {
-		if ((uint64_t) vg_size(vg) % new_size) {
+	if (new_extent_size > vg->extent_size) {
+		if ((uint64_t) vg_size(vg) % new_extent_size) {
 			/* FIXME Adjust used PV sizes instead */
 			log_error("New extent size is not a perfect fit");
 			return 0;
 		}
 	}
 
-	vg->extent_size = new_size;
+	vg->extent_size = new_extent_size;
 
 	if (vg->fid->fmt->ops->vg_setup &&
 	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg))
 		return_0;
 
-	if (!_recalc_extents(&vg->extent_count, vg->name, "", old_size,
-			     new_size))
+	if (!_recalc_extents(&vg->extent_count, vg->name, "", old_extent_size,
+			     new_extent_size))
 		return_0;
 
 	if (!_recalc_extents(&vg->free_count, vg->name, " free space",
-			     old_size, new_size))
+			     old_extent_size, new_extent_size))
 		return_0;
 
 	/* foreach PV */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
-		pv->pe_size = new_size;
+		pv->pe_size = new_extent_size;
 		if (!_recalc_extents(&pv->pe_count, pv_dev_name(pv), "",
-				     old_size, new_size))
+				     old_extent_size, new_extent_size))
 			return_0;
 
 		if (!_recalc_extents(&pv->pe_alloc_count, pv_dev_name(pv),
-				     " allocated space", old_size, new_size))
+				     " allocated space", old_extent_size, new_extent_size))
 			return_0;
 
 		/* foreach free PV Segment */
@@ -373,12 +405,12 @@ int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 				continue;
 
 			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
-					     " PV segment start", old_size,
-					     new_size))
+					     " PV segment start", old_extent_size,
+					     new_extent_size))
 				return_0;
 			if (!_recalc_extents(&pvseg->len, pv_dev_name(pv),
-					     " PV segment length", old_size,
-					     new_size))
+					     " PV segment length", old_extent_size,
+					     new_extent_size))
 				return_0;
 		}
 	}
@@ -387,29 +419,29 @@ int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (!_recalc_extents(&lv->le_count, lv->name, "", old_size,
-				     new_size))
+		if (!_recalc_extents(&lv->le_count, lv->name, "", old_extent_size,
+				     new_extent_size))
 			return_0;
 
 		dm_list_iterate_items(seg, &lv->segments) {
 			if (!_recalc_extents(&seg->le, lv->name,
-					     " segment start", old_size,
-					     new_size))
+					     " segment start", old_extent_size,
+					     new_extent_size))
 				return_0;
 
 			if (!_recalc_extents(&seg->len, lv->name,
-					     " segment length", old_size,
-					     new_size))
+					     " segment length", old_extent_size,
+					     new_extent_size))
 				return_0;
 
 			if (!_recalc_extents(&seg->area_len, lv->name,
-					     " area length", old_size,
-					     new_size))
+					     " area length", old_extent_size,
+					     new_extent_size))
 				return_0;
 
 			if (!_recalc_extents(&seg->extents_copied, lv->name,
-					     " extents moved", old_size,
-					     new_size))
+					     " extents moved", old_extent_size,
+					     new_extent_size))
 				return_0;
 
 			/* foreach area */
@@ -419,21 +451,21 @@ int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 					if (!_recalc_extents
 					    (&seg_pe(seg, s),
 					     lv->name,
-					     " pvseg start", old_size,
-					     new_size))
+					     " pvseg start", old_extent_size,
+					     new_extent_size))
 						return_0;
 					if (!_recalc_extents
 					    (&seg_pvseg(seg, s)->len,
 					     lv->name,
-					     " pvseg length", old_size,
-					     new_size))
+					     " pvseg length", old_extent_size,
+					     new_extent_size))
 						return_0;
 					break;
 				case AREA_LV:
 					if (!_recalc_extents
 					    (&seg_le(seg, s), lv->name,
-					     " area start", old_size,
-					     new_size))
+					     " area start", old_extent_size,
+					     new_extent_size))
 						return_0;
 					break;
 				case AREA_UNASSIGNED:
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index b3b7e93..fffe9a7 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -147,6 +147,7 @@ int vg_set_clustered(struct volume_group *vg, int clustered);
 uint64_t vg_size(const struct volume_group *vg);
 uint64_t vg_free(const struct volume_group *vg);
 uint64_t vg_extent_size(const struct volume_group *vg);
+int vg_check_new_extent_size(const struct format_type *fmt, uint32_t new_extent_size);
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size);
 uint64_t vg_extent_count(const struct volume_group *vg);
 uint64_t vg_free_count(const struct volume_group *vg);
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 150b77d..dcd1faf 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -220,10 +220,11 @@ minimize metadata read and write overhead.
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIBbBsSkKmMgGtTpPeE ]
 Changes the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present. The value must be at least 1 sector
-for LVM2 format (where the sector size is the largest sector size of the
-PVs currently used in the VG) or 8KiB for LVM1 format and it must be a
-power of 2. The default is 4 MiB.
+is the default if no suffix is present.  For LVM2 format, the value must be a
+power of 2 of at least 1 sector (where the sector size is the largest sector
+size of the PVs currently used in the VG) or, if not a power of 2, at least
+128KiB.  For the older LVM1 format, it must be a power of 2 of at least 8KiB.
+The default is 4 MiB.
 
 Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits.  For example, every
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index bcfbcfc..d850659 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -105,10 +105,11 @@ See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIbBsSkKmMgGtTpPeE ]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present. The value must be at least 1 sector
-for LVM2 format (where the sector size is the largest sector size of the
-PVs currently used in the VG) or 8KiB for LVM1 format and it must be a
-power of 2. The default is 4 MiB.
+is the default if no suffix is present. For LVM2 format, the value must be a
+power of 2 of at least 1 sector (where the sector size is the largest sector
+size of the PVs currently used in the VG) or, if not a power of 2, at least
+128KiB.  For the older LVM1 format, it must be a power of 2 of at least 8KiB.
+The default is 4 MiB.
 
 Once this value has been set, it is difficult to change it without recreating
 the volume group which would involve backing up and restoring data on any
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 86e3097..1089344 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -66,6 +66,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
 	}
 
+	if (!vg_check_new_extent_size(cmd->fmt, vg->extent_size))
+		return_ECMD_FAILED;
+
 	if (!archive(vg)) {
 		log_error("Archive of \"%s\" metadata failed.", vg_name);
 		return ECMD_FAILED;


