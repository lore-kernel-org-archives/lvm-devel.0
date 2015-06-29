From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 07:45:56 +0000 (UTC)
Subject: master - refactor: rename _out_tags fn to _out_list and use it for string lists in general
Message-ID: <20150629074556.CD5CD60300@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b45a1fc60859faa4163bde8332ac7c173802640
Commit:        7b45a1fc60859faa4163bde8332ac7c173802640
Parent:        f143ad3a9340eb3c90fa37cf912ce163ad107e1a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 6 14:06:44 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 09:43:55 2015 +0200

refactor: rename _out_tags fn to _out_list and use it for string lists in general

---
 lib/format_text/export.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index a1af06b..11766ac 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -414,18 +414,19 @@ bad:
 	return_NULL;
 }
 
-static int _out_tags(struct formatter *f, struct dm_list *tagsl)
+static int _out_list(struct formatter *f, struct dm_list *list,
+		     const char *list_name)
 {
-	char *tag_buffer;
+	char *buffer;
 
-	if (!dm_list_empty(tagsl)) {
-		if (!(tag_buffer = _alloc_printed_str_list(tagsl)))
+	if (!dm_list_empty(list)) {
+		if (!(buffer = _alloc_printed_str_list(list)))
 			return_0;
-		if (!out_text(f, "tags = %s", tag_buffer)) {
-			dm_free(tag_buffer);
+		if (!out_text(f, "%s = %s", list_name, buffer)) {
+			dm_free(buffer);
 			return_0;
 		}
-		dm_free(tag_buffer);
+		dm_free(buffer);
 	}
 
 	return 1;
@@ -463,7 +464,7 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	if (!_print_flag_config(f, status, VG_FLAGS))
 		return_0;
 
-	if (!_out_tags(f, &vg->tags))
+	if (!_out_list(f, &vg->tags, "tags"))
 		return_0;
  
 	if (vg->system_id && *vg->system_id)
@@ -550,7 +551,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
 			return_0;
 
-		if (!_out_tags(f, &pv->tags))
+		if (!_out_list(f, &pv->tags, "tags"))
 			return_0;
 
 		outsize(f, pv->size, "dev_size = %" PRIu64, pv->size);
@@ -586,7 +587,7 @@ static int _print_segment(struct formatter *f, struct volume_group *vg,
 	outnl(f);
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
-	if (!_out_tags(f, &seg->tags))
+	if (!_out_list(f, &seg->tags, "tags"))
 		return_0;
 
 	if (seg->segtype->ops->text_export &&
@@ -682,7 +683,7 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 	if (!_print_flag_config(f, status, LV_FLAGS))
 		return_0;
 
-	if (!_out_tags(f, &lv->tags))
+	if (!_out_list(f, &lv->tags, "tags"))
 		return_0;
 
 	if (lv->timestamp) {


