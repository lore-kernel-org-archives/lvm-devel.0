From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 08:55:44 -0400
Subject: master - flags: add segtype flag support
Message-ID: <201705291255.v4TCtij1002384@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4141409eb09e78aef030346995f1722fb40956d8
Commit:        4141409eb09e78aef030346995f1722fb40956d8
Parent:        0299a7af1ec1eeb11388ed15c4c78f224fee76b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 29 14:20:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 14:52:56 2017 +0200

flags: add segtype flag support

Switch METADATA_FORMAT flag usage to be stored via segtype
instead of 'status' flag which appeared to cause major
incompatibility troubles.

For backward compatiblity segtype flags are still accepted also
via 'status' bits which were used from version 2.02.169 so metadata
saved by this newer lvm2 version should still work nicely, although
new save version will no longer work on this older lvm2 version.
---
 WHATS_NEW                       |    1 +
 lib/format_text/export.c        |    8 +++++++-
 lib/format_text/flags.c         |    4 ++--
 lib/format_text/import-export.h |    1 +
 lib/format_text/import_vsn1.c   |   21 +++++++++++++++++++--
 5 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index de65e0e..878aa7a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Cache format2 flag is now using segment name type field.
   Support storing status flags via segtype name field.
   Stop using '--yes' mode when fsadm runs without terminal.
   Extend validation of filesystems resized by fsadm.
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 829b46d..f369089 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -584,6 +584,11 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 static int _print_segment(struct formatter *f, struct volume_group *vg,
 			  int count, struct lv_segment *seg)
 {
+	char buffer[2048];
+
+	if (!print_segtype_lvflags(buffer, sizeof(buffer), seg->lv->status))
+		return_0;
+
 	outf(f, "segment%u {", count);
 	_inc_indent(f);
 
@@ -594,7 +599,8 @@ static int _print_segment(struct formatter *f, struct volume_group *vg,
 	if (seg->reshape_len)
 		outsize(f, (uint64_t) seg->reshape_len * vg->extent_size,
 			"reshape_count = %u", seg->reshape_len);
-	outf(f, "type = \"%s\"", seg->segtype->name);
+
+	outf(f, "type = \"%s%s\"", seg->segtype->name, buffer);
 
 	if (!_out_list(f, &seg->tags, "tags"))
 		return_0;
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 64bad1c..04896f4 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -67,7 +67,7 @@ static const struct flag _lv_flags[] = {
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
-	{LV_METADATA_FORMAT, "METADATA_FORMAT", STATUS_FLAG},
+	{LV_METADATA_FORMAT, "METADATA_FORMAT", SEGTYPE_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
@@ -138,7 +138,7 @@ int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint6
 		if (status & flags[f].mask) {
 			status &= ~flags[f].mask;
 
-			if ((type & STATUS_FLAG) != flags[f].kind)
+			if (mask != flags[f].kind)
 				continue;
 
 			/* Internal-only flag? */
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index abb9b0e..4b47636 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -43,6 +43,7 @@ enum pv_vg_lv_e {
 
 #define COMPATIBLE_FLAG	0x01
 #define STATUS_FLAG	0x02
+#define SEGTYPE_FLAG	0x04
 
 struct text_vg_version_ops {
 	int (*check_version) (const struct dm_config_tree * cf);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 6acfe1d..7d9257e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -140,7 +140,8 @@ static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, i
 		return 0;
 	}
 
-	if (!(read_flags(status, type, STATUS_FLAG, cv))) {
+	/* For backward compatible metadata accept both type of flags */
+	if (!(read_flags(status, type, STATUS_FLAG | SEGTYPE_FLAG, cv))) {
 		log_error("Could not read status flags.");
 		return 0;
 	}
@@ -357,6 +358,7 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 	uint32_t area_extents, start_extent, extent_count, reshape_count, data_copies;
 	struct segment_type *segtype;
 	const char *segtype_str;
+	char *segtype_with_flags;
 
 	if (!sn_child) {
 		log_error("Empty segment section.");
@@ -388,9 +390,24 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 		return 0;
 	}
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, segtype_str)))
+        /* Locally duplicate to parse out status flag bits */
+	if (!(segtype_with_flags = dm_pool_strdup(mem, segtype_str))) {
+		log_error("Cannot duplicate segtype string.");
+		return 0;
+	}
+
+	if (!read_segtype_lvflags(&lv->status, segtype_with_flags)) {
+		log_error("Couldn't read segtype for logical volume %s.",
+			  display_lvname(lv));
+	       return 0;
+	}
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, segtype_with_flags)))
 		return_0;
 
+	/* Can drop temporary string here as nothing has allocated from VGMEM meanwhile */
+	dm_pool_free(mem, segtype_with_flags);
+
 	if (segtype->ops->text_import_area_count &&
 	    !segtype->ops->text_import_area_count(sn_child, &area_count))
 		return_0;


