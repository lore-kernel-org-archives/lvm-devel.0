From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 24 Nov 2009 22:55:59 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/for ...
Message-ID: <20091124225559.11196.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-11-24 22:55:56

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 
	lib/format_text: export.c flags.c format-text.c format-text.h 
	                 import-export.h import.c import_vsn1.c 
	                 text_label.c 
	lib/metadata   : lv_alloc.h lv_manip.c metadata-exported.h 
	                 metadata.c mirror.c 

Log message:
	Switch status from 32-bit to 64-bit
	
	The physical_volume, volume_group, logical_volume and lv_segment
	structures' 'status' member is now uint64_t.
	
	The alignment of these structures was also audited to remove holes.  The
	movement of some members in 'volume_group' and 'lv_segment' eliminates
	holes.  The 'physical_volume' structure still has one 4-byte hole after
	'pe_size'; the other structures no longer have any holes.  Each
	structures' size has not changed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1330&r2=1.1331
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.298&r2=1.299
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2009/11/24 19:04:23	1.1330
+++ LVM2/WHATS_NEW	2009/11/24 22:55:55	1.1331
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+ Switch status from 32-bit to 64-bit.
 
 Version 2.02.56 - 24th November 2009
 ====================================
--- LVM2/lib/display/display.c	2009/11/03 10:50:57	1.107
+++ LVM2/lib/display/display.c	2009/11/24 22:55:56	1.108
@@ -317,7 +317,7 @@
 		return;
 	}
 
