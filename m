From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 11 Apr 2016 21:13:36 +0000 (UTC)
Subject: master - rename function read_vgname to read_vgsummary
Message-ID: <20160411211336.3375D61BC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=147c9c01a21687b82314a62571cfc390a9a606a8
Commit:        147c9c01a21687b82314a62571cfc390a9a606a8
Parent:        fe65a86cbc98bb38014b238266a7732de42d0aa1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 9 13:32:26 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 11 13:07:48 2016 -0500

rename function read_vgname to read_vgsummary

The name did not clearly represent what it does.
---
 lib/format_text/format-text.c   |    2 +-
 lib/format_text/import-export.h |    8 ++++----
 lib/format_text/import.c        |    4 ++--
 lib/format_text/import_vsn1.c   |   12 ++++++++----
 4 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 408e63c..6053610 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1210,7 +1210,7 @@ int vgname_from_mda(const struct format_type *fmt,
 		used_cached_metadata = 1;
 
 	/* FIXME 64-bit */
-	if (!text_vgname_import(fmt, dev_area->dev,
+	if (!text_vgsummary_import(fmt, dev_area->dev,
 				(off_t) (dev_area->start + rlocn->offset),
 				(uint32_t) (rlocn->size - wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 074b118..c081c51 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -51,9 +51,9 @@ struct text_vg_version_ops {
 					 unsigned allow_lvmetad_extensions);
 	void (*read_desc) (struct dm_pool * mem, const struct dm_config_tree *cf,
 			   time_t *when, char **desc);
-	int (*read_vgname) (const struct format_type *fmt,
-			    const struct dm_config_tree *cft,
-			    struct lvmcache_vgsummary *vgsummary);
+	int (*read_vgsummary) (const struct format_type *fmt,
+			       const struct dm_config_tree *cft,
+			       struct lvmcache_vgsummary *vgsummary);
 };
 
 struct text_vg_version_ops *text_vg_vsn1_init(void);
@@ -78,7 +78,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       uint32_t checksum,
 				       time_t *when, char **desc);
 
-int text_vgname_import(const struct format_type *fmt,
+int text_vgsummary_import(const struct format_type *fmt,
 		       struct device *dev,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 5b4f4a9..629884b 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -35,7 +35,7 @@ static void _init_text_import(void)
 /*
  * Find out vgname on a given device.
  */
-int text_vgname_import(const struct format_type *fmt,
+int text_vgsummary_import(const struct format_type *fmt,
 		       struct device *dev,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
@@ -74,7 +74,7 @@ int text_vgname_import(const struct format_type *fmt,
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(*vsn)->read_vgname(fmt, cft, vgsummary))
+		if (!(*vsn)->read_vgsummary(fmt, cft, vgsummary))
 			goto_out;
 
 		r = 1;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 3bf5f7b..22f519e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1229,12 +1229,16 @@ static void _read_desc(struct dm_pool *mem,
 }
 
 /*
- * It would be more accurate to call this _read_vgsummary().
  * It is used to read vgsummary information about a VG
  * before locking and reading the VG via vg_read().
+ * read_vgsummary: read VG metadata before VG is locked
+ *                 and save the data in struct vgsummary
+ * read_vg: read VG metadata after VG is locked
+ *          and save the data in struct volume_group
+ * FIXME: why are these separate?
  */
-static int _read_vgname(const struct format_type *fmt, const struct dm_config_tree *cft, 
-			struct lvmcache_vgsummary *vgsummary)
+static int _read_vgsummary(const struct format_type *fmt, const struct dm_config_tree *cft, 
+			   struct lvmcache_vgsummary *vgsummary)
 {
 	const struct dm_config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
@@ -1285,7 +1289,7 @@ static struct text_vg_version_ops _vsn1_ops = {
 	.check_version = _vsn1_check_version,
 	.read_vg = _read_vg,
 	.read_desc = _read_desc,
-	.read_vgname = _read_vgname,
+	.read_vgsummary = _read_vgsummary
 };
 
 struct text_vg_version_ops *text_vg_vsn1_init(void)


