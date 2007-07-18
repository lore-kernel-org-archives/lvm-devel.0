From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jul 2007 15:39:00 -0000
Subject: LVM2 ./WHATS_NEW include/.symlinks lib/activat ...
Message-ID: <20070718153900.28800.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-18 15:38:58

Modified files:
	.              : WHATS_NEW 
	include        : .symlinks 
	lib/activate   : activate.h 
	lib/display    : display.h 
	lib/error      : errseg.c 
	lib/format_text: archiver.h 
	lib/metadata   : metadata.h 
	lib/report     : report.h 
	lib/striped    : striped.c 
	lib/zero       : zero.c 
	tools          : polldaemon.h toollib.h tools.h 
Added files:
	lib/metadata   : metadata-exported.h 

Log message:
	Split metadata-external.h out from metadata.h for the tools to use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.659&r2=1.660
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2007/07/17 20:53:51	1.659
+++ LVM2/WHATS_NEW	2007/07/18 15:38:57	1.660
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Split metadata-external.h out from metadata.h for the tools to use.
 
 Version 2.02.27 - 17th July 2007
 ================================
--- LVM2/include/.symlinks	2007/04/27 18:52:05	1.44
+++ LVM2/include/.symlinks	2007/07/18 15:38:57	1.45
@@ -30,6 +30,7 @@
 ../lib/log/log.h
 ../lib/metadata/lv_alloc.h
 ../lib/metadata/metadata.h
+../lib/metadata/metadata-exported.h
 ../lib/metadata/pv_alloc.h
 ../lib/metadata/segtype.h
 ../lib/mm/memlock.h
--- LVM2/lib/activate/activate.h	2007/03/08 21:08:25	1.55
+++ LVM2/lib/activate/activate.h	2007/07/18 15:38:57	1.56
@@ -16,7 +16,7 @@
 #ifndef LVM_ACTIVATE_H
 #define LVM_ACTIVATE_H
 