-	log_print("%s:%s:%" PRIu64 ":-1:%u:%u:-1:%" PRIu32 ":%u:%u:%u:%s",
+	log_print("%s:%s:%" PRIu64 ":-1:%" PRIu64 ":%" PRIu64 ":-1:%" PRIu32 ":%u:%u:%u:%s",
 		  pv_dev_name(pv), pv->vg_name, pv->size,
 		  /* FIXME pv->pv_number, Derive or remove? */
 		  pv->status,	/* FIXME Support old or new format here? */
@@ -459,7 +459,7 @@
 	struct lvinfo info;
 	inkernel = lv_info(lv->vg->cmd, lv, &info, 1, 0) && info.exists;
 
-	log_print("%s%s/%s:%s:%d:%d:-1:%d:%" PRIu64 ":%d:-1:%d:%d:%d:%d",
+	log_print("%s%s/%s:%s:%" PRIu64 ":%d:-1:%d:%" PRIu64 ":%d:-1:%d:%d:%d:%d",
 		  lv->vg->cmd->dev_dir,
 		  lv->vg->name,
 		  lv->name,
@@ -760,7 +760,7 @@
 		return;
 	}
 
-	log_print("%s:%s:%d:-1:%u:%u:%u:-1:%u:%u:%u:%" PRIu64 ":%" PRIu32
+	log_print("%s:%s:%" PRIu64 ":-1:%u:%u:%u:-1:%u:%u:%u:%" PRIu64 ":%" PRIu32
 		  ":%u:%u:%u:%s",
 		vg->name,
 		access_str,
--- LVM2/lib/format_text/export.c	2009/11/03 11:00:46	1.71
+++ LVM2/lib/format_text/export.c	2009/11/24 22:55:56	1.72
@@ -349,7 +349,7 @@
 	return 1;
 }
 
-static int _print_flag_config(struct formatter *f, int status, int type)
+static int _print_flag_config(struct formatter *f, uint64_t status, int type)
 {
 	char buffer[4096];
 	if (!print_flags(status, type | STATUS_FLAG, buffer, sizeof(buffer)))
--- LVM2/lib/format_text/flags.c	2009/07/15 20:02:47	1.37
+++ LVM2/lib/format_text/flags.c	2009/11/24 22:55:56	1.38
@@ -23,7 +23,7 @@
  * converted into arrays of strings.
  */
 struct flag {
-	const int mask;
+	const uint64_t mask;
 	const char *description;
 	int kind;
 };
@@ -91,7 +91,7 @@
  * using one of the tables defined at the top of
  * the file.
  */
-int print_flags(uint32_t status, int type, char *buffer, size_t size)
+int print_flags(uint64_t status, int type, char *buffer, size_t size)
 {
 	int f, first = 1;
 	struct flag *flags;
@@ -135,10 +135,10 @@
 	return 1;
 }
 
-int read_flags(uint32_t *status, int type, struct config_value *cv)
+int read_flags(uint64_t *status, int type, struct config_value *cv)
 {
 	int f;
-	uint32_t s = 0;
+	uint64_t s = UINT64_C(0);
 	struct flag *flags;
 
 	if (!(flags = _get_flags(type)))
--- LVM2/lib/format_text/format-text.c	2009/08/01 17:07:37	1.115
+++ LVM2/lib/format_text/format-text.c	2009/11/24 22:55:56	1.116
@@ -1037,7 +1037,7 @@
 
 const char *vgname_from_mda(const struct format_type *fmt,
 			    struct device_area *dev_area, struct id *vgid,
-			    uint32_t *vgstatus, char **creation_host,
+			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors)
 {
 	struct raw_locn *rlocn;
@@ -1146,7 +1146,7 @@
 	struct volume_group *vg;
 	struct format_instance fid;
 	struct id vgid;
-	uint32_t vgstatus;
+	uint64_t vgstatus;
 
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
--- LVM2/lib/format_text/format-text.h	2008/11/03 22:14:28	1.25
+++ LVM2/lib/format_text/format-text.h	2009/11/24 22:55:56	1.26
@@ -61,7 +61,7 @@
 
 const char *vgname_from_mda(const struct format_type *fmt,
 			    struct device_area *dev_area, struct id *vgid,
-			    uint32_t *vgstatus, char **creation_host,
+			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors);
 
 #endif
--- LVM2/lib/format_text/import-export.h	2008/11/03 22:14:28	1.22
+++ LVM2/lib/format_text/import-export.h	2009/11/24 22:55:56	1.23
@@ -51,14 +51,14 @@
 			   time_t *when, char **desc);
 	const char *(*read_vgname) (const struct format_type *fmt,
 				    struct config_tree *cft,
-				    struct id *vgid, uint32_t *vgstatus,
+				    struct id *vgid, uint64_t *vgstatus,
 				    char **creation_host);
 };
 
 struct text_vg_version_ops *text_vg_vsn1_init(void);
 
-int print_flags(uint32_t status, int type, char *buffer, size_t size);
-int read_flags(uint32_t *status, int type, struct config_value *cv);
+int print_flags(uint64_t status, int type, char *buffer, size_t size);
+int read_flags(uint64_t *status, int type, struct config_value *cv);
 
 int print_tags(struct dm_list *tags, char *buffer, size_t size);
 int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv);
@@ -81,7 +81,7 @@
                                off_t offset, uint32_t size,
                                off_t offset2, uint32_t size2,
                                checksum_fn_t checksum_fn, uint32_t checksum,
-                               struct id *vgid, uint32_t *vgstatus,
+                               struct id *vgid, uint64_t *vgstatus,
 			       char **creation_host);
 
 #endif
--- LVM2/lib/format_text/import.c	2008/04/01 22:40:12	1.47
+++ LVM2/lib/format_text/import.c	2009/11/24 22:55:56	1.48
@@ -40,7 +40,7 @@
 			       off_t offset, uint32_t size,
 			       off_t offset2, uint32_t size2,
 			       checksum_fn_t checksum_fn, uint32_t checksum,
-			       struct id *vgid, uint32_t *vgstatus,
+			       struct id *vgid, uint64_t *vgstatus,
 			       char **creation_host)
 {
 	struct config_tree *cft;
--- LVM2/lib/format_text/import_vsn1.c	2009/09/28 17:46:16	1.65
+++ LVM2/lib/format_text/import_vsn1.c	2009/11/24 22:55:56	1.66
@@ -125,7 +125,7 @@
 	return 1;
 }
 
-static int _read_flag_config(struct config_node *n, uint32_t *status, int type)
+static int _read_flag_config(struct config_node *n, uint64_t *status, int type)
 {
 	struct config_node *cn;
 	*status = 0;
@@ -809,7 +809,7 @@
 
 static const char *_read_vgname(const struct format_type *fmt,
 				struct config_tree *cft, struct id *vgid,
-				uint32_t *vgstatus, char **creation_host)
+				uint64_t *vgstatus, char **creation_host)
 {
 	struct config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
--- LVM2/lib/format_text/text_label.c	2009/07/15 20:02:47	1.25
+++ LVM2/lib/format_text/text_label.c	2009/11/24 22:55:56	1.26
@@ -259,7 +259,7 @@
 	struct id vgid;
 	struct mda_context *mdac;
 	const char *vgname;
-	uint32_t vgstatus;
+	uint64_t vgstatus;
 	char *creation_host;
 
 	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
--- LVM2/lib/metadata/lv_alloc.h	2008/12/19 15:24:53	1.23
+++ LVM2/lib/metadata/lv_alloc.h	2009/11/24 22:55:56	1.24
@@ -19,7 +19,7 @@
 				    const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
-				    uint32_t status,
+				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
 				    uint32_t area_count,
@@ -29,7 +29,7 @@
 				    uint32_t extents_copied);
 
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
-				      uint32_t status, uint32_t old_le_count);
+				      uint64_t status, uint32_t old_le_count);
 
 int set_lv_segment_area_pv(struct lv_segment *seg, uint32_t area_num,
 			   struct physical_volume *pv, uint32_t pe);
