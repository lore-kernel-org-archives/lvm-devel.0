From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 07:45:52 +0000 (UTC)
Subject: master - refactor: rename alloc_printed_tags fn to _alloc_printed_str_list and use it for string lists in general
Message-ID: <20150629074552.9E1A860300@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e29d4773f4de731d8483a12684d5f4b96092088b
Commit:        e29d4773f4de731d8483a12684d5f4b96092088b
Parent:        77c2d11657d0b1bdb82e02cbbc6cf025d8b2f43e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 6 13:58:17 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 09:43:41 2015 +0200

refactor: rename alloc_printed_tags fn to _alloc_printed_str_list and use it for string lists in general

---
 lib/format_text/export.c        |   43 ++++++++++++++++++++++++++++++++++++++-
 lib/format_text/import-export.h |    2 -
 lib/format_text/tags.c          |   41 -------------------------------------
 3 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 018772e..a1af06b 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -372,13 +372,54 @@ static int _print_flag_config(struct formatter *f, uint64_t status, int type)
 	return 1;
 }
 
+static char *_alloc_printed_str_list(struct dm_list *list)
+{
+	struct dm_str_list *sl;
+	int first = 1;
+	size_t size = 0;
+	char *buffer, *buf;
+
+	dm_list_iterate_items(sl, list)
+		/* '"' + item + '"' + ',' + ' ' */
+		size += strlen(sl->str) + 4;
+	/* '[' + ']' + '\0' */
+	size += 3;
+
+	if (!(buffer = buf = dm_malloc(size))) {
+		log_error("Could not allocate memory for string list buffer.");
+		return NULL;
+	}
+
+	if (!emit_to_buffer(&buf, &size, "["))
+		goto_bad;
+
+	dm_list_iterate_items(sl, list) {
+		if (!first) {
+			if (!emit_to_buffer(&buf, &size, ", "))
+				goto_bad;
+		} else
+			first = 0;
+
+		if (!emit_to_buffer(&buf, &size, "\"%s\"", sl->str))
+			goto_bad;
+	}
+
+	if (!emit_to_buffer(&buf, &size, "]"))
+		goto_bad;
+
+	return buffer;
+
+bad:
+	dm_free(buffer);
+	return_NULL;
+}
 
 static int _out_tags(struct formatter *f, struct dm_list *tagsl)
 {
 	char *tag_buffer;
 
 	if (!dm_list_empty(tagsl)) {
-		if (!(tag_buffer = alloc_printed_tags(tagsl)))
+		if (!(tag_buffer = _alloc_printed_str_list(tagsl)))
 			return_0;
 		if (!out_text(f, "tags = %s", tag_buffer)) {
 			dm_free(tag_buffer);
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 18561d3..be88994 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -61,8 +61,6 @@ struct text_vg_version_ops *text_vg_vsn1_init(void);
 int print_flags(uint64_t status, int type, char *buffer, size_t size);
 int read_flags(uint64_t *status, int type, const struct dm_config_value *cv);
 
-char *alloc_printed_tags(struct dm_list *tags);
-
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
 struct volume_group *text_vg_import_file(struct format_instance *fid,
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index c081167..e22ca28 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -19,44 +19,3 @@
 #include "str_list.h"
 #include "lvm-string.h"
 
-char *alloc_printed_tags(struct dm_list *tagsl)
-{
-	struct dm_str_list *sl;
-	int first = 1;
-	size_t size = 0;
-	char *buffer, *buf;
-
-	dm_list_iterate_items(sl, tagsl)
-		/* '"' + tag + '"' + ',' + ' ' */
-		size += strlen(sl->str) + 4;
-	/* '[' + ']' + '\0' */
-	size += 3;
-
-	if (!(buffer = buf = dm_malloc(size))) {
-		log_error("Could not allocate memory for tag list buffer.");
-		return NULL;
-	}
-
-	if (!emit_to_buffer(&buf, &size, "["))
-		goto_bad;
-
-	dm_list_iterate_items(sl, tagsl) {
-		if (!first) {
-			if (!emit_to_buffer(&buf, &size, ", "))
-				goto_bad;
-		} else
-			first = 0;
-
-		if (!emit_to_buffer(&buf, &size, "\"%s\"", sl->str))
-			goto_bad;
-	}
-
-	if (!emit_to_buffer(&buf, &size, "]"))
-		goto_bad;
-
-	return buffer;
-
-bad:
-	dm_free(buffer);
-	return_NULL;
-}