-#include "metadata.h"
+#include "metadata-exported.h"
 
 struct lvinfo {
 	int exists;
--- LVM2/lib/display/display.h	2007/05/30 20:43:09	1.17
+++ LVM2/lib/display/display.h	2007/07/18 15:38:57	1.18
@@ -16,7 +16,7 @@
 #ifndef _LVM_DISPLAY_H
 #define _LVM_DISPLAY_H
 
-#include "metadata.h"
+#include "metadata-exported.h"
 
 #include <stdint.h>
 
--- LVM2/lib/error/errseg.c	2006/10/18 18:01:51	1.12
+++ LVM2/lib/error/errseg.c	2007/07/18 15:38:58	1.13
@@ -24,6 +24,7 @@
 #include "lvm-string.h"
 #include "activate.h"
 #include "str_list.h"
+#include "metadata.h"
 
 static const char *_errseg_name(const struct lv_segment *seg)
 {
--- LVM2/lib/format_text/archiver.h	2007/06/08 22:38:48	1.2
+++ LVM2/lib/format_text/archiver.h	2007/07/18 15:38:58	1.3
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,7 +16,7 @@
 #ifndef _LVM_TOOL_ARCHIVE_H
 #define _LVM_TOOL_ARCHIVE_H
 
-#include "metadata.h"
+#include "metadata-exported.h"
 
 /*
  * There are two operations that come under the general area of
/cvs/lvm2/LVM2/lib/metadata/metadata-exported.h,v  -->  standard output
revision 1.1
--- LVM2/lib/metadata/metadata-exported.h
+++ -	2007-07-18 15:38:59.653039000 +0000
@@ -0,0 +1,451 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This is the representation of LVM metadata that is being adapted
+ * for library export.
+ */
+
+#ifndef _LVM_METADATA_EXPORTED_H
+#define _LVM_METADATA_EXPORTED_H
+
+#include "uuid.h"
+
+struct physical_volume;
+typedef struct physical_volume pv_t;
+struct volume_group;
+typedef struct volume_group vg_t;
+
+struct logical_volume;
+
+struct lv_segment;
+struct pv_segment;
+
+#define MAX_STRIPES 128U
+#define SECTOR_SHIFT 9L
+#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
+#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
+#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
+#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
+#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
+
+/* Various flags */
+/* Note that the bits no longer necessarily correspond to LVM1 disk format */
+
+#define PARTIAL_VG		0x00000001U	/* VG */
+#define EXPORTED_VG          	0x00000002U	/* VG PV */
+#define RESIZEABLE_VG        	0x00000004U	/* VG */
+
+/* May any free extents on this PV be used or must they be left free? */
+#define ALLOCATABLE_PV         	0x00000008U	/* PV */
+
+//#define SPINDOWN_LV          	0x00000010U	/* LV */
+//#define BADBLOCK_ON       	0x00000020U	/* LV */
+#define VISIBLE_LV		0x00000040U	/* LV */
+#define FIXED_MINOR		0x00000080U	/* LV */
+/* FIXME Remove when metadata restructuring is completed */
+#define SNAPSHOT		0x00001000U	/* LV - internal use only */
+#define PVMOVE			0x00002000U	/* VG LV SEG */
+#define LOCKED			0x00004000U	/* LV */
+#define MIRRORED		0x00008000U	/* LV - internal use only */
+//#define VIRTUAL			0x00010000U	/* LV - internal use only */
+#define MIRROR_LOG		0x00020000U	/* LV */
+#define MIRROR_IMAGE		0x00040000U	/* LV */
+#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
+//#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
+//#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
+
+#define LVM_READ              	0x00000100U	/* LV VG */
+#define LVM_WRITE             	0x00000200U	/* LV VG */
+#define CLUSTERED         	0x00000400U	/* VG */
+//#define SHARED            	0x00000800U	/* VG */
+
+/* Format features flags */
+#define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
+#define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
+#define FMT_TAGS		0x00000004U	/* Tagging? */
+#define FMT_UNLIMITED_VOLS	0x00000008U	/* Unlimited PVs/LVs? */
+#define FMT_RESTRICTED_LVIDS	0x00000010U	/* LVID <= 255 */
+#define FMT_ORPHAN_ALLOCATABLE	0x00000020U	/* Orphan PV allocatable? */
+//#define FMT_PRECOMMIT		0x00000040U	/* Supports pre-commit? */
+#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
+#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
+
+/* Ordered list - see lv_manip.c */
+typedef enum {
+	ALLOC_INVALID,
+	ALLOC_CONTIGUOUS,
+	ALLOC_CLING,
+	ALLOC_NORMAL,
+	ALLOC_ANYWHERE,
+	ALLOC_INHERIT
+} alloc_policy_t;
+
+typedef enum {
+	AREA_UNASSIGNED,
+	AREA_PV,
+	AREA_LV
+} area_type_t;
+
+struct cmd_context;
+struct format_handler;
+struct labeller;
+
+struct format_type {
+	struct list list;
+	struct cmd_context *cmd;
+	struct format_handler *ops;
+	struct labeller *labeller;
+	const char *name;
+	const char *alias;
+	uint32_t features;
+	void *library;
+	void *private;
+};
+
+struct pv_segment {
+	struct list list;	/* Member of pv->segments: ordered list
+				 * covering entire data area on this PV */
+
+	struct physical_volume *pv;
+	uint32_t pe;
+	uint32_t len;
+
+	struct lv_segment *lvseg;	/* NULL if free space */
+	uint32_t lv_area;	/* Index to area in LV segment */
+};
+
+struct physical_volume {
+	struct id id;
+	struct device *dev;
+	const struct format_type *fmt;
+	const char *vg_name;
+	struct id vgid;
+
+	uint32_t status;
+	uint64_t size;
+
+	/* physical extents */
+	uint32_t pe_size;
+	uint64_t pe_start;
+	uint32_t pe_count;
+	uint32_t pe_alloc_count;
+
+	struct list segments;	/* Ordered pv_segments covering complete PV */
+	struct list tags;
+};
+
+struct format_instance {
+	const struct format_type *fmt;
+	struct list metadata_areas;	/* e.g. metadata locations */
+	void *private;
+};
+
+struct volume_group {
+	struct cmd_context *cmd;
+	struct format_instance *fid;
+	uint32_t seqno;		/* Metadata sequence number */
+
+	struct id id;
+	char *name;
+	char *system_id;
+
+	uint32_t status;
+	alloc_policy_t alloc;
+
+	uint32_t extent_size;
+	uint32_t extent_count;
+	uint32_t free_count;
+
+	uint32_t max_lv;
+	uint32_t max_pv;
+
+	/* physical volumes */
+	uint32_t pv_count;
+	struct list pvs;
+
+	/* logical volumes */
+	uint32_t lv_count;
+	uint32_t snapshot_count;
+	struct list lvs;
+
+	struct list tags;
+};
+
+/* There will be one area for each stripe */
+struct lv_segment_area {
+	area_type_t type;
+	union {
+		struct {
+			struct pv_segment *pvseg;
+		} pv;
+		struct {
+			struct logical_volume *lv;
+			uint32_t le;
+		} lv;
+	} u;
+};
+
+struct segment_type;
+struct lv_segment {
+	struct list list;
+	struct logical_volume *lv;
+
+	const struct segment_type *segtype;
+	uint32_t le;
+	uint32_t len;
+
+	uint32_t status;
+
+	/* FIXME Fields depend on segment type */
+	uint32_t stripe_size;
+	uint32_t area_count;
+	uint32_t area_len;
+	struct logical_volume *origin;
+	struct logical_volume *cow;
+	struct list origin_list;
+	uint32_t chunk_size;	/* For snapshots - in sectors */
+	uint32_t region_size;	/* For mirrors - in sectors */
+	uint32_t extents_copied;
+	struct logical_volume *log_lv;
+	struct lv_segment *mirror_seg;
+
+	struct list tags;
+
+	struct lv_segment_area *areas;
+};
+
+#define seg_type(seg, s)	(seg)->areas[(s)].type
+#define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
+#define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
+
+struct logical_volume {
+	union lvid lvid;
+	char *name;
+
+	struct volume_group *vg;
+
+	uint32_t status;
+	alloc_policy_t alloc;
+	uint32_t read_ahead;
+	int32_t major;
+	int32_t minor;
+
+	uint64_t size;		/* Sectors */
+	uint32_t le_count;
+
+	uint32_t origin_count;
+	struct list snapshot_segs;
+	struct lv_segment *snapshot;
+
+	struct list segments;
+	struct list tags;
+};
+
+struct pe_range {
+	struct list list;
+	uint32_t start;		/* PEs */
+	uint32_t count;		/* PEs */
+};
+
+struct pv_list {
+	struct list list;
+	struct physical_volume *pv;
+	struct list *mdas;	/* Metadata areas */
+	struct list *pe_ranges;	/* Ranges of PEs e.g. for allocation */
+};
+
+struct lv_list {
+	struct list list;
+	struct logical_volume *lv;
+};
+
+/*
+* Utility functions
+*/
+int vg_write(struct volume_group *vg);
+int vg_commit(struct volume_group *vg);
+int vg_revert(struct volume_group *vg);
+struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
+			     const char *vgid, int *consistent);
+struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
+				struct list *mdas, uint64_t *label_sector,
+				int warnings);
+struct list *get_pvs(struct cmd_context *cmd);
+
+/* Set full_scan to 1 to re-read every (filtered) device label */
+struct list *get_vgs(struct cmd_context *cmd, int full_scan);
+struct list *get_vgids(struct cmd_context *cmd, int full_scan);
+
+int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
+	     struct list *mdas, int64_t label_sector);
+int is_orphan(pv_t *pv);
+
+/* pe_start and pe_end relate to any existing data so that new metadata
+* areas can avoid overlap */
+pv_t *pv_create(const struct format_type *fmt,
+		      struct device *dev,
+		      struct id *id,
+		      uint64_t size,
+		      uint64_t pe_start,
+		      uint32_t existing_extent_count,
+		      uint32_t existing_extent_size,
+		      int pvmetadatacopies,
+		      uint64_t pvmetadatasize, struct list *mdas);
+int pv_resize(struct physical_volume *pv, struct volume_group *vg,
+             uint32_t new_pe_count);
+int pv_analyze(struct cmd_context *cmd, const char *pv_name,
+	       int64_t label_sector);
+
+struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
+			       uint32_t extent_size, uint32_t max_pv,
+			       uint32_t max_lv, alloc_policy_t alloc,
+			       int pv_count, char **pv_names);
+int vg_remove(struct volume_group *vg);
+int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
+	      const char *new_name);
+int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
+int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
+		     uint32_t new_extent_size);
+int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
+		  struct volume_group *vg_to);
+
+/* Manipulate LVs */
+struct logical_volume *lv_create_empty(struct format_instance *fi,
+				       const char *name,
+				       union lvid *lvid,
+				       uint32_t status,
+				       alloc_policy_t alloc,
+				       int import,
+				       struct volume_group *vg);
+
+/* Reduce the size of an LV by extents */
+int lv_reduce(struct logical_volume *lv, uint32_t extents);
+
+/* Empty an LV prior to deleting it */
+int lv_empty(struct logical_volume *lv);
+
+/* Entry point for all LV extent allocations */
+int lv_extend(struct logical_volume *lv,
+	      const struct segment_type *segtype,
+	      uint32_t stripes, uint32_t stripe_size,
+	      uint32_t mirrors, uint32_t extents,
+	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
+	      uint32_t status, struct list *allocatable_pvs,
+	      alloc_policy_t alloc);
+
+/* lv must be part of lv->vg->lvs */
+int lv_remove(struct logical_volume *lv);
+
+/* Find a PV within a given VG */
+struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
+pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
+
+/* Find an LV within a given VG */
+struct lv_list *find_lv_in_vg(struct volume_group *vg, const char *lv_name);
+
+/* FIXME Merge these functions with ones above */
+struct logical_volume *find_lv(struct volume_group *vg, const char *lv_name);
+struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
+					const char *pv_name);
+
+/* Find LV segment containing given LE */
+struct lv_segment *first_seg(struct logical_volume *lv);
+
+
+/*
+* Useful functions for managing snapshots.
+*/
+int lv_is_origin(const struct logical_volume *lv);
+int lv_is_cow(const struct logical_volume *lv);
+int lv_is_visible(const struct logical_volume *lv);
+
+int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
+
+/* Given a cow LV, return return the snapshot lv_segment that uses it */
+struct lv_segment *find_cow(const struct logical_volume *lv);
+
+/* Given a cow LV, return its origin */
+struct logical_volume *origin_from_cow(const struct logical_volume *lv);
+
+int vg_add_snapshot(struct format_instance *fid, const char *name,
+		    struct logical_volume *origin, struct logical_volume *cow,
+		    union lvid *lvid, uint32_t extent_count,
+		    uint32_t chunk_size);
+
+int vg_remove_snapshot(struct logical_volume *cow);
+
+int vg_check_status(struct volume_group *vg, uint32_t status);
+
+/*
+* Mirroring functions
+*/
+struct alloc_handle;
+uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
+                                    uint32_t region_size);
+int create_mirror_layers(struct alloc_handle *ah,
+			 uint32_t first_area,
+			 uint32_t num_mirrors,
+			 struct logical_volume *lv,
+			 const struct segment_type *segtype,
+			 uint32_t status,
+			 uint32_t region_size,
+			 struct logical_volume *log_lv);
+
+int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
+			 struct list *removable_pvs, int remove_log);
+int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
+			      struct list *removable_pvs, int remove_log);
+
+int insert_pvmove_mirrors(struct cmd_context *cmd,
+			  struct logical_volume *lv_mirr,
+			  struct list *source_pvl,
+			  struct logical_volume *lv,
+			  struct list *allocatable_pvs,
+			  alloc_policy_t alloc,
+			  struct list *lvs_changed);
+int remove_pvmove_mirrors(struct volume_group *vg,
+			  struct logical_volume *lv_mirr);
+struct logical_volume *find_pvmove_lv(struct volume_group *vg,
+				      struct device *dev, uint32_t lv_type);
+struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
+						  struct volume_group *vg,
+						  const char *name,
+						  uint32_t lv_type);
+const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
+const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
+float copy_percent(struct logical_volume *lv_mirr);
+struct list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
+			  struct logical_volume *lv);
+
+uint32_t find_free_lvnum(struct logical_volume *lv);
+char *generate_lv_name(struct volume_group *vg, const char *format,
+		       char *buffer, size_t len);
+
+/*
+* Begin skeleton for external LVM library
+*/
+struct device *pv_dev(pv_t *pv);
+const char *pv_vg_name(pv_t *pv);
+uint64_t pv_size(pv_t *pv);
+uint32_t pv_status(pv_t *pv);
+uint32_t pv_pe_size(pv_t *pv);
+uint64_t pv_pe_start(pv_t *pv);
+uint32_t pv_pe_count(pv_t *pv);
+uint32_t pv_pe_alloc_count(pv_t *pv);
+
+uint32_t vg_status(vg_t *vg);
+
+#endif
--- LVM2/lib/metadata/metadata.h	2007/07/12 15:38:53	1.169
+++ LVM2/lib/metadata/metadata.h	2007/07/18 15:38:58	1.170
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -24,127 +24,61 @@
 #include "ctype.h"
 #include "dev-cache.h"
 #include "lvm-string.h"
