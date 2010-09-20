From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 20 Sep 2010 14:23:42 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c lib/ ...
Message-ID: <20100920142342.16058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-09-20 14:23:20

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c import-export.h tags.c 

Log message:
	Use dynamic allocation for metadata's tag buffer (removes 4096 char. limit).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1729&r2=1.1730
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2010/09/09 13:13:12	1.1729
+++ LVM2/WHATS_NEW	2010/09/20 14:23:20	1.1730
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Use dynamic allocation for metadata's tag buffer (removes 4096 char. limit).
   Add random suffix to archive file names to prevent races when being created.
   Reinitialize archive and backup handling on toolcontext refresh.
   Fix opprobriously slow I/O to cluster mirrors created with --nosync.
--- LVM2/lib/format_text/export.c	2010/07/09 15:34:44	1.77
+++ LVM2/lib/format_text/export.c	2010/09/20 14:23:20	1.78
@@ -366,6 +366,7 @@
 static int _print_vg(struct formatter *f, struct volume_group *vg)
 {
 	char buffer[4096];
+	char *tag_buffer = NULL;
 
 	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
 		return_0;
@@ -378,9 +379,10 @@
 		return_0;
 
 	if (!dm_list_empty(&vg->tags)) {
-		if (!print_tags(&vg->tags, buffer, sizeof(buffer)))
+		if (!(tag_buffer = alloc_printed_tags(&vg->tags)))
 			return_0;
-		outf(f, "tags = %s", buffer);
+		outf(f, "tags = %s", tag_buffer);
+		dm_free(tag_buffer);
 	}
 
 	if (vg->system_id && *vg->system_id)
@@ -426,7 +428,7 @@
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	char buffer[4096];
-	char *buf;
+	char *buf, *tag_buffer = NULL;
 	const char *name;
 
 	outf(f, "physical_volumes {");
@@ -461,9 +463,10 @@
 			return_0;
 
 		if (!dm_list_empty(&pv->tags)) {
-			if (!print_tags(&pv->tags, buffer, sizeof(buffer)))
+			if (!(tag_buffer = alloc_printed_tags(&pv->tags)))
 				return_0;
-			outf(f, "tags = %s", buffer);
+			outf(f, "tags = %s", tag_buffer);
+			dm_free(tag_buffer);
 		}
 
 		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
@@ -484,7 +487,7 @@
 static int _print_segment(struct formatter *f, struct volume_group *vg,
 			  int count, struct lv_segment *seg)
 {
-	char buffer[4096];
+	char *tag_buffer = NULL;
 
 	outf(f, "segment%u {", count);
 	_inc_indent(f);
@@ -497,9 +500,10 @@
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
 	if (!dm_list_empty(&seg->tags)) {
-		if (!print_tags(&seg->tags, buffer, sizeof(buffer)))
+		if (!(tag_buffer = alloc_printed_tags(&seg->tags)))
 			return_0;
-		outf(f, "tags = %s", buffer);
+		outf(f, "tags = %s", tag_buffer);
+		dm_free(tag_buffer);
 	}
 
 	if (seg->segtype->ops->text_export &&
@@ -553,6 +557,7 @@
 {
 	struct lv_segment *seg;
 	char buffer[4096];
+	char *tag_buffer = NULL;
 	int seg_count;
 
 	outnl(f);
@@ -569,9 +574,10 @@
 		return_0;
 
 	if (!dm_list_empty(&lv->tags)) {
-		if (!print_tags(&lv->tags, buffer, sizeof(buffer)))
+		if (!(tag_buffer = alloc_printed_tags(&lv->tags)))
 			return_0;
-		outf(f, "tags = %s", buffer);
+		outf(f, "tags = %s", tag_buffer);
+		dm_free(tag_buffer);
 	}
 
 	if (lv->alloc != ALLOC_INHERIT)
--- LVM2/lib/format_text/import-export.h	2010/03/17 02:11:19	1.24
+++ LVM2/lib/format_text/import-export.h	2010/09/20 14:23:20	1.25
@@ -61,7 +61,7 @@
 int print_flags(uint64_t status, int type, char *buffer, size_t size);
 int read_flags(uint64_t *status, int type, struct config_value *cv);
 
-int print_tags(struct dm_list *tags, char *buffer, size_t size);
+char *alloc_printed_tags(struct dm_list *tags);
 int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
--- LVM2/lib/format_text/tags.c	2008/11/03 22:14:28	1.7
+++ LVM2/lib/format_text/tags.c	2010/09/20 14:23:20	1.8
@@ -19,29 +19,46 @@
 #include "str_list.h"
 #include "lvm-string.h"
 
-int print_tags(struct dm_list *tags, char *buffer, size_t size)
+char *alloc_printed_tags(struct dm_list *tags)
 {
 	struct str_list *sl;
 	int first = 1;
+	size_t size = 0;
+	char *buffer, *buf;
 
-	if (!emit_to_buffer(&buffer, &size, "["))
-		return_0;
+	dm_list_iterate_items(sl, tags)
+		/* '"' + tag + '"' + ',' + ' ' */
+		size += strlen(sl->str) + 4;
+	/* '[' + ']' + '\0' */
+	size += 3;
+
+	if (!(buffer = buf = dm_malloc(size))) {
+		log_error("Could not allocate memory for tag list buffer.");
+		return NULL;
+	}
+
+	if (!emit_to_buffer(&buf, &size, "["))
+		goto bad;
 
 	dm_list_iterate_items(sl, tags) {
 		if (!first) {
-			if (!emit_to_buffer(&buffer, &size, ", "))
-				return_0;
+			if (!emit_to_buffer(&buf, &size, ", "))
+				goto bad;
 		} else
 			first = 0;
 
-		if (!emit_to_buffer(&buffer, &size, "\"%s\"", sl->str))
-			return_0;
+		if (!emit_to_buffer(&buf, &size, "\"%s\"", sl->str))
+			goto bad;
 	}
 
-	if (!emit_to_buffer(&buffer, &size, "]"))
-		return_0;
+	if (!emit_to_buffer(&buf, &size, "]"))
+		goto bad;
 
-	return 1;
+	return buffer;
+
+bad:
+	dm_free(buffer);
+	return_NULL;
 }
 
 int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv)


