From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:44 +0000 (GMT)
Subject: main - vg_read: reuse already parsed config tree
Message-ID: <20210308144644.48E6B395200F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=936c7b5104e4fb6fb489845b87d9ba2cd1a69d0a
Commit:        936c7b5104e4fb6fb489845b87d9ba2cd1a69d0a
Parent:        bc0cb663043bb9c67151f88061ff22c53c6883ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 5 23:04:44 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:30:18 2021 +0100

vg_read: reuse already parsed config tree

When parsing VG metadata we can create from a single config tree
also 'vg_committed' that is always created for writable VG.

This avoids extra uncessary step of serializing and deserilizing
just parsed VG.
---
 lib/format_text/import.c |  5 ++++-
 lib/metadata/metadata.c  | 10 ++++------
 lib/metadata/vg.c        |  2 ++
 lib/metadata/vg.h        |  4 ++--
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 2dc80f13f..2687d172e 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -186,6 +186,8 @@ struct volume_group *text_read_metadata(struct format_instance *fid,
 			goto_out;
 
 		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
+		vg->committed_cft = cft; /* Reuse CFT for recreation of committed VG */
+		cft = NULL;
 		break;
 	}
 
@@ -198,7 +200,8 @@ struct volume_group *text_read_metadata(struct format_instance *fid,
 		*use_previous_vg = 0;
 
       out:
-	config_destroy(cft);
+	if (cft)
+		config_destroy(cft);
 	return vg;
 }
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index daf49827f..5410eac60 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5186,8 +5186,6 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	 * FIXME: be specific about exactly when this works correctly.
 	 */
 	if (writing) {
-		struct dm_config_tree *cft;
-
 		if (dm_pool_locked(vg->vgmem)) {
 			/* FIXME: can this happen? */
 			log_warn("WARNING: vg_read no vg copy: pool locked.");
@@ -5208,15 +5206,15 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 			vg->vg_precommitted = NULL;
 		}
 
-		if (!(cft = export_vg_to_config_tree(vg))) {
+		if (!vg->committed_cft) {
 			log_warn("WARNING: vg_read no vg copy: copy export failed.");
-			goto out;
+			if (!(vg->committed_cft = export_vg_to_config_tree(vg)))
+				goto out;
 		}
 
-		if (!(vg->vg_committed = import_vg_from_config_tree(cmd, vg->fid, cft)))
+		if (!(vg->vg_committed = import_vg_from_config_tree(cmd, vg->fid, vg->committed_cft)))
 			log_warn("WARNING: vg_read no vg copy: copy import failed.");
 
-		dm_config_destroy(cft);
 	} else {
 		if (vg->vg_precommitted)
 			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", (void *)vg, (void *)vg->vg_precommitted);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 9a8693c0b..e659579c2 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -79,6 +79,8 @@ static void _free_vg(struct volume_group *vg)
 
 	log_debug_mem("Freeing VG %s at %p.", vg->name ? : "<no name>", (void *)vg);
 
+	if (vg->committed_cft)
+		config_destroy(vg->committed_cft);
 	dm_hash_destroy(vg->hostnames);
 	dm_pool_destroy(vg->vgmem);
 }
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index fa1b03621..36d1ed155 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -50,9 +50,9 @@ struct volume_group {
 	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed
 	 * version (i.e. vg_committed == NULL *implies* this is the committed copy,
 	 * there is no guarantee that if this VG is the same as the committed one
-	 * this will be NULL). The pointer is maintained by calls to
-	 * _vg_update_vg_committed.
+	 * this will be NULL). The pointer is maintained by calls to vg_write & vg_commit
 	 */
+	struct dm_config_tree *committed_cft;
 	struct volume_group *vg_committed;
 	struct volume_group *vg_precommitted;
 