-#include "uuid.h"
+#include "metadata-exported.h"
 
-#define MAX_STRIPES 128U
-#define SECTOR_SHIFT 9L
+//#define MAX_STRIPES 128U
+//#define SECTOR_SHIFT 9L
 #define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
-#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
-#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
-#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
-#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
-#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
+//#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
+//#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
+//#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
+//#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
+//#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MIRROR_LOG_SIZE 1	/* Extents */
 
 /* Various flags */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
 
-#define PARTIAL_VG		0x00000001U	/* VG */
-#define EXPORTED_VG          	0x00000002U	/* VG PV */
-#define RESIZEABLE_VG        	0x00000004U	/* VG */
+//#define PARTIAL_VG		0x00000001U	/* VG */
+//#define EXPORTED_VG          	0x00000002U	/* VG PV */
+//#define RESIZEABLE_VG        	0x00000004U	/* VG */
 
 /* May any free extents on this PV be used or must they be left free? */
-#define ALLOCATABLE_PV         	0x00000008U	/* PV */
+//#define ALLOCATABLE_PV         	0x00000008U	/* PV */
 
 #define SPINDOWN_LV          	0x00000010U	/* LV */
 #define BADBLOCK_ON       	0x00000020U	/* LV */
-#define VISIBLE_LV		0x00000040U	/* LV */
-#define FIXED_MINOR		0x00000080U	/* LV */
+//#define VISIBLE_LV		0x00000040U	/* LV */
+//#define FIXED_MINOR		0x00000080U	/* LV */
 /* FIXME Remove when metadata restructuring is completed */