@@ -57,7 +57,7 @@
 		   struct logical_volume *lv,
                    const struct segment_type *segtype,
                    uint32_t stripe_size,
-                   uint32_t status,   
+                   uint64_t status,
 		   uint32_t region_size,
                    struct logical_volume *log_lv);
 
@@ -67,10 +67,10 @@
 int lv_add_mirror_lvs(struct logical_volume *lv,
 		      struct logical_volume **sub_lvs,
 		      uint32_t num_extra_areas,
-		      uint32_t status, uint32_t region_size);
+		      uint64_t status, uint32_t region_size);
 
 int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv);
-int lv_add_virtual_segment(struct logical_volume *lv, uint32_t status,
+int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
                            uint32_t extents, const struct segment_type *segtype);
 
 void alloc_destroy(struct alloc_handle *ah);
--- LVM2/lib/metadata/lv_manip.c	2009/10/26 10:01:57	1.185
+++ LVM2/lib/metadata/lv_manip.c	2009/11/24 22:55:56	1.186
@@ -167,7 +167,7 @@
 				    const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
-				    uint32_t status,
+				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
 				    uint32_t area_count,
@@ -213,7 +213,7 @@
 }
 
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
-				      uint32_t status, uint32_t old_le_count)
+				      uint64_t status, uint32_t old_le_count)
 {
 	struct lv_segment *seg;
 	const struct segment_type *segtype;
@@ -639,7 +639,7 @@
 	return 1;
 }
 
