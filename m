From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 15:10:20 +0000 (UTC)
Subject: master - metadata: Reject lvmetad metadata extensions when reading from disk.
Message-ID: <20150612151020.7EB5C60AAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c78b6f18d4909dc4e5c873b3b1023c2053443046
Commit:        c78b6f18d4909dc4e5c873b3b1023c2053443046
Parent:        4f91ad64c3c76ab31efe6bfad362adefd47adff2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 10 16:25:57 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 10 16:25:57 2015 +0200

metadata: Reject lvmetad metadata extensions when reading from disk.

---
 lib/cache/lvmetad.c             |    2 +-
 lib/format_text/import-export.h |    3 ++-
 lib/format_text/import.c        |   21 +++++++++++++++++----
 lib/format_text/import_vsn1.c   |   10 +++++++---
 lib/metadata/metadata.h         |    2 ++
 5 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index dd1219b..9aac6e9 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -483,7 +483,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 				_pv_populate_lvmcache(cmd, pvcn, fmt, 0);
 
 		top->key = name;
-		if (!(vg = import_vg_from_config_tree(reply.cft, fid)))
+		if (!(vg = import_vg_from_lvmetad_config_tree(reply.cft, fid)))
 			goto_out;
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 1ee647b..f60496f 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -47,7 +47,8 @@ struct text_vg_version_ops {
 	int (*check_version) (const struct dm_config_tree * cf);
 	struct volume_group *(*read_vg) (struct format_instance * fid,
 					 const struct dm_config_tree *cf,
-					 unsigned use_cached_pvs);
+					 unsigned use_cached_pvs,
+					 unsigned allow_lvmetad_extensions);
 	void (*read_desc) (struct dm_pool * mem, const struct dm_config_tree *cf,
 			   time_t *when, char **desc);
 	int (*read_vgname) (const struct format_type *fmt,
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 84230cb..16cdf9b 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -146,7 +146,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vg = (*vsn)->read_vg(fid, cft, single_device)))
+		if (!(vg = (*vsn)->read_vg(fid, cft, single_device, 0)))
 			goto_out;
 
 		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
@@ -174,8 +174,9 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 				 when, desc);
 }
 
-struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
-						struct format_instance *fid)
+static struct volume_group *_import_vg_from_config_tree(const struct dm_config_tree *cft,
+							struct format_instance *fid,
+							unsigned allow_lvmetad_extensions)
 {
 	struct volume_group *vg = NULL;
 	struct text_vg_version_ops **vsn;
@@ -190,7 +191,7 @@ struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft
 		 * The only path to this point uses cached vgmetadata,
 		 * so it can use cached PV state too.
 		 */
-		if (!(vg = (*vsn)->read_vg(fid, cft, 1)))
+		if (!(vg = (*vsn)->read_vg(fid, cft, 1, allow_lvmetad_extensions)))
 			stack;
 		else if ((vg_missing = vg_missing_pv_count(vg))) {
 			log_verbose("There are %d physical volumes missing.",
@@ -203,3 +204,15 @@ struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft
 
 	return vg;
 }
+
+struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
+						struct format_instance *fid)
+{
+	return _import_vg_from_config_tree(cft, fid, 0);
+}
+
+struct volume_group *import_vg_from_lvmetad_config_tree(const struct dm_config_tree *cft,
+							struct format_instance *fid)
+{
+	return _import_vg_from_config_tree(cft, fid, 1);
+}
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 2d62905..048c8fe 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -740,7 +740,8 @@ static int _read_sections(struct format_instance *fid,
 
 static struct volume_group *_read_vg(struct format_instance *fid,
 				     const struct dm_config_tree *cft,
-				     unsigned use_cached_pvs)
+				     unsigned use_cached_pvs,
+				     unsigned allow_lvmetad_extensions)
 {
 	const struct dm_config_node *vgn;
 	const struct dm_config_value *cv;
@@ -882,8 +883,11 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	_read_sections(fid, "outdated_pvs", _read_pv, vg,
-		       vgn, pv_hash, lv_hash, 1, &scan_done_once);
+	if (allow_lvmetad_extensions)
+		_read_sections(fid, "outdated_pvs", _read_pv, vg,
+			       vgn, pv_hash, lv_hash, 1, &scan_done_once);
+	else if (dm_config_has_node(vgn, "outdated_pvs"))
+		log_error(INTERNAL_ERROR "Unexpected outdated_pvs section in metadata of VG %s.", vg->name);
 
 	/* Optional tags */
 	if (dm_config_get_list(vgn, "tags", &cv) &&
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 031d19e..abf6072 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -460,6 +460,8 @@ struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
 struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
 						struct format_instance *fid);
+struct volume_group *import_vg_from_lvmetad_config_tree(const struct dm_config_tree *cft,
+							struct format_instance *fid);
 
 /*
  * Mirroring functions