-#define SNAPSHOT		0x00001000U	/* LV - internal use only */
-#define PVMOVE			0x00002000U	/* VG LV SEG */
-#define LOCKED			0x00004000U	/* LV */
-#define MIRRORED		0x00008000U	/* LV - internal use only */
+//#define SNAPSHOT		0x00001000U	/* LV - internal use only */
+//#define PVMOVE			0x00002000U	/* VG LV SEG */
+//#define LOCKED			0x00004000U	/* LV */
+//#define MIRRORED		0x00008000U	/* LV - internal use only */
 #define VIRTUAL			0x00010000U	/* LV - internal use only */
-#define MIRROR_LOG		0x00020000U	/* LV */
-#define MIRROR_IMAGE		0x00040000U	/* LV */
-#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
+//#define MIRROR_LOG		0x00020000U	/* LV */
+//#define MIRROR_IMAGE		0x00040000U	/* LV */
+//#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
 #define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 #define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 
-#define LVM_READ              	0x00000100U	/* LV VG */
-#define LVM_WRITE             	0x00000200U	/* LV VG */
-#define CLUSTERED         	0x00000400U	/* VG */
+//#define LVM_READ              	0x00000100U	/* LV VG */
+//#define LVM_WRITE             	0x00000200U	/* LV VG */
+//#define CLUSTERED         	0x00000400U	/* VG */
 #define SHARED            	0x00000800U	/* VG */
 
 /* Format features flags */
