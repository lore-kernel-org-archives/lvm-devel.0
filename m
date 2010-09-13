From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 13 Sep 2010 16:30:48 +0200
Subject: [PATCH] Use dynamic allocation for tag buffer when writing metadata out
Message-ID: <4C8E3598.4040801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Statically allocated buffer of 4096 is not enough is some situations for tag
buffer (see also rhbz #633033). So let's use dynamic allocation instead to make
enough room for it.

Peter
---
 lib/format_text/export.c        |   26 ++++++++++++++++----------
 lib/format_text/import-export.h |    2 +-
 lib/format_text/tags.c          |   35 ++++++++++++++++++++++++++---------
 3 files changed, 43 insertions(+), 20 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index bb558fc..95b2f02 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -366,6 +366,7 @@ static int _print_flag_config(struct formatter *f, uint64_t status, int type)
 static int _print_vg(struct formatter *f, struct volume_group *vg)
 {
 	char buffer[4096];
+	char *tag_buffer = NULL;
 
 	if (!id_write_format(&vg->id, buffer, sizeof(buffer)))
 		return_0;
@@ -378,9 +379,10 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 		return_0;
 
 	if (!dm_list_empty(&vg->tags)) {
-		if (!print_tags(&vg->tags, buffer, sizeof(buffer)))
+		if (!print_tags(&vg->tags, &tag_buffer))
 			return_0;
-		outf(f, "tags = %s", buffer);
+		outf(f, "tags = %s", tag_buffer);
+		dm_free(tag_buffer);
 	}
 
 	if (vg->system_id && *vg->system_id)
@@ -426,7 +428,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 	char buffer[4096];
-	char *buf;
+	char *buf, *tag_buffer = NULL;
 	const char *name;
 
 	outf(f, "physical_volumes {");
@@ -461,9 +463,10 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 			return_0;
 
 		if (!dm_list_empty(&pv->tags)) {
-			if (!print_tags(&pv->tags, buffer, sizeof(buffer)))
+			if (!print_tags(&pv->tags, &tag_buffer))
 				return_0;
-			outf(f, "tags = %s", buffer);
+			outf(f, "tags = %s", tag_buffer);
+			dm_free(tag_buffer);
 		}
 
 		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
@@ -484,7 +487,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 static int _print_segment(struct formatter *f, struct volume_group *vg,
 			  int count, struct lv_segment *seg)
 {
-	char buffer[4096];
+	char *tag_buffer = NULL;
 
 	outf(f, "segment%u {", count);
 	_inc_indent(f);
@@ -497,9 +500,10 @@ static int _print_segment(struct formatter *f, struct volume_group *vg,
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
 	if (!dm_list_empty(&seg->tags)) {
-		if (!print_tags(&seg->tags, buffer, sizeof(buffer)))
+		if (!print_tags(&seg->tags, &tag_buffer))
 			return_0;
-		outf(f, "tags = %s", buffer);
+		outf(f, "tags = %s", tag_buffer);
+		dm_free(tag_buffer);
 	}
 
 	if (seg->segtype->ops->text_export &&
@@ -553,6 +557,7 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 	char buffer[4096];
+	char *tag_buffer = NULL;
 	int seg_count;
 
 	outnl(f);
@@ -569,9 +574,10 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 		return_0;
 
 	if (!dm_list_empty(&lv->tags)) {
-		if (!print_tags(&lv->tags, buffer, sizeof(buffer)))
+		if (!print_tags(&lv->tags, &tag_buffer))
 			return_0;
-		outf(f, "tags = %s", buffer);
+		outf(f, "tags = %s", tag_buffer);
+		dm_free(tag_buffer);
 	}
 
 	if (lv->alloc != ALLOC_INHERIT)
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 019c739..2a64734 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -61,7 +61,7 @@ struct text_vg_version_ops *text_vg_vsn1_init(void);
 int print_flags(uint64_t status, int type, char *buffer, size_t size);
 int read_flags(uint64_t *status, int type, struct config_value *cv);
 
-int print_tags(struct dm_list *tags, char *buffer, size_t size);
+int print_tags(struct dm_list *tags, char **buffer);
 int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index eeb0af7..9c5bc3f 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -19,29 +19,46 @@
 #include "str_list.h"
 #include "lvm-string.h"
 
-int print_tags(struct dm_list *tags, char *buffer, size_t size)
+int print_tags(struct dm_list *tags, char **buffer)
 {
 	struct str_list *sl;
 	int first = 1;
+	size_t size = 0;
+	char *buf;
 
-	if (!emit_to_buffer(&buffer, &size, "["))
-		return_0;
+	dm_list_iterate_items(sl, tags)
+		/* '"' + tag + '"' + ',' + ' ' */
+		size += strlen(sl->str) + 4;
+	/* '[' + ']' + '\0' */
+	size += 3;
+
+	if (!(*buffer = buf = dm_malloc(size))) {
+		log_error("Could not allocate memory for tag list buffer.");
+		return 0;
+	}
+
+	if (!emit_to_buffer(&buf, &size, "["))
+		goto error;
 
 	dm_list_iterate_items(sl, tags) {
 		if (!first) {
-			if (!emit_to_buffer(&buffer, &size, ", "))
-				return_0;
+			if (!emit_to_buffer(&buf, &size, ", "))
+				goto error;
 		} else
 			first = 0;
 
-		if (!emit_to_buffer(&buffer, &size, "\"%s\"", sl->str))
-			return_0;
+		if (!emit_to_buffer(&buf, &size, "\"%s\"", sl->str))
+			goto error;
 	}
 
-	if (!emit_to_buffer(&buffer, &size, "]"))
-		return_0;
+	if (!emit_to_buffer(&buf, &size, "]"))
+		goto error;
 
 	return 1;
+
+error:
+	dm_free(*buffer);
+	return_0;
 }
 
 int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv)