-static int _setup_alloced_segment(struct logical_volume *lv, uint32_t status,
+static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 				  uint32_t area_count,
 				  uint32_t stripe_size,
 				  const struct segment_type *segtype,
@@ -682,7 +682,7 @@
 static int _setup_alloced_segments(struct logical_volume *lv,
 				   struct dm_list *alloced_areas,
 				   uint32_t area_count,
-				   uint32_t status,
+				   uint64_t status,
 				   uint32_t stripe_size,
 				   const struct segment_type *segtype,
 				   uint32_t region_size,
@@ -1278,7 +1278,7 @@
 	return r;
 }
 
-int lv_add_virtual_segment(struct logical_volume *lv, uint32_t status,
+int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 			   uint32_t extents, const struct segment_type *segtype)
 {
 	struct lv_segment *seg;
@@ -1355,7 +1355,7 @@
 		   struct logical_volume *lv,
 		   const struct segment_type *segtype,
 		   uint32_t stripe_size,
-		   uint32_t status,
+		   uint64_t status,
 		   uint32_t region_size,
 		   struct logical_volume *log_lv)
 {
@@ -1495,7 +1495,7 @@
 int lv_add_mirror_lvs(struct logical_volume *lv,
 		      struct logical_volume **sub_lvs,
 		      uint32_t num_extra_areas,
-		      uint32_t status, uint32_t region_size)
+		      uint64_t status, uint32_t region_size)
 {
 	struct lv_segment *seg;
 	uint32_t old_area_count, new_area_count;
@@ -1620,7 +1620,7 @@
 	      uint32_t mirrors, uint32_t extents,
 	      struct physical_volume *mirrored_pv __attribute((unused)),
 	      uint32_t mirrored_pe __attribute((unused)),
-	      uint32_t status, struct dm_list *allocatable_pvs,
+	      uint64_t status, struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc)
 {
 	int r = 1;
@@ -1885,7 +1885,7 @@
  */
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
-				       uint32_t status,
+				       uint64_t status,
 				       alloc_policy_t alloc,
 				       struct volume_group *vg)
 {
@@ -2266,7 +2266,7 @@
 int remove_layers_for_segments(struct cmd_context *cmd,
 			       struct logical_volume *lv,
 			       struct logical_volume *layer_lv,
-			       uint32_t status_mask, struct dm_list *lvs_changed)
+			       uint64_t status_mask, struct dm_list *lvs_changed)
 {
 	struct lv_segment *seg, *lseg;
 	uint32_t s;
@@ -2298,7 +2298,7 @@
 			}
 			if ((lseg->status & status_mask) != status_mask) {
 				log_error("Layer status does not match: "
-					  "%s:%" PRIu32 " status: 0x%x/0x%x",
+					  "%s:%" PRIu32 " status: 0x%" PRIx64 "/0x%" PRIx64,
 					  layer_lv->name, lseg->le,
 					  lseg->status, status_mask);
 				return 0;
@@ -2347,7 +2347,7 @@
 /* Remove a layer */
 int remove_layers_for_segments_all(struct cmd_context *cmd,
 				   struct logical_volume *layer_lv,
-				   uint32_t status_mask,
+				   uint64_t status_mask,
 				   struct dm_list *lvs_changed)
 {
 	struct lv_list *lvl;
@@ -2372,7 +2372,7 @@
 
 static int _move_lv_segments(struct logical_volume *lv_to,
 			     struct logical_volume *lv_from,
-			     uint32_t set_status, uint32_t reset_status)
+			     uint64_t set_status, uint64_t reset_status)
 {
 	struct lv_segment *seg;
 
@@ -2454,7 +2454,7 @@
  */
 struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   struct logical_volume *lv_where,
-					   uint32_t status,
+					   uint64_t status,
 					   const char *layer_suffix)
 {
 	struct logical_volume *layer_lv;
@@ -2543,7 +2543,7 @@
  */
 static int _extend_layer_lv_for_segment(struct logical_volume *layer_lv,
 					struct lv_segment *seg, uint32_t s,
-					uint32_t status)
+					uint64_t status)
 {
 	struct lv_segment *mapseg;
 	struct segment_type *segtype;
@@ -2690,7 +2690,7 @@
 int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 				    struct logical_volume *lv_where,
 				    struct logical_volume *layer_lv,
-				    uint32_t status,
+				    uint64_t status,
 				    struct pv_list *pvl,
 				    struct dm_list *lvs_changed)
 {
@@ -2833,7 +2833,7 @@
 {
 	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
-	uint32_t status = 0;
+	uint64_t status = UINT64_C(0);
 	struct logical_volume *lv, *org = NULL;
 	int origin_active = 0;
 	char lv_name_buf[128];
--- LVM2/lib/metadata/metadata-exported.h	2009/11/23 10:44:51	1.123
+++ LVM2/lib/metadata/metadata-exported.h	2009/11/24 22:55:56	1.124
@@ -181,7 +181,7 @@
 	const char *vg_name;
 	struct id vgid;
 
-	uint32_t status;
+	uint64_t status;
 	uint64_t size;
 
 	/* physical extents */
@@ -208,13 +208,13 @@
 	struct format_instance *fid;
 	uint32_t seqno;		/* Metadata sequence number */
 
+	alloc_policy_t alloc;
+	uint64_t status;
+
 	struct id id;
 	char *name;
 	char *system_id;
 
-	uint32_t status;
-	alloc_policy_t alloc;
-
 	uint32_t extent_size;
 	uint32_t extent_count;
 	uint32_t free_count;
@@ -285,16 +285,16 @@
 	uint32_t le;
 	uint32_t len;
 
-	uint32_t status;
+	uint64_t status;
 
 	/* FIXME Fields depend on segment type */
 	uint32_t stripe_size;
 	uint32_t area_count;
 	uint32_t area_len;
+	uint32_t chunk_size;	/* For snapshots - in sectors */
 	struct logical_volume *origin;
 	struct logical_volume *cow;
 	struct dm_list origin_list;
-	uint32_t chunk_size;	/* For snapshots - in sectors */
 	uint32_t region_size;	/* For mirrors - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
@@ -315,7 +315,7 @@
 
 	struct volume_group *vg;
 
-	uint32_t status;
+	uint64_t status;
 	alloc_policy_t alloc;
 	uint32_t read_ahead;
 	int32_t major;
@@ -479,7 +479,7 @@
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
-				       uint32_t status,
+				       uint64_t status,
 				       alloc_policy_t alloc,
 				       struct volume_group *vg);
 
@@ -502,7 +502,7 @@
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t extents,
 	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
-	      uint32_t status, struct dm_list *allocatable_pvs,
+	      uint64_t status, struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc);
 
 /* lv must be part of lv->vg->lvs */
@@ -565,16 +565,16 @@
 int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 				    struct logical_volume *lv_where,
 				    struct logical_volume *layer_lv,
-				    uint32_t status,
+				    uint64_t status,
 				    struct pv_list *pv,
 				    struct dm_list *lvs_changed);
 int remove_layers_for_segments(struct cmd_context *cmd,
 			       struct logical_volume *lv,
 			       struct logical_volume *layer_lv,
-			       uint32_t status_mask, struct dm_list *lvs_changed);
+			       uint64_t status_mask, struct dm_list *lvs_changed);
 int remove_layers_for_segments_all(struct cmd_context *cmd,
 				   struct logical_volume *layer_lv,
-				   uint32_t status_mask,
+				   uint64_t status_mask,
 				   struct dm_list *lvs_changed);
 int split_parent_segments_for_layer(struct cmd_context *cmd,
 				    struct logical_volume *layer_lv);
@@ -582,7 +582,7 @@
 			 struct logical_volume *layer_lv);
 struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   struct logical_volume *lv_where,
-					   uint32_t status,
+					   uint64_t status,
 					   const char *layer_suffix);
 
 /* Find a PV within a given VG */