-#define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
-#define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
-#define FMT_TAGS		0x00000004U	/* Tagging? */
-#define FMT_UNLIMITED_VOLS	0x00000008U	/* Unlimited PVs/LVs? */
-#define FMT_RESTRICTED_LVIDS	0x00000010U	/* LVID <= 255 */
-#define FMT_ORPHAN_ALLOCATABLE	0x00000020U	/* Orphan PV allocatable? */
+//#define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
+//#define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
+//#define FMT_TAGS		0x00000004U	/* Tagging? */
+//#define FMT_UNLIMITED_VOLS	0x00000008U	/* Unlimited PVs/LVs? */
+//#define FMT_RESTRICTED_LVIDS	0x00000010U	/* LVID <= 255 */
+//#define FMT_ORPHAN_ALLOCATABLE	0x00000020U	/* Orphan PV allocatable? */
 #define FMT_PRECOMMIT		0x00000040U	/* Supports pre-commit? */
-#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
-#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
+//#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
+//#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
-/* Ordered list - see lv_manip.c */
-typedef enum {
-	ALLOC_INVALID,
-	ALLOC_CONTIGUOUS,
-	ALLOC_CLING,
-	ALLOC_NORMAL,
-	ALLOC_ANYWHERE,
-	ALLOC_INHERIT
-} alloc_policy_t;
-
-typedef enum {
-	AREA_UNASSIGNED,
-	AREA_PV,
-	AREA_LV
-} area_type_t;
-
-struct cmd_context;
-struct format_handler;
-struct labeller;
-
-struct format_type {
-	struct list list;
-	struct cmd_context *cmd;
-	struct format_handler *ops;
-	struct labeller *labeller;
-	const char *name;
-	const char *alias;
-	uint32_t features;
-	void *library;
-	void *private;
-};
-
-struct pv_segment {
-	struct list list;	/* Member of pv->segments: ordered list
-				 * covering entire data area on this PV */
-
-	struct physical_volume *pv;
-	uint32_t pe;
-	uint32_t len;
-
-	struct lv_segment *lvseg;	/* NULL if free space */
-	uint32_t lv_area;	/* Index to area in LV segment */
-};
-
-struct physical_volume {
-	struct id id;
-	struct device *dev;
-	const struct format_type *fmt;
-	const char *vg_name;
-	struct id vgid;
-
-	uint32_t status;
-	uint64_t size;
-
-	/* physical extents */
-	uint32_t pe_size;
-	uint64_t pe_start;
-	uint32_t pe_count;
-	uint32_t pe_alloc_count;
-
-	struct list segments;	/* Ordered pv_segments covering complete PV */
-	struct list tags;
-};
-
-typedef struct physical_volume pv_t;
 struct metadata_area;
