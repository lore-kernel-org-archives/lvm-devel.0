From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Oct 2009 17:41:58 -0000
Subject: LVM2 ./WHATS_NEW lib/Makefile.in lib/activate/ ...
Message-ID: <20091016174158.13829.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-10-16 17:41:53

Modified files:
	.              : WHATS_NEW 
	lib            : Makefile.in 
	lib/activate   : activate.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : config.c config.h 
	lib/format_text: export.c text_export.h 
	lib/metadata   : metadata-exported.h metadata.c segtype.c 
	                 segtype.h 
	tools          : vgcfgrestore.c 
Added files:
	lib/unknown    : unknown.c 
	test           : t-unknown-segment.sh 

Log message:
	Handle metadata with unknown segment types more gracefully.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1296&r2=1.1297
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.290&r2=1.291
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unknown-segment.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2009/10/14 04:10:41	1.1296
+++ LVM2/WHATS_NEW	2009/10/16 17:41:49	1.1297
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Handle metadata with unknown segment types more gracefully.
   Set default owner and group to null.
   Add dmeventd.static to the build.
   Disable realtime support code by default.
--- LVM2/lib/Makefile.in	2009/10/12 16:59:20	1.95
+++ LVM2/lib/Makefile.in	2009/10/16 17:41:50	1.96
@@ -47,6 +47,7 @@
 	device/device.c \
 	display/display.c \
 	error/errseg.c \
+	unknown/unknown.c \
 	filters/filter-composite.c \
 	filters/filter-persistent.c \
 	filters/filter-regex.c \
--- LVM2/lib/activate/activate.c	2009/10/01 00:35:29	1.156
+++ LVM2/lib/activate/activate.c	2009/10/16 17:41:50	1.157
@@ -1112,6 +1112,12 @@
 		goto_out;
 	}
 
+	if (lv_has_unknown_segments(lv)) {
+		log_error("Refusing activation of LV %s containing "
+			  "an unrecognised segment.", lv->name);
+		goto_out;
+	}
+
 	if (test_mode()) {
 		_skip("Activating '%s'.", lv->name);
 		r = 1;
--- LVM2/lib/commands/toolcontext.c	2009/09/28 16:23:45	1.85
+++ LVM2/lib/commands/toolcontext.c	2009/10/16 17:41:50	1.86
@@ -1085,6 +1085,7 @@
 	memset(cmd, 0, sizeof(*cmd));
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
+	cmd->handles_unknown_segments = 0;
 	cmd->hosttags = 0;
 	dm_list_init(&cmd->formats);
 	dm_list_init(&cmd->segtypes);
--- LVM2/lib/commands/toolcontext.h	2009/09/28 16:23:45	1.34
+++ LVM2/lib/commands/toolcontext.h	2009/10/16 17:41:50	1.35
@@ -69,6 +69,7 @@
 	char **argv;
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
+	unsigned handles_unknown_segments:1;
 	unsigned partial_activation:1;
 	unsigned si_unit_consistency:1;
 
--- LVM2/lib/config/config.c	2009/07/27 21:01:56	1.75
+++ LVM2/lib/config/config.c	2009/10/16 17:41:51	1.76
@@ -71,6 +71,8 @@
 struct output_line {
 	FILE *fp;
 	struct dm_pool *mem;
+	putline_fn putline;
+	void *putline_baton;
 };
 
 static void _get_token(struct parser *p, int tok_prev);
@@ -80,8 +82,8 @@
 static struct config_value *_value(struct parser *p);
 static struct config_value *_type(struct parser *p);
 static int _match_aux(struct parser *p, int t);
-static struct config_value *_create_value(struct parser *p);
-static struct config_node *_create_node(struct parser *p);
+static struct config_value *_create_value(struct dm_pool *mem);
+static struct config_node *_create_node(struct dm_pool *mem);
 static char *_dup_tok(struct parser *p);
 
 static const int sep = '/';
@@ -403,10 +405,14 @@
 	}
 
 	line = dm_pool_end_object(outline->mem);
-	if (!outline->fp)
-		log_print("%s", line);
-	else
-		fprintf(outline->fp, "%s\n", line);
+	if (outline->putline)
+		outline->putline(line, outline->putline_baton);
+	else {
+		if (!outline->fp)
+			log_print("%s", line);
+		else
+			fprintf(outline->fp, "%s\n", line);
+	}
 
 	return 1;
 }
@@ -498,6 +504,21 @@
 	return 1;
 }
 
