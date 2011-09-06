From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 18:49:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20110906184935.10709.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 18:49:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.h 
	                 mirror.c raid_manip.c 
	tools          : lvconvert.c polldaemon.c polldaemon.h 

Log message:
	Start using 64-bit status flags - most of the code already handles them.
	tdata -> tpool
	remove commented out definitions from metadata.h
	formatting clean-ups

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2093&r2=1.2094
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.279&r2=1.280
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.204&r2=1.205
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.251&r2=1.252
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2011/09/06 18:24:27	1.2093
+++ LVM2/WHATS_NEW	2011/09/06 18:49:31	1.2094
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Begin using 64-bit status field flags.
   Detect sscanf recovering_region input error in cmirrord pull_state().
   Fix error path bitmap leak in cmirrord import_checkpoint().
   Log unlink() error in cmirrord remove_lockfile().
--- LVM2/lib/metadata/lv_manip.c	2011/09/06 15:39:46	1.279
+++ LVM2/lib/metadata/lv_manip.c	2011/09/06 18:49:32	1.280
@@ -1675,7 +1675,7 @@
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
 				/* On a second pass, avoid PVs already used in an uncommitted area */
- 				} else if (iteration_count)
+				} else if (iteration_count)
 					for (s = 0; s < devices_needed; s++)
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
@@ -1907,8 +1907,8 @@
 		return 1;
 	}
 
-        if (ah->area_multiple > 1 &&
-            (ah->new_extents - alloc_state.allocated) % ah->area_count) {
+	if (ah->area_multiple > 1 &&
+	    (ah->new_extents - alloc_state.allocated) % ah->area_count) {
 		log_error("Number of extents requested (%d) needs to be divisible by %d.",
 			  ah->new_extents - alloc_state.allocated, ah->area_count);
 		return 0;
@@ -2306,7 +2306,7 @@
  * If we used AREA_PVs under the mirror layer of a log, we could
  * assemble it all at once by calling 'lv_add_segment' with the
  * appropriate segtype (mirror/stripe), like this:
- * 	lv_add_segment(ah, ah->area_count, ah->log_area_count,
+ *	lv_add_segment(ah, ah->area_count, ah->log_area_count,
  *		       log_lv, segtype, 0, MIRROR_LOG, 0);
  *
  * For now, we use the same mechanism to build a mirrored log as we
@@ -2353,7 +2353,7 @@
 	} else if (segtype_is_thin_pool(segtype)) {
 		// lv->status |= THIN_POOL;
 		// status = THIN_IMAGE;
-		layer_name = "tdata";
+		layer_name = "tpool";
 	} else
 		return_0;
 
@@ -3775,7 +3775,7 @@
 	dev_flush(dev);
 
 	if (!dev_close_immediate(dev))
-                stack;
+		stack;
 
 	return 1;
 }
@@ -4198,7 +4198,7 @@
 		lp->pool = lv->name;
 	
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-		return_0;
+			return_0;
 	}
 
 	if (!(lv = _lv_create_an_lv(vg, lp, lp->lv_name)))
--- LVM2/lib/metadata/metadata-exported.h	2011/09/06 00:26:43	1.204
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/06 18:49:32	1.205
@@ -42,55 +42,55 @@
 /* Various flags */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
 
-#define PARTIAL_VG		0x00000001U	/* VG */
-#define EXPORTED_VG          	0x00000002U	/* VG PV */
-#define RESIZEABLE_VG        	0x00000004U	/* VG */
-
-/*
- * Since the RAID flags are LV (and seg) only and the above three
- * are VG/PV only, these flags are reused.
- */
-#define RAID                    0x00000001U	/* LV */
-#define RAID_META               0x00000002U	/* LV */
-#define RAID_IMAGE              0x00000004U	/* LV */
+#define PARTIAL_VG		UINT64_C(0x00000001)	/* VG */
+#define EXPORTED_VG		UINT64_C(0x00000002)	/* VG PV */
+#define RESIZEABLE_VG		UINT64_C(0x00000004)	/* VG */
 
 /* May any free extents on this PV be used or must they be left free? */