-struct format_instance;
 
 /* Per-format per-metadata area operations */
 struct metadata_area_ops {
@@ -198,142 +132,16 @@
 	void *metadata_locn;
 };
 
-struct format_instance {
-	const struct format_type *fmt;
-	struct list metadata_areas;	/* e.g. metadata locations */
-	void *private;
-};
-
-struct volume_group {
-	struct cmd_context *cmd;
-	struct format_instance *fid;
-	uint32_t seqno;		/* Metadata sequence number */
-
-	struct id id;
-	char *name;
-	char *system_id;
-
-	uint32_t status;
-	alloc_policy_t alloc;
-
-	uint32_t extent_size;
-	uint32_t extent_count;
-	uint32_t free_count;
-
-	uint32_t max_lv;
-	uint32_t max_pv;
-
-	/* physical volumes */
-	uint32_t pv_count;
-	struct list pvs;
-
-	/* logical volumes */
-	uint32_t lv_count;
-	uint32_t snapshot_count;
-	struct list lvs;
-
-	struct list tags;
-};
-
-typedef struct volume_group vg_t;
-
-/* There will be one area for each stripe */
-struct lv_segment_area {
-	area_type_t type;
-	union {
-		struct {
-			struct pv_segment *pvseg;
-		} pv;
-		struct {
-			struct logical_volume *lv;
-			uint32_t le;
-		} lv;
-	} u;
-};
-
-struct segment_type;
-struct lv_segment {
-	struct list list;
-	struct logical_volume *lv;
-
-	const struct segment_type *segtype;
-	uint32_t le;
-	uint32_t len;
-
-	uint32_t status;
-
-	/* FIXME Fields depend on segment type */
-	uint32_t stripe_size;
-	uint32_t area_count;
-	uint32_t area_len;
-	struct logical_volume *origin;
-	struct logical_volume *cow;
-	struct list origin_list;
-	uint32_t chunk_size;	/* For snapshots - in sectors */
-	uint32_t region_size;	/* For mirrors - in sectors */
-	uint32_t extents_copied;
-	struct logical_volume *log_lv;
-	struct lv_segment *mirror_seg;
-
-	struct list tags;
-
-	struct lv_segment_area *areas;
-};
-
-#define seg_type(seg, s)	(seg)->areas[(s)].type
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
-#define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
 #define seg_pe(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pe
-#define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
 #define seg_le(seg, s)		(seg)->areas[(s)].u.lv.le
 
-struct logical_volume {
-	union lvid lvid;
-	char *name;
-
-	struct volume_group *vg;
-
-	uint32_t status;
-	alloc_policy_t alloc;
-	uint32_t read_ahead;
-	int32_t major;
-	int32_t minor;
-
-	uint64_t size;		/* Sectors */
-	uint32_t le_count;
-
-	uint32_t origin_count;
-	struct list snapshot_segs;
-	struct lv_segment *snapshot;
-
-	struct list segments;
-	struct list tags;
-};
-
 struct name_list {
 	struct list list;
 	char *name;
 };
 
-struct pe_range {
-	struct list list;
-	uint32_t start;		/* PEs */
-	uint32_t count;		/* PEs */
-};
-
-struct pv_list {
-	struct list list;
-	struct physical_volume *pv;
-	struct list *mdas;	/* Metadata areas */
-	struct list *pe_ranges;	/* Ranges of PEs e.g. for allocation */
-};
-
-struct lv_list {
-	struct list list;
-	struct logical_volume *lv;
-};
-
 struct mda_list {
 	struct list list;
 	struct device_area mda;
@@ -421,80 +229,8 @@
  */
 unsigned long pe_align(void);
 int vg_validate(struct volume_group *vg);
-int vg_write(struct volume_group *vg);
-int vg_commit(struct volume_group *vg);
-int vg_revert(struct volume_group *vg);
-struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, int *consistent);
-struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				struct list *mdas, uint64_t *label_sector,
-				int warnings);
-struct list *get_pvs(struct cmd_context *cmd);
-
-/* Set full_scan to 1 to re-read every (filtered) device label */
-struct list *get_vgs(struct cmd_context *cmd, int full_scan);
-struct list *get_vgids(struct cmd_context *cmd, int full_scan);
 