+int write_config_node(struct config_node *cn, putline_fn putline, void *baton)
+{
+	struct output_line outline;
+	outline.fp = NULL;
+	outline.mem = dm_pool_create("config_line", 1024);
+	outline.putline = putline;
+	outline.putline_baton = baton;
+	if (!_write_config(cn, 0, &outline, 0)) {
+		dm_pool_destroy(outline.mem);
+		return_0;
+	}
+	dm_pool_destroy(outline.mem);
+	return 1;
+}
+
 int write_config_file(struct config_tree *cft, const char *file,
 		      int argc, char **argv)
 {
@@ -505,6 +526,7 @@
 	int r = 1;
 	struct output_line outline;
 	outline.fp = NULL;
+	outline.putline = NULL;
 
 	if (!file)
 		file = "stdout";
@@ -567,7 +589,7 @@
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 	struct config_node *root, *n, *l = NULL;
-	if (!(root = _create_node(p)))
+	if (!(root = _create_node(p->mem)))
 		return_0;
 
 	if (!(root->key = _dup_tok(p)))
@@ -622,7 +644,7 @@
 		 * Special case for an empty array.
 		 */
 		if (!h) {
-			if (!(h = _create_value(p)))
+			if (!(h = _create_value(p->mem)))
 				return NULL;
 
 			h->type = CFG_EMPTY_ARRAY;
@@ -637,7 +659,7 @@
 static struct config_value *_type(struct parser *p)
 {
 	/* [+-]{0,1}[0-9]+ | [0-9]*\.[0-9]* | ".*" */
-	struct config_value *v = _create_value(p);
+	struct config_value *v = _create_value(p->mem);
 
 	if (!v)
 		return NULL;
@@ -833,9 +855,9 @@
 /*
  * memory management
  */
-static struct config_value *_create_value(struct parser *p)
+static struct config_value *_create_value(struct dm_pool *mem)
 {
-	struct config_value *v = dm_pool_alloc(p->mem, sizeof(*v));
+	struct config_value *v = dm_pool_alloc(mem, sizeof(*v));
 
 	if (v)
 		memset(v, 0, sizeof(*v));
@@ -843,9 +865,9 @@
 	return v;
 }
 
-static struct config_node *_create_node(struct parser *p)
+static struct config_node *_create_node(struct dm_pool *mem)
 {
-	struct config_node *n = dm_pool_alloc(p->mem, sizeof(*n));
+	struct config_node *n = dm_pool_alloc(mem, sizeof(*n));
 
 	if (n)
 		memset(n, 0, sizeof(*n));
@@ -1297,3 +1319,33 @@
 	else
 		return 0;
 }
+
+static struct config_value *_clone_config_value(struct dm_pool *mem, const struct config_value *v)
+{
+	if (!v)
+		return NULL;
+	struct config_value *new = _create_value(mem);
+	new->type = v->type;
+	if (v->type == CFG_STRING)
+		new->v.str = dm_pool_strdup(mem, v->v.str);
+	else
+		new->v = v->v;
+	new->next = _clone_config_value(mem, v->next);
+	return new;
+}
+
+struct config_node *clone_config_node(struct dm_pool *mem, const struct config_node *cn,
+				      int siblings)
+{
+	if (!cn)
+		return NULL;
+	struct config_node *new = _create_node(mem);
+	new->key = dm_pool_strdup(mem, cn->key);
+	new->child = clone_config_node(mem, cn->child, 1);
+	new->v = _clone_config_value(mem, cn->v);
+	if (siblings)
+		new->sib = clone_config_node(mem, cn->sib, siblings);
+	else
+		new->sib = NULL;
+	return new;
+}
--- LVM2/lib/config/config.h	2009/07/27 21:01:58	1.28
+++ LVM2/lib/config/config.h	2009/10/16 17:41:51	1.29
@@ -69,6 +69,10 @@
 int read_config_file(struct config_tree *cft);
 int write_config_file(struct config_tree *cft, const char *file,
 		      int argc, char **argv);
+
+typedef int (*putline_fn)(const char *line, void *baton);
+int write_config_node(struct config_node *cn, putline_fn putline, void *baton);
+
 time_t config_file_timestamp(struct config_tree *cft);
 int config_file_changed(struct config_tree *cft);
 int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
@@ -114,4 +118,6 @@
 
 const char *config_parent_name(const struct config_node *n);
 
+struct config_node *clone_config_node(struct dm_pool *mem, const struct config_node *cn,
+				      int siblings);
 #endif
--- LVM2/lib/format_text/export.c	2009/05/19 09:48:32	1.69
+++ LVM2/lib/format_text/export.c	2009/10/16 17:41:51	1.70
@@ -293,6 +293,16 @@
 	return r;
 }
 
+static int _out_line(const char *line, void *_f) {
+	struct formatter *f = (struct formatter *) _f;
+	return out_text(f, "%s", line);
+}
+
+int out_config_node(struct formatter *f, const struct config_node *cn)
+{
+	return write_config_node(cn, _out_line, f);
+}
+
 static int _print_header(struct formatter *f,
 			 const char *desc)
 {
--- LVM2/lib/format_text/text_export.h	2008/03/10 18:51:27	1.4
+++ LVM2/lib/format_text/text_export.h	2009/10/16 17:41:51	1.5
@@ -21,6 +21,7 @@
 
 struct formatter;
 struct lv_segment;
+struct config_node;
 
 int out_size(struct formatter *f, uint64_t size, const char *fmt, ...)
     __attribute__ ((format(printf, 3, 4)));
@@ -31,6 +32,8 @@
 int out_text(struct formatter *f, const char *fmt, ...)
     __attribute__ ((format(printf, 2, 3)));
 
+int out_config_node(struct formatter *f, const struct config_node *cn);
+
 int out_areas(struct formatter *f, const struct lv_segment *seg,
 	      const char *type);
 
--- LVM2/lib/metadata/metadata-exported.h	2009/10/05 20:03:08	1.116
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/16 17:41:52	1.117
@@ -298,6 +298,7 @@
 	uint32_t region_size;	/* For mirrors - in sectors */
 	uint32_t extents_copied;
 	struct logical_volume *log_lv;
+	void *segtype_private;
 
 	struct dm_list tags;
 
@@ -734,6 +735,9 @@
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
 #define vg_is_resizeable(vg) (vg_status((vg)) & RESIZEABLE_VG)
 
+int lv_has_unknown_segments(const struct logical_volume *lv);
+int vg_has_unknown_segments(const struct volume_group *vg);
+
 struct vgcreate_params {
 	char *vg_name;
 	uint32_t extent_size;
--- LVM2/lib/metadata/metadata.c	2009/10/06 16:00:38	1.290
+++ LVM2/lib/metadata/metadata.c	2009/10/16 17:41:52	1.291
@@ -23,6 +23,7 @@
 #include "memlock.h"
 #include "str_list.h"
 #include "pv_alloc.h"
+#include "segtype.h"
 #include "activate.h"
 #include "display.h"
 #include "locking.h"
@@ -738,6 +739,27 @@
 	return (struct volume_group *)vg;
 }
 
+int lv_has_unknown_segments(const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+	/* foreach segment */
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg_unknown(seg))
+			return 1;
+	return 0;
+}
+
+int vg_has_unknown_segments(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+
+	/* foreach LV */
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_has_unknown_segments(lvl->lv))
+			return 1;
+	return 0;
+}
+
 /*
  * Create a VG with default parameters.
  * Returns:
@@ -2192,6 +2214,13 @@
 		return 0;
 	}
 
+	if (vg_has_unknown_segments(vg) && !vg->cmd->handles_unknown_segments) {
+		log_error("Cannot update volume group %s with unknown segments in it!",
+			  vg->name);
+		return 0;
+	}
+
+
 	if (dm_list_empty(&vg->fid->metadata_areas)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
 		return 0;
@@ -3317,6 +3346,11 @@
 		}
 	}
 
+	/*
+	 * Check that the tool can handle tricky cases -- missing PVs and
+	 * unknown segment types.
+	 */
+
 	if (!cmd->handles_missing_pvs && vg_missing_pv_count(vg) &&
 	    (lock_flags & LCK_WRITE)) {
 		log_error("Cannot change VG %s while PVs are missing!",
@@ -3325,6 +3359,14 @@
 		goto_bad;
 	}
 
+	if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg) &&
+	    (lock_flags & LCK_WRITE)) {
+		log_error("Cannot change VG %s with unknown segments in it!",
+			  vg->name);
+		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
+		goto_bad;
+	}
+
 	failure |= _vg_bad_status_bits(vg, status_flags);
 	if (failure)
 		goto_bad;