-#define ALLOCATABLE_PV         	0x00000008U	/* PV */
+#define ALLOCATABLE_PV		UINT64_C(0x00000008)	/* PV */
 
-//#define SPINDOWN_LV          	0x00000010U	/* LV */
-//#define BADBLOCK_ON       	0x00000020U	/* LV */
-#define VISIBLE_LV		0x00000040U	/* LV */
-#define FIXED_MINOR		0x00000080U	/* LV */
+//#define SPINDOWN_LV		UINT64_C(0x00000010)	/* LV */
+//#define BADBLOCK_ON		UINT64_C(0x00000020)	/* LV */
+#define VISIBLE_LV		UINT64_C(0x00000040)	/* LV */
+#define FIXED_MINOR		UINT64_C(0x00000080)	/* LV */
 /* FIXME Remove when metadata restructuring is completed */
-#define SNAPSHOT		0x00001000U	/* LV - internal use only */
-#define PVMOVE			0x00002000U	/* VG LV SEG */
-#define LOCKED			0x00004000U	/* LV */
-#define MIRRORED		0x00008000U	/* LV - internal use only */
-//#define VIRTUAL			0x00010000U	/* LV - internal use only */
-#define MIRROR_LOG		0x00020000U	/* LV */
-#define MIRROR_IMAGE		0x00040000U	/* LV */
-#define LV_NOTSYNCED		0x00080000U	/* LV */
-//#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
-#define CONVERTING		0x00400000U	/* LV */
-
-#define MISSING_PV              0x00800000U	/* PV */
-#define PARTIAL_LV              0x01000000U	/* LV - derived flag, not
-						   written out in metadata*/
-
-//#define POSTORDER_FLAG	0x02000000U /* Not real flags, reserved for
-//#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read_internal. */
-//#define VIRTUAL_ORIGIN	0x08000000U	/* LV - internal use only */
-
-#define MERGING			0x10000000U	/* LV SEG */
-
-#define REPLICATOR		0x20000000U	/* LV -internal use only for replicator */
-#define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicator-dev */
-#define UNLABELLED_PV           0x80000000U     /* PV -this PV had no label written yet */
-
-#define LVM_READ              	0x00000100U	/* LV VG */
-#define LVM_WRITE             	0x00000200U	/* LV VG */
-#define CLUSTERED         	0x00000400U	/* VG */
-//#define SHARED            	0x00000800U	/* VG */
+#define SNAPSHOT		UINT64_C(0x00001000)	/* LV - internal use only */
+#define PVMOVE			UINT64_C(0x00002000)	/* VG LV SEG */
+#define LOCKED			UINT64_C(0x00004000)	/* LV */
+#define MIRRORED		UINT64_C(0x00008000)	/* LV - internal use only */
+//#define VIRTUAL		UINT64_C(0x00010000)	/* LV - internal use only */
+#define MIRROR_LOG		UINT64_C(0x00020000)	/* LV */
+#define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
+#define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
+//#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
+#define CONVERTING		UINT64_C(0x00400000)	/* LV */
+
+#define MISSING_PV		UINT64_C(0x00800000)	/* PV */
+#define PARTIAL_LV		UINT64_C(0x01000000)	/* LV - derived flag, not
+							   written out in metadata*/
+
+//#define POSTORDER_FLAG	UINT64_C(0x02000000) /* Not real flags, reserved for
+//#define POSTORDER_OPEN_FLAG	UINT64_C(0x04000000)    temporary use inside vg_read_internal. */
+//#define VIRTUAL_ORIGIN	UINT64_C(0x08000000)	/* LV - internal use only */
+
+#define MERGING			UINT64_C(0x10000000)	/* LV SEG */
+
+#define REPLICATOR		UINT64_C(0x20000000)	/* LV -internal use only for replicator */
+#define REPLICATOR_LOG		UINT64_C(0x40000000)	/* LV -internal use only for replicator-dev */
+#define UNLABELLED_PV		UINT64_C(0x80000000)	/* PV -this PV had no label written yet */
+
+#define RAID			UINT64_C(0x0000000100000000)	/* LV */
+#define RAID_META		UINT64_C(0x0000000200000000)	/* LV */
+#define RAID_IMAGE		UINT64_C(0x0000000400000000)	/* LV */
+
+#define THIN_VOLUME		UINT64_C(0x0000001000000000)	/* LV */
+#define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV */
+
+#define LVM_READ		0x00000100U	/* LV VG 32-bit */
+#define LVM_WRITE		0x00000200U	/* LV VG 32-bit */
+
+#define CLUSTERED		UINT64_C(0x00000400)	/* VG */
+//#define SHARED		UINT64_C(0x00000800)	/* VG */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -112,10 +112,10 @@
 /* vg_read and vg_read_for_update flags */
 #define READ_ALLOW_INCONSISTENT	0x00010000U
 #define READ_ALLOW_EXPORTED	0x00020000U