-int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
-	     struct list *mdas, int64_t label_sector);
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
-int is_orphan(pv_t *pv);
-
-/* pe_start and pe_end relate to any existing data so that new metadata
- * areas can avoid overlap */
-pv_t *pv_create(const struct format_type *fmt,
-		      struct device *dev,
-		      struct id *id,
-		      uint64_t size,
-		      uint64_t pe_start,
-		      uint32_t existing_extent_count,
-		      uint32_t existing_extent_size,
-		      int pvmetadatacopies,
-		      uint64_t pvmetadatasize, struct list *mdas);
-int pv_resize(struct physical_volume *pv, struct volume_group *vg,
-              uint32_t new_pe_count);
-int pv_analyze(struct cmd_context *cmd, const char *pv_name,
-	       int64_t label_sector);
-
-struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
-			       uint32_t extent_size, uint32_t max_pv,
-			       uint32_t max_lv, alloc_policy_t alloc,
-			       int pv_count, char **pv_names);
-int vg_remove(struct volume_group *vg);
-int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
-	      const char *new_name);
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
-int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
-		     uint32_t new_extent_size);
-int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
-		  struct volume_group *vg_to);
-
-/* Manipulate LVs */
-struct logical_volume *lv_create_empty(struct format_instance *fi,
-				       const char *name,
-				       union lvid *lvid,
-				       uint32_t status,
-				       alloc_policy_t alloc,
-				       int import,
-				       struct volume_group *vg);
-
-/* Reduce the size of an LV by extents */
-int lv_reduce(struct logical_volume *lv, uint32_t extents);
-
-/* Empty an LV prior to deleting it */
-int lv_empty(struct logical_volume *lv);
-
-/* Entry point for all LV extent allocations */
-int lv_extend(struct logical_volume *lv,
-	      const struct segment_type *segtype,
-	      uint32_t stripes, uint32_t stripe_size,
-	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
-	      uint32_t status, struct list *allocatable_pvs,
-	      alloc_policy_t alloc);
-
-/* lv must be part of lv->vg->lvs */
-int lv_remove(struct logical_volume *lv);
 
 /* Manipulate PV structures */
 int pv_add(struct volume_group *vg, struct physical_volume *pv);
@@ -502,14 +238,10 @@
 struct physical_volume *pv_find(struct volume_group *vg, const char *pv_name);
 
 /* Find a PV within a given VG */
-struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
-pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv);
 
-/* Find an LV within a given VG */
-struct lv_list *find_lv_in_vg(struct volume_group *vg, const char *lv_name);
 struct lv_list *find_lv_in_vg_by_lvid(struct volume_group *vg,
 				      const union lvid *lvid);
 
@@ -524,13 +256,9 @@
 
 /* FIXME Merge these functions with ones above */
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev);
-struct logical_volume *find_lv(struct volume_group *vg, const char *lv_name);
-struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
-					const char *pv_name);
 
 /* Find LV segment containing given LE */
 struct lv_segment *find_seg_by_le(struct logical_volume *lv, uint32_t le);
-struct lv_segment *first_seg(struct logical_volume *lv);
 
 /* Find PV segment containing given LE */
 struct pv_segment *find_peg_by_pe(struct physical_volume *pv, uint32_t pe);
@@ -559,100 +287,26 @@
 int lv_split_segment(struct logical_volume *lv, uint32_t le);
 
 /*
- * Useful functions for managing snapshots.
- */
-int lv_is_origin(const struct logical_volume *lv);
-int lv_is_cow(const struct logical_volume *lv);
-int lv_is_visible(const struct logical_volume *lv);
-
-int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
-
-/* Given a cow LV, return return the snapshot lv_segment that uses it */
-struct lv_segment *find_cow(const struct logical_volume *lv);
-
-/* Given a cow LV, return its origin */
-struct logical_volume *origin_from_cow(const struct logical_volume *lv);
-
-int vg_add_snapshot(struct format_instance *fid, const char *name,
-		    struct logical_volume *origin, struct logical_volume *cow,
-		    union lvid *lvid, uint32_t extent_count,
-		    uint32_t chunk_size);
-
-int vg_remove_snapshot(struct logical_volume *cow);
-
-int vg_check_status(struct volume_group *vg, uint32_t status);
-
-/*
  * Mirroring functions
  */
-struct alloc_handle;
-uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
-                                     uint32_t region_size);
-int create_mirror_layers(struct alloc_handle *ah,
-			 uint32_t first_area,
-			 uint32_t num_mirrors,
-			 struct logical_volume *lv,
-			 const struct segment_type *segtype,
-			 uint32_t status,
-			 uint32_t region_size,
-			 struct logical_volume *log_lv);
 int add_mirror_layers(struct alloc_handle *ah,
 		      uint32_t num_mirrors,
 		      uint32_t existing_mirrors,
 		      struct logical_volume *lv,
 		      const struct segment_type *segtype);
 
