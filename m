From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:20:59 -0500
Subject: master - metadata: add vg_from_config_tree
Message-ID: <54536.119112712205500723@us-mta-88.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74ad2cd76f68596c0a718f3a9d951a4c72214691
Commit:        74ad2cd76f68596c0a718f3a9d951a4c72214691
Parent:        13c629fb7840e73a38afb9396cae93ea10955a21
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 29 14:31:37 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

metadata: add vg_from_config_tree

Add cmd/fmt args to import functions so that
they can be used without the fid arg which.
---
 lib/format_text/import-export.h |   10 +++++++---
 lib/format_text/import.c        |   28 +++++++++++++++++++++-------
 lib/format_text/import_vsn1.c   |   16 ++++++++--------
 lib/metadata/metadata.c         |    4 ++--
 lib/metadata/metadata.h         |    6 ++++--
 5 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 0bfc60b..da76852 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -47,11 +47,15 @@ enum pv_vg_lv_e {
 
 struct text_vg_version_ops {
 	int (*check_version) (const struct dm_config_tree * cf);
-	struct volume_group *(*read_vg) (struct format_instance * fid,
-					 const struct dm_config_tree *cf,
-					 unsigned allow_lvmetad_extensions);
+
+	struct volume_group *(*read_vg) (struct cmd_context *cmd,
+					 const struct format_type *fmt,
+					 struct format_instance *fid,
+					 const struct dm_config_tree *cft);
+
 	void (*read_desc) (struct dm_pool * mem, const struct dm_config_tree *cf,
 			   time_t *when, char **desc);
+
 	int (*read_vgsummary) (const struct format_type *fmt,
 			       const struct dm_config_tree *cft,
 			       struct lvmcache_vgsummary *vgsummary);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 79276dd..a4ea98b 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -15,6 +15,7 @@
 
 #include "lib/misc/lib.h"
 #include "lib/metadata/metadata.h"
+#include "lib/commands/toolcontext.h"
 #include "import-export.h"
 
 /* FIXME Use tidier inclusion method */
@@ -181,7 +182,7 @@ struct volume_group *text_read_metadata(struct format_instance *fid,
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vg = (*vsn)->read_vg(fid, cft, 0)))
+		if (!(vg = (*vsn)->read_vg(fid->fmt->cmd, fid->fmt, fid, cft)))
 			goto_out;
 
 		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
@@ -210,9 +211,9 @@ struct volume_group *text_read_metadata_file(struct format_instance *fid,
 				  when, desc);
 }
 
-static struct volume_group *_import_vg_from_config_tree(const struct dm_config_tree *cft,
+static struct volume_group *_import_vg_from_config_tree(struct cmd_context *cmd,
 							struct format_instance *fid,
-							unsigned allow_lvmetad_extensions)
+							const struct dm_config_tree *cft)
 {
 	struct volume_group *vg = NULL;
 	struct text_vg_version_ops **vsn;
@@ -227,7 +228,7 @@ static struct volume_group *_import_vg_from_config_tree(const struct dm_config_t
 		 * The only path to this point uses cached vgmetadata,
 		 * so it can use cached PV state too.
 		 */
-		if (!(vg = (*vsn)->read_vg(fid, cft, allow_lvmetad_extensions)))
+		if (!(vg = (*vsn)->read_vg(cmd, fid->fmt, fid, cft)))
 			stack;
 		else {
 			set_pv_devices(fid, vg, NULL);
@@ -243,8 +244,21 @@ static struct volume_group *_import_vg_from_config_tree(const struct dm_config_t
 	return vg;
 }
 
-struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
-						struct format_instance *fid)
+struct volume_group *import_vg_from_config_tree(struct cmd_context *cmd,
+						struct format_instance *fid,
+						const struct dm_config_tree *cft)
 {
-	return _import_vg_from_config_tree(cft, fid, 0);
+	return _import_vg_from_config_tree(cmd, fid, cft);
 }
+
+struct volume_group *vg_from_config_tree(struct cmd_context *cmd, const struct dm_config_tree *cft)
+{
+	static struct text_vg_version_ops *ops;
+
+	_init_text_import();
+
+	ops = _text_vsn_list[0];
+
+	return ops->read_vg(cmd, cmd->fmt, NULL, cft);
+}
+
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d7ff786..2bdbfee 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -993,7 +993,7 @@ static int _read_lvsegs(struct cmd_context *cmd,
 }
 
 static int _read_sections(struct cmd_context *cmd,
-			  struct format_type *fmt,
+			  const struct format_type *fmt,
 			  struct format_instance *fid,
 			  struct dm_pool *mem,
 			  const char *section, section_fn fn,
@@ -1016,19 +1016,18 @@ static int _read_sections(struct cmd_context *cmd,
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(cmd, fmt, fid, mem, vg, vgsummary, n, vgn, pv_hash, lv_hash))
+		if (!fn(cmd, (struct format_type *)fmt, fid, mem, vg, vgsummary, n, vgn, pv_hash, lv_hash))
 			return_0;
 	}
 
 	return 1;
 }
 
-static struct volume_group *_read_vg(struct format_instance *fid,
-				     const struct dm_config_tree *cft,
-				     unsigned allow_lvmetad_extensions)
+static struct volume_group *_read_vg(struct cmd_context *cmd,
+				     const struct format_type *fmt,
+				     struct format_instance *fid,
+				     const struct dm_config_tree *cft)
 {
-	struct cmd_context *cmd = fid->fmt->cmd;
-	struct format_type *fmt = (struct format_type *)fid->fmt;
 	struct dm_pool *mem;
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
@@ -1234,7 +1233,8 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	dm_hash_destroy(pv_hash);
 	dm_hash_destroy(lv_hash);
 
-	vg_set_fid(vg, fid);
+	if (fid)
+		vg_set_fid(vg, fid);
 
 	/*
 	 * Finished.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b12db60..1371b97 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -999,7 +999,7 @@ static int _vg_update_embedded_copy(struct volume_group *vg, struct volume_group
 	if (!(cft = export_vg_to_config_tree(vg)))
 		return_0;
 
-	if (!(*vg_embedded = import_vg_from_config_tree(cft, vg->fid))) {
+	if (!(*vg_embedded = import_vg_from_config_tree(vg->cmd, vg->fid, cft))) {
 		dm_config_destroy(cft);
 		return_0;
 	}
@@ -5220,7 +5220,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 			goto out;
 		}
 
-		if (!(vg->vg_committed = import_vg_from_config_tree(cft, vg->fid)))
+		if (!(vg->vg_committed = import_vg_from_config_tree(cmd, vg->fid, cft)))
 			log_warn("WARNING: vg_read no vg copy: copy import failed");
 
 		dm_config_destroy(cft);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 377a063..f199fc4 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -477,8 +477,10 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
  * For internal metadata caching.
  */
 struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg);
-struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
-						struct format_instance *fid);
+struct volume_group *import_vg_from_config_tree(struct cmd_context *cmd,
+						struct format_instance *fid,
+						const struct dm_config_tree *cft);
+struct volume_group *vg_from_config_tree(struct cmd_context *cmd, const struct dm_config_tree *cft);
 
 /*
  * Mirroring functions