-#define READ_WITHOUT_LOCK       0x00040000U
+#define READ_WITHOUT_LOCK	0x00040000U
 
 /* A meta-flag, useful with toollib for_each_* functions. */
-#define READ_FOR_UPDATE 	0x00100000U
+#define READ_FOR_UPDATE		0x00100000U
 
 /* vg's "read_status" field */
 #define FAILED_INCONSISTENT	0x00000001U
@@ -189,19 +189,19 @@
  */
 
 /* PV-based format instance */
-#define FMT_INSTANCE_PV 		0x00000000U
+#define FMT_INSTANCE_PV			0x00000000U
 
 /* VG-based format instance */
-#define FMT_INSTANCE_VG 		0x00000001U
+#define FMT_INSTANCE_VG			0x00000001U
 
 /* Include any existing PV mdas during format_instance initialisation */
-#define FMT_INSTANCE_MDAS 		0x00000002U
+#define FMT_INSTANCE_MDAS		0x00000002U
 
 /* Include any auxiliary mdas during format_instance intialisation */
-#define FMT_INSTANCE_AUX_MDAS 		0x00000004U
+#define FMT_INSTANCE_AUX_MDAS		0x00000004U
 
 /* Include any other format-specific mdas during format_instance initialisation */
-#define FMT_INSTANCE_PRIVATE_MDAS 	0x00000008U
+#define FMT_INSTANCE_PRIVATE_MDAS	0x00000008U
 
 struct format_instance {
 	unsigned ref_count;	/* Refs to this fid from VG and PV structs */
@@ -265,9 +265,9 @@
 
 	struct logical_volume *replicator; /* Reference to replicator */
 
-	const char *name;               /* Site name */
+	const char *name;		/* Site name */
 	const char *vg_name;		/* VG name */
-	struct volume_group *vg;        /* resolved vg  (activate/deactive) */
+	struct volume_group *vg;	/* resolved vg  (activate/deactive) */
 	unsigned site_index;
 	replicator_state_t state;	/* Active or pasive state of site */
 	dm_replicator_mode_t op_mode;	/* Operation mode sync or async fail|warn|drop|stall */
@@ -301,7 +301,7 @@
 	uint64_t status;
 
 	/* FIXME Fields depend on segment type */
-	uint32_t stripe_size;   /* For stripe and RAID - in sectors */
+	uint32_t stripe_size;	/* For stripe and RAID - in sectors */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots - in sectors */
@@ -388,7 +388,7 @@
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, int warnings, int *consistent);
+				      const char *vgid, int warnings, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				int warnings,
 				int scan_label_only);