-int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			 struct list *removable_pvs, int remove_log);
-int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			      struct list *removable_pvs, int remove_log);
 /*
  * Given mirror image or mirror log segment, find corresponding mirror segment 
  */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int fixup_imported_mirrors(struct volume_group *vg);
 
-int insert_pvmove_mirrors(struct cmd_context *cmd,
-			  struct logical_volume *lv_mirr,
-			  struct list *source_pvl,
-			  struct logical_volume *lv,
-			  struct list *allocatable_pvs,
-			  alloc_policy_t alloc,
-			  struct list *lvs_changed);
-int remove_pvmove_mirrors(struct volume_group *vg,
-			  struct logical_volume *lv_mirr);
-struct logical_volume *find_pvmove_lv(struct volume_group *vg,
-				      struct device *dev, uint32_t lv_type);
-struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
-						  struct volume_group *vg,
-						  const char *name,
-						  uint32_t lv_type);
-const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
-const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-float copy_percent(struct logical_volume *lv_mirr);
-struct list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
-			  struct logical_volume *lv);
-
-uint32_t find_free_lvnum(struct logical_volume *lv);
-char *generate_lv_name(struct volume_group *vg, const char *format,
-		       char *buffer, size_t len);
-
 /*
  * Begin skeleton for external LVM library
  */
 struct id pv_id(pv_t *pv);
 const struct format_type *pv_format_type(pv_t *pv);
 struct id pv_vgid(pv_t *pv);
-struct device *pv_dev(pv_t *pv);
-const char *pv_vg_name(pv_t *pv);
-uint64_t pv_size(pv_t *pv);
-uint32_t pv_status(pv_t *pv);
-uint32_t pv_pe_size(pv_t *pv);
-uint64_t pv_pe_start(pv_t *pv);
-uint32_t pv_pe_count(pv_t *pv);
-uint32_t pv_pe_alloc_count(pv_t *pv);
-
-uint32_t vg_status(vg_t *vg);
 
 pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
--- LVM2/lib/report/report.h	2005/04/19 20:58:25	1.3
+++ LVM2/lib/report/report.h	2007/07/18 15:38:58	1.4
@@ -16,7 +16,7 @@
 #ifndef _LVM_REPORT_H
 #define _LVM_REPORT_H
 
-#include "metadata.h"
+#include "metadata-exported.h"
 
 typedef enum { LVS = 1, PVS = 2, VGS = 4, SEGS = 8, PVSEGS = 16 } report_type_t;
 
--- LVM2/lib/striped/striped.c	2006/10/18 18:01:52	1.20
+++ LVM2/lib/striped/striped.c	2007/07/18 15:38:58	1.21
@@ -25,6 +25,7 @@
 #include "lvm-string.h"
 #include "activate.h"
 #include "pv_alloc.h"
+#include "metadata.h"
 
 static const char *_striped_name(const struct lv_segment *seg)
 {
--- LVM2/lib/zero/zero.c	2006/10/18 18:01:52	1.11
+++ LVM2/lib/zero/zero.c	2007/07/18 15:38:58	1.12
@@ -23,6 +23,7 @@
 #include "targets.h"
 #include "lvm-string.h"
 #include "activate.h"
+#include "metadata.h"
 
 static const char *_zero_name(const struct lv_segment *seg)
 {
--- LVM2/tools/polldaemon.h	2004/05/05 17:56:20	1.1
+++ LVM2/tools/polldaemon.h	2007/07/18 15:38:58	1.2
@@ -16,7 +16,7 @@
 #ifndef _LVM_TOOL_POLLDAEMON_H
 #define _LVM_TOOL_POLLDAEMON_H
 
-#include "metadata.h"
+#include "metadata-exported.h"
 
 struct poll_functions {
 	const char *(*get_copy_name_from_lv) (struct logical_volume * lv_mirr);
--- LVM2/tools/toollib.h	2007/03/26 16:10:10	1.46
+++ LVM2/tools/toollib.h	2007/07/18 15:38:58	1.47
@@ -16,7 +16,7 @@
 #ifndef _LVM_TOOLLIB_H
 #define _LVM_TOOLLIB_H
 
-#include "metadata.h"
+#include "metadata-exported.h"
 
 int autobackup_set(void);
 int autobackup_init(const char *backup_dir, int keep_days, int keep_number,
--- LVM2/tools/tools.h	2006/09/26 09:35:43	1.52
+++ LVM2/tools/tools.h	2007/07/18 15:38:58	1.53
@@ -38,8 +38,7 @@
 #include "filter-composite.h"
 #include "filter-persistent.h"
 #include "filter-regex.h"
-#include "format-text.h"
-#include "metadata.h"
+#include "metadata-exported.h"
 #include "list.h"
 #include "locking.h"
 #include "lvm-exec.h"


