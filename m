From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 12:19:59 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c
Message-ID: <20101129121959.28053.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 12:19:58

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c 

Log message:
	Fix memory leak in error path
	
	Nicely hidden memory leak in outf macro error path.
	This macro is using out_text() and does automagical return_0.
	That would leak tag_buffer allocated memory.
	
	As there was same code for tags output - create _out_tags() function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1812&r2=1.1813
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/WHATS_NEW	2010/11/29 11:08:14	1.1812
+++ LVM2/WHATS_NEW	2010/11/29 12:19:58	1.1813
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix memory leak in outf macro error path of _print_vg/lv/pvs/segment().
   Fix missing reset of vg pointer after vg_release() in _vg_read_by_vgid().
   Fix test for empty system_dir string in _init_backup().
   Certain lvconvert invocations are now required to be done in two steps.
--- LVM2/lib/format_text/export.c	2010/09/30 21:06:51	1.79
+++ LVM2/lib/format_text/export.c	2010/11/29 12:19:58	1.80
@@ -363,10 +363,27 @@
 	return 1;
 }
 
+
+static int _out_tags(struct formatter *f, struct dm_list *tags)
+{
+	char *tag_buffer;
+
+	if (!dm_list_empty(tags)) {
+		if (!(tag_buffer = alloc_printed_tags(tags)))
+			return_0;
+		if (!out_text(f, "tags = %s", tag_buffer)) {
+			dm_free(tag_buffer);
+			return_0;
+		}
+		dm_free(tag_buffer);
+	}
+
+	return 1;
+}
+
 static int _print_vg(struct formatter *f, struct volume_group *vg)
 {
 	char buffer[4096];
-	char *tag_buffer = NULL;
 
 	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
 		return_0;
@@ -378,12 +395,8 @@
 	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
 
-	if (!dm_list_empty(&vg->tags)) {
-		if (!(tag_buffer = alloc_printed_tags(&vg->tags)))
-			return_0;
-		outf(f, "tags = %s", tag_buffer);
-		dm_free(tag_buffer);
-	}
+	if (!_out_tags(f, &vg->tags))
+		return_0;
 
 	if (vg->system_id && *vg->system_id)
 		outf(f, "system_id = \"%s\"", vg->system_id);
@@ -428,7 +441,7 @@
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	char buffer[4096];
-	char *buf, *tag_buffer = NULL;
+	char *buf;
 	const char *name;
 
 	outf(f, "physical_volumes {");
@@ -462,12 +475,8 @@
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
 			return_0;
 
-		if (!dm_list_empty(&pv->tags)) {
-			if (!(tag_buffer = alloc_printed_tags(&pv->tags)))
-				return_0;
-			outf(f, "tags = %s", tag_buffer);
-			dm_free(tag_buffer);
-		}
+		if (!_out_tags(f, &pv->tags))
+			return_0;
 
 		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
 
@@ -487,8 +496,6 @@
 static int _print_segment(struct formatter *f, struct volume_group *vg,
 			  int count, struct lv_segment *seg)
 {
-	char *tag_buffer = NULL;
-
 	outf(f, "segment%u {", count);
 	_inc_indent(f);
 
@@ -499,12 +506,8 @@
 	outnl(f);
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
-	if (!dm_list_empty(&seg->tags)) {
-		if (!(tag_buffer = alloc_printed_tags(&seg->tags)))
-			return_0;
-		outf(f, "tags = %s", tag_buffer);
-		dm_free(tag_buffer);
-	}
+	if (!_out_tags(f, &seg->tags))
+		return_0;
 
 	if (seg->segtype->ops->text_export &&
 	    !seg->segtype->ops->text_export(seg, f))
@@ -557,7 +560,6 @@
 {
 	struct lv_segment *seg;
 	char buffer[4096];
-	char *tag_buffer = NULL;
 	int seg_count;
 
 	outnl(f);
@@ -573,12 +575,8 @@
 	if (!_print_flag_config(f, lv->status, LV_FLAGS))
 		return_0;
 
-	if (!dm_list_empty(&lv->tags)) {
-		if (!(tag_buffer = alloc_printed_tags(&lv->tags)))
-			return_0;
-		outf(f, "tags = %s", tag_buffer);
-		dm_free(tag_buffer);
-	}
+	if (!_out_tags(f, &lv->tags))
+		return_0;
 
 	if (lv->alloc != ALLOC_INHERIT)
 		outf(f, "allocation_policy = \"%s\"",