@@ -425,9 +425,9 @@
  * Return a handle to VG metadata.
  */
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-              const char *vgid, uint32_t flags);
+			     const char *vgid, uint32_t flags);
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
-                         const char *vgid, uint32_t flags);
+			 const char *vgid, uint32_t flags);
 
 /* 
  * Test validity of a VG handle.
@@ -450,7 +450,7 @@
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
-             uint64_t size);
+	      uint64_t size);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
 
@@ -495,7 +495,7 @@
 
 /* Write out LV contents */
 int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
-           uint64_t sectors, int value);
+	   uint64_t sectors, int value);
 
 int lv_change_tag(struct logical_volume *lv, const char *tag, int add_tag);
 
@@ -699,7 +699,7 @@
 int lv_is_mirrored(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
-                                    uint32_t region_size);
+				    uint32_t region_size);
 int remove_mirrors_from_segments(struct logical_volume *lv,
 				 uint32_t new_mirrors, uint64_t status_mask);
 int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
@@ -773,12 +773,12 @@
 void lv_release_replicator_vgs(struct logical_volume *lv);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
-				      struct device *dev, uint32_t lv_type);
+				      struct device *dev, uint64_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  struct volume_group *vg,
 						  const char *name,
 						  const char *uuid,
-						  uint32_t lv_type);
+						  uint64_t lv_type);
 struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
--- LVM2/lib/metadata/metadata.h	2011/09/01 10:25:22	1.251
+++ LVM2/lib/metadata/metadata.h	2011/09/06 18:49:32	1.252
@@ -49,54 +49,23 @@
 
 
 /* Various flags */
+/* See metadata-exported.h for the complete list. */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
 
-//#define PARTIAL_VG		0x00000001U	/* VG */
-//#define EXPORTED_VG          	0x00000002U	/* VG PV */
-//#define RESIZEABLE_VG        	0x00000004U	/* VG */
-
 /* May any free extents on this PV be used or must they be left free? */
-//#define ALLOCATABLE_PV         	0x00000008U	/* PV */
 
-#define SPINDOWN_LV          	0x00000010U	/* LV */
-#define BADBLOCK_ON       	0x00000020U	/* LV */
-//#define VISIBLE_LV		0x00000040U	/* LV */
-//#define FIXED_MINOR		0x00000080U	/* LV */
-/* FIXME Remove when metadata restructuring is completed */
-//#define SNAPSHOT		0x00001000U	/* LV - internal use only */
-//#define PVMOVE			0x00002000U	/* VG LV SEG */
-//#define LOCKED			0x00004000U	/* LV */
-//#define MIRRORED		0x00008000U	/* LV - internal use only */
-#define VIRTUAL			0x00010000U	/* LV - internal use only */
-//#define MIRROR_LOG		0x00020000U	/* LV */
-//#define MIRROR_IMAGE		0x00040000U	/* LV */
-//#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
-#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
-//#define CONVERTING		0x00400000U	/* LV */
-
-//#define MISSING_PV		0x00800000U	/* PV */
-//#define PARTIAL_LV		0x01000000U	/* LV - derived flag, not
-//						   written out in metadata*/
-
-#define POSTORDER_FLAG		0x02000000U /* Not real flags, reserved for  */
-#define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read_internal. */
-#define VIRTUAL_ORIGIN		0x08000000U	/* LV - internal use only */
-
-//#define LVM_READ              	0x00000100U	/* LV VG */
-//#define LVM_WRITE             	0x00000200U	/* LV VG */
-//#define CLUSTERED         	0x00000400U	/* VG */
-#define SHARED            	0x00000800U	/* VG */
+#define SPINDOWN_LV          	UINT64_C(0x00000010)	/* LV */
+#define BADBLOCK_ON       	UINT64_C(0x00000020)	/* LV */
+#define VIRTUAL			UINT64_C(0x00010000)	/* LV - internal use only */
+#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
+#define POSTORDER_FLAG		UINT64_C(0x02000000) /* Not real flags, reserved for  */
+#define POSTORDER_OPEN_FLAG	UINT64_C(0x04000000) /* temporary use inside vg_read_internal. */
+#define VIRTUAL_ORIGIN		UINT64_C(0x08000000)	/* LV - internal use only */
+
+#define SHARED            	UINT64_C(0x00000800)	/* VG */
 
 /* Format features flags */
