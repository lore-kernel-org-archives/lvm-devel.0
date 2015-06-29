From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 07:45:50 +0000 (UTC)
Subject: master - refactor: rename read_tags fn to _read_str_list and use it for string lists in general
Message-ID: <20150629074550.772B961103@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77c2d11657d0b1bdb82e02cbbc6cf025d8b2f43e
Commit:        77c2d11657d0b1bdb82e02cbbc6cf025d8b2f43e
Parent:        02767c5eb1f9e4a15c5f5134903c292ea499213d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 6 13:19:21 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 09:43:32 2015 +0200

refactor: rename read_tags fn to _read_str_list and use it for string lists in general

---
 lib/format_text/import-export.h |    1 -
 lib/format_text/import_vsn1.c   |   29 +++++++++++++++++++++++++----
 lib/format_text/tags.c          |   20 --------------------
 3 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index f60496f..18561d3 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -62,7 +62,6 @@ int print_flags(uint64_t status, int type, char *buffer, size_t size);
 int read_flags(uint64_t *status, int type, const struct dm_config_value *cv);
 
 char *alloc_printed_tags(struct dm_list *tags);
-int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct dm_config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 048c8fe..931aff8 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -25,6 +25,7 @@
 #include "segtype.h"
 #include "text_import.h"
 #include "defaults.h"
+#include "str_list.h"
 
 typedef int (*section_fn) (struct format_instance * fid,
 			   struct volume_group * vg, const struct dm_config_node * pvn,
@@ -153,6 +154,26 @@ static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, i
 	return 1;
 }
 
+static int _read_str_list(struct dm_pool *mem, struct dm_list *list, const struct dm_config_value *cv)
+{
+	if (cv->type == DM_CFG_EMPTY_ARRAY)
+		return 1;
+
+	while (cv) {
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Found an item that is not a string");
+			return 0;
+		}
+
+		if (!str_list_add(mem, list, dm_pool_strdup(mem, cv->v.str)))
+			return_0;
+
+		cv = cv->next;
+	}
+
+	return 1;
+}
+
 static int _read_pv(struct format_instance *fid,
 		    struct volume_group *vg, const struct dm_config_node *pvn,
 		    const struct dm_config_node *vgn __attribute__((unused)),
@@ -269,7 +290,7 @@ static int _read_pv(struct format_instance *fid,
 
 	/* Optional tags */
 	if (dm_config_get_list(pvn, "tags", &cv) &&
-	    !(read_tags(mem, &pv->tags, cv))) {
+	    !(_read_str_list(mem, &pv->tags, cv))) {
 		log_error("Couldn't read tags for physical volume %s in %s.",
 			  pv_dev_name(pv), vg->name);
 		return 0;
@@ -380,7 +401,7 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 
 	/* Optional tags */
 	if (dm_config_get_list(sn_child, "tags", &cv) &&
-	    !(read_tags(mem, &seg->tags, cv))) {
+	    !(_read_str_list(mem, &seg->tags, cv))) {
 		log_error("Couldn't read tags for a segment of %s/%s.",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -616,7 +637,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 
 	/* Optional tags */
 	if (dm_config_get_list(lvn, "tags", &cv) &&
-	    !(read_tags(mem, &lv->tags, cv))) {
+	    !(_read_str_list(mem, &lv->tags, cv))) {
 		log_error("Couldn't read tags for logical volume %s/%s.",
 			  vg->name, lv->name);
 		return 0;
@@ -891,7 +912,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	/* Optional tags */
 	if (dm_config_get_list(vgn, "tags", &cv) &&
-	    !(read_tags(vg->vgmem, &vg->tags, cv))) {
+	    !(_read_str_list(vg->vgmem, &vg->tags, cv))) {
 		log_error("Couldn't read tags for volume group %s.", vg->name);
 		goto bad;
 	}
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index dc138d1..c081167 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -60,23 +60,3 @@ bad:
 	dm_free(buffer);
 	return_NULL;
 }
-
-int read_tags(struct dm_pool *mem, struct dm_list *tagsl, const struct dm_config_value *cv)
-{
-	if (cv->type == DM_CFG_EMPTY_ARRAY)
-		return 1;
-
-	while (cv) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Found a tag that is not a string");
-			return 0;
-		}
-
-		if (!str_list_add(mem, tagsl, dm_pool_strdup(mem, cv->v.str)))
-			return_0;
-
-		cv = cv->next;
-	}
-
-	return 1;
-}