@@ -632,7 +632,7 @@
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
-int vg_check_status(const struct volume_group *vg, uint32_t status);
+int vg_check_status(const struct volume_group *vg, uint64_t status);
 
 /*
  * Returns visible LV count - number of LVs from user perspective
@@ -654,7 +654,7 @@
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
-		      struct dm_list *pvs, uint32_t status_mask);
+		      struct dm_list *pvs, uint64_t status_mask);
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
@@ -662,7 +662,7 @@
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
                                     uint32_t region_size);
 int remove_mirrors_from_segments(struct logical_volume *lv,
-				 uint32_t new_mirrors, uint32_t status_mask);
+				 uint32_t new_mirrors, uint64_t status_mask);
 int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 			    uint32_t mirrors, uint32_t region_size,
 			    struct dm_list *allocatable_pvs, alloc_policy_t alloc);
@@ -711,7 +711,7 @@
 const char *pv_vg_name(const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
-uint32_t pv_status(const struct physical_volume *pv);
+uint64_t pv_status(const struct physical_volume *pv);
 uint32_t pv_pe_size(const struct physical_volume *pv);
 uint64_t pv_pe_start(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
@@ -722,7 +722,7 @@
 
 int vg_missing_pv_count(const struct volume_group *vg);
 uint32_t vg_seqno(const struct volume_group *vg);
-uint32_t vg_status(const struct volume_group *vg);
+uint64_t vg_status(const struct volume_group *vg);
 uint64_t vg_size(const struct volume_group *vg);
 uint64_t vg_free(const struct volume_group *vg);
 uint64_t vg_extent_size(const struct volume_group *vg);
--- LVM2/lib/metadata/metadata.c	2009/11/23 10:44:51	1.298
+++ LVM2/lib/metadata/metadata.c	2009/11/24 22:55:56	1.299
@@ -56,7 +56,7 @@
 						      const struct id *id);
 
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
-				    uint32_t status);
+				    uint64_t status);
 
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
@@ -3220,7 +3220,7 @@
  * FIXME Remove the unnecessary duplicate definitions and return bits directly.
  */
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
-				    uint32_t status)
+				    uint64_t status)
 {
 	uint32_t failure = 0;
 
@@ -3257,7 +3257,7 @@
  * @vg - volume group to check status flags
  * @status - specific status flags to check (e.g. EXPORTED_VG)
  */
-int vg_check_status(const struct volume_group *vg, uint32_t status)
+int vg_check_status(const struct volume_group *vg, uint64_t status)
 {
 	return !_vg_bad_status_bits(vg, status);
 }
@@ -3303,7 +3303,7 @@
  */
 static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			       const char *vgid, uint32_t lock_flags,
-			       uint32_t status_flags, uint32_t misc_flags)
+			       uint64_t status_flags, uint32_t misc_flags)
 {
 	struct volume_group *vg = NULL;
 	const char *lock_name;
@@ -3429,7 +3429,7 @@
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 	      const char *vgid, uint32_t flags)
 {
-	uint32_t status = 0;
+	uint64_t status = UINT64_C(0);
 	uint32_t lock_flags = LCK_VG_READ;
 
 	if (flags & READ_FOR_UPDATE) {
@@ -3548,7 +3548,7 @@
 	return pv_field(pv, size);
 }
 
-uint32_t pv_status(const struct physical_volume *pv)
+uint64_t pv_status(const struct physical_volume *pv)
 {
 	return pv_field(pv, status);
 }
@@ -3586,7 +3586,7 @@
 	return vg->seqno;
 }
 
