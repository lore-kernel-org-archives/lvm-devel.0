From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:47 +0000 (UTC)
Subject: dev-mornfall-activate - Move export_vg_to_config_tree alongside export_vg_to_buffer.
Message-ID: <20130604192847.ECA1D60FD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=140007a272f471dddb85d1014cee4a06db7266fa
Commit:        140007a272f471dddb85d1014cee4a06db7266fa
Parent:        eb2c68590b766e25ada9d425ad0b6602cd724fcc
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 17 16:25:12 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jun 4 18:16:43 2013 +0200

Move export_vg_to_config_tree alongside export_vg_to_buffer.

---
 lib/cache/lvmetad.c      |   24 ++----------------------
 lib/format_text/export.c |   20 ++++++++++++++++++++
 lib/metadata/metadata.h  |    2 +-
 3 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7aa8641..6c8b10b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -425,26 +425,6 @@ static int _fixup_ignored(struct metadata_area *mda, void *baton) {
 	return 1;
 }
 
-static struct dm_config_tree *_export_vg_to_config_tree(struct volume_group *vg)
-{
-	char *buf = NULL;
-	struct dm_config_tree *vgmeta;
-
-	if (!export_vg_to_buffer(vg, &buf)) {
-		log_error("Could not format VG metadata.");
-		return 0;
-	}
-
-	if (!(vgmeta = dm_config_from_string(buf))) {
-		log_error("Error parsing VG metadata.");
-		dm_free(buf);
-		return 0;
-	}
-
-	dm_free(buf);
-	return vgmeta;
-}
-
 int lvmetad_vg_update(struct volume_group *vg)
 {
 	daemon_reply reply;
@@ -462,7 +442,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!lvmetad_active() || test_mode())
 		return 1; /* fake it */
 
-	if (!(vgmeta = _export_vg_to_config_tree(vg)))
+	if (!(vgmeta = export_vg_to_config_tree(vg)))
 		return_0;
 
 	log_debug_lvmetad("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
@@ -772,7 +752,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 		_extract_mdas(info, pvmeta, pvmeta->root);
 
 	if (vg) {
-		if (!(vgmeta = _export_vg_to_config_tree(vg))) {
+		if (!(vgmeta = export_vg_to_config_tree(vg))) {
 			dm_config_destroy(pvmeta);
 			return_0;
 		}
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 73b5a3a..9ac5160 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -841,5 +841,25 @@ size_t export_vg_to_buffer(struct volume_group *vg, char **buf)
 	return text_vg_export_raw(vg, "", buf);
 }
 
+struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
+{
+	char *buf = NULL;
+	struct dm_config_tree *vgmeta;
+
+	if (!export_vg_to_buffer(vg, &buf)) {
+		log_error("Could not format VG metadata.");
+		return 0;
+	}
+
+	if (!(vgmeta = dm_config_from_string(buf))) {
+		log_error("Error parsing VG metadata.");
+		dm_free(buf);
+		return 0;
+	}
+
+	dm_free(buf);
+	return vgmeta;
+}
+
 #undef outf
 #undef outnl
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 4f504ed..bf9bd55 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -437,7 +437,7 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
  * For internal metadata caching.
  */
 size_t export_vg_to_buffer(struct volume_group *vg, char **buf);
-int export_vg_to_config_tree(struct volume_group *vg, struct dm_config_tree **cft);
+struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg);
 struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
 struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,