-//#define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
-//#define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
-//#define FMT_TAGS		0x00000004U	/* Tagging? */
-//#define FMT_UNLIMITED_VOLS	0x00000008U	/* Unlimited PVs/LVs? */
-//#define FMT_RESTRICTED_LVIDS	0x00000010U	/* LVID <= 255 */
-//#define FMT_ORPHAN_ALLOCATABLE	0x00000020U	/* Orphan PV allocatable? */
 #define FMT_PRECOMMIT		0x00000040U	/* Supports pre-commit? */
-//#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
-//#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
 struct dm_config_tree;
 struct metadata_area;
--- LVM2/lib/metadata/mirror.c	2011/09/01 19:22:11	1.160
+++ LVM2/lib/metadata/mirror.c	2011/09/06 18:49:32	1.161
@@ -1528,7 +1528,7 @@
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev,
-				      uint32_t lv_type)
+				      uint64_t lv_type)
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
@@ -1558,7 +1558,7 @@
 						  struct volume_group *vg,
 						  const char *name,
 						  const char *uuid __attribute__((unused)),
-						  uint32_t lv_type)
+						  uint64_t lv_type)
 {
 	struct physical_volume *pv;
 	struct logical_volume *lv;
--- LVM2/lib/metadata/raid_manip.c	2011/08/19 19:35:50	1.11
+++ LVM2/lib/metadata/raid_manip.c	2011/09/06 18:49:32	1.12
@@ -359,7 +359,7 @@
  */
 static int _alloc_image_component(struct logical_volume *lv,
 				  struct alloc_handle *ah, uint32_t first_area,
-				  uint32_t type, struct logical_volume **new_lv)
+				  uint64_t type, struct logical_volume **new_lv)
 {
 	uint64_t status;
 	size_t len = strlen(lv->name) + 32;
--- LVM2/tools/lvconvert.c	2011/08/18 19:43:09	1.171
+++ LVM2/tools/lvconvert.c	2011/09/06 18:49:32	1.172
@@ -342,7 +342,7 @@
 						struct volume_group *vg,
 						const char *name,
 						const char *uuid,
-						uint32_t lv_type __attribute__((unused)))
+						uint64_t lv_type __attribute__((unused)))
 {
 	struct logical_volume *lv = find_lv(vg, name);
 
--- LVM2/tools/polldaemon.c	2011/08/10 20:25:31	1.45
+++ LVM2/tools/polldaemon.c	2011/09/06 18:49:32	1.46
@@ -283,7 +283,7 @@
  */
 int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		unsigned background,
-		uint32_t lv_type, struct poll_functions *poll_fns,
+		uint64_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title)
 {
 	struct daemon_parms parms;
--- LVM2/tools/polldaemon.h	2010/01/22 21:59:43	1.11
+++ LVM2/tools/polldaemon.h	2011/09/06 18:49:32	1.12
@@ -36,7 +36,7 @@
 					       struct volume_group *vg,
 					       const char *name,
 					       const char *uuid,
-					       uint32_t lv_type);
+					       uint64_t lv_type);
 	progress_t (*poll_progress)(struct cmd_context *cmd,
 				    struct logical_volume *lv,
 				    const char *name,
@@ -59,13 +59,13 @@
 	unsigned outstanding_count;
 	unsigned progress_display;
 	const char *progress_title;
-	uint32_t lv_type;
+	uint64_t lv_type;
 	struct poll_functions *poll_fns;
 };
 
 int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		unsigned background,
-		uint32_t lv_type, struct poll_functions *poll_fns,
+		uint64_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title);
 
 progress_t poll_mirror_progress(struct cmd_context *cmd,