-uint32_t vg_status(const struct volume_group *vg)
+uint64_t vg_status(const struct volume_group *vg)
 {
 	return vg->status;
 }
--- LVM2/lib/metadata/mirror.c	2009/11/19 13:42:38	1.95
+++ LVM2/lib/metadata/mirror.c	2009/11/24 22:55:56	1.96
@@ -973,7 +973,7 @@
  * has the status bits on.
  */
 int remove_mirrors_from_segments(struct logical_volume *lv,
-				 uint32_t new_mirrors, uint32_t status_mask)
+				 uint32_t new_mirrors, uint64_t status_mask)
 {
 	struct lv_segment *seg;
 	uint32_t s;
@@ -986,7 +986,7 @@
 			return 0;
 		} if ((seg->status & status_mask) != status_mask) {
 			log_error("Segment status does not match: %s:%" PRIu32
-				  " status:0x%x/0x%x", lv->name, seg->le,
+				  " status:0x%" PRIx64 "/0x%" PRIx64, lv->name, seg->le,
 				  seg->status, status_mask);
 			return 0;
 		}
@@ -1609,7 +1609,7 @@
 int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
 		      struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count, struct dm_list *pvs,
-		      uint32_t status_mask)
+		      uint64_t status_mask)
 {
 	uint32_t new_mirrors;
 	struct lv_segment *seg;