--- LVM2/lib/metadata/segtype.c	2008/11/03 22:14:29	1.4
+++ LVM2/lib/metadata/segtype.c	2009/10/16 17:41:52	1.5
@@ -27,6 +27,11 @@
 			return segtype;
 	}
 
-	log_error("Unrecognised segment type %s", str);
-	return NULL;
+	if (!(segtype = init_unknown_segtype(cmd, str)))
+		return_NULL;
+
+	segtype->library = NULL;
+	dm_list_add(&cmd->segtypes, &segtype->list);
+	log_warn("WARNING: Unrecognised segment type %s", str);
+	return segtype;
 }
--- LVM2/lib/metadata/segtype.h	2009/10/01 00:35:29	1.25
+++ LVM2/lib/metadata/segtype.h	2009/10/16 17:41:52	1.26
@@ -35,6 +35,7 @@
 #define SEG_VIRTUAL		0x00000020U
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
 #define SEG_MONITORED		0x00000080U
+#define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -43,6 +44,7 @@
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
+#define seg_unknown(seg)	((seg)->segtype->flags & SEG_UNKNOWN ? 1 : 0)
 
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -105,6 +107,7 @@
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);
 struct segment_type *init_free_segtype(struct cmd_context *cmd);
+struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name);
 
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
/cvs/lvm2/LVM2/lib/unknown/unknown.c,v  -->  standard output
revision 1.1
--- LVM2/lib/unknown/unknown.c
+++ -	2009-10-16 17:41:57.687400000 +0000
@@ -0,0 +1,107 @@
+/*
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "toolcontext.h"
+#include "segtype.h"
+#include "display.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "str_list.h"
+#include "targets.h"
+#include "lvm-string.h"
+#include "activate.h"
+#include "str_list.h"
+#include "metadata.h"
+
+static const char *_unknown_name(const struct lv_segment *seg)
+{
+
+	return seg->segtype->name;
+}
+
+static int _unknown_text_import(struct lv_segment *seg, const struct config_node *sn,
+				struct dm_hash_table *pv_hash)
+{
+	struct config_node *new, *last = NULL, *current, *head = NULL;
+	log_verbose("importing unknown segment");
+	for (current = sn; current != NULL; current = current->sib) {
+		if (!strcmp(current->key, "type") || !strcmp(current->key, "start_extent") ||
+		    !strcmp(current->key, "tags") || !strcmp(current->key, "extent_count"))
+			continue;
+		new = clone_config_node(seg->lv->vg->vgmem, current, 0);
+		if (!new)
+			return_0;
+		if (last)
+			last->sib = new;
+		if (!head)
+			head = new;
+		last = new;
+	}
+	seg->segtype_private = head;
+	return 1;
+}
+
+static int _unknown_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	struct config_node *cn = seg->segtype_private;
+	return out_config_node(f, cn);
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _unknown_add_target_line(struct dev_manager *dm __attribute((unused)),
+				struct dm_pool *mem __attribute((unused)),
+				struct cmd_context *cmd __attribute((unused)),
+				void **target_state __attribute((unused)),
+				struct lv_segment *seg __attribute((unused)),
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count __attribute((unused)))
+{
+	return dm_tree_node_add_error_target(node, len);
+}
+#endif
+
+static void _unknown_destroy(const struct segment_type *segtype)
+{
+	dm_free((void *)segtype);
+}
+
+static struct segtype_handler _unknown_ops = {
+	.name = _unknown_name,
+	.text_import = _unknown_text_import,
+	.text_export = _unknown_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _unknown_add_target_line,
+#endif
+	.destroy = _unknown_destroy,
+};
+
+struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *name)
+{
+	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+	segtype->ops = &_unknown_ops;
+	segtype->name = dm_pool_strdup(cmd->mem, name);
+	segtype->private = NULL;
+	segtype->flags = SEG_UNKNOWN | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
+
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
+}
/cvs/lvm2/LVM2/test/t-unknown-segment.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-unknown-segment.sh
+++ -	2009-10-16 17:41:57.784831000 +0000
@@ -0,0 +1,34 @@
+#!/bin/sh
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+aux prepare_vg 4
+
+lvcreate -l 1 -n $lv1 $vg
+lvcreate -l 2 -m 1 -n $lv2 $vg
+
+vgcfgbackup -f bak0 $vg
+sed -e 's,striped,unstriped,;s,mirror,unmirror,' -i.orig bak0
+vgcfgrestore -f bak0 $vg
+
+# we have on-disk metadata with unknown segments now
+not lvchange -a y $vg/$lv1 # check that activation is refused
+
+vgcfgbackup -f bak1 $vg
+cat bak1
+sed -e 's,unstriped,striped,;s,unmirror,mirror,' -i.orig bak1
+vgcfgrestore -f bak1 $vg
+vgcfgbackup -f bak2 $vg
+
+egrep -v 'description|seqno|creation_time|Generated' < bak0.orig > a
+egrep -v 'description|seqno|creation_time|Generated' < bak2 > b
+diff -u a b
--- LVM2/tools/vgcfgrestore.c	2009/09/14 22:47:50	1.23
+++ LVM2/tools/vgcfgrestore.c	2009/10/16 17:41:53	1.24
@@ -56,6 +56,8 @@
 		return ECMD_FAILED;
 	}
 
+	cmd->handles_unknown_segments = 1;
+
 	if (!(arg_count(cmd, file_ARG) ?
 	      backup_restore_from_file(cmd, vg_name,
 				       arg_str_value(cmd, file_ARG, "")) :


