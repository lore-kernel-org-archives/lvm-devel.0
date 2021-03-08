From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:43 +0000 (GMT)
Subject: main - vg_write: optimize caching of precommitted VG
Message-ID: <20210308144643.26AE33952009@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc0cb663043bb9c67151f88061ff22c53c6883ea
Commit:        bc0cb663043bb9c67151f88061ff22c53c6883ea
Parent:        a125a3bb505cc2f0374715f850f4c1e02c7d4e3c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 5 22:12:58 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:30:18 2021 +0100

vg_write: optimize caching of precommitted VG

Every vg_write stores new 'metadata' into precommitted slot.
For this step we use 'serialized buffer' to ascii metadata.

Instead of recreating this buffer after whole 'vg_write()' we
use this buffer instantly for creating of precommitted VG.

This has also the advantage of catching any problems with
reparsing of ascii metadata back to VG early before any write.
---
 lib/format_text/format-text.c | 17 +++++++++++++++++
 lib/metadata/metadata.c       | 29 -----------------------------
 2 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e8533d5dc..bf1b9b3a4 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -28,6 +28,7 @@
 #include "lib/mm/xlate.h"
 #include "lib/label/label.h"
 #include "lib/cache/lvmcache.h"
+#include "libdaemon/client/config-util.h"
 
 #include <unistd.h>
 #include <limits.h>
@@ -579,6 +580,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			 struct metadata_area *mda)
 {
 	char desc[2048];
+	struct dm_config_tree *cft;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct text_fid_context *fidtc = (struct text_fid_context *) fid->private;
 	struct raw_locn *rlocn_old;
@@ -662,6 +664,21 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		fidtc->write_buf = write_buf;
 		fidtc->write_buf_size = write_buf_size;
 		fidtc->new_metadata_size = new_size;
+
+		/* Immediatelly reuse existing buffer for parsing metadata back.
+		 * Such VG is then used for as precommitted VG and later committed VG.
+		 *
+		 * 'Lazy' creation of such VG might improve performance, but we
+		 * lose important validation that written metadata can be parsed. */
+		if (!(cft = config_tree_from_string_without_dup_node_check(write_buf))) {
+			log_error("Error parsing metadata for VG %s.", vg->name);
+			goto out;
+		}
+		release_vg(vg->vg_precommitted);
+		vg->vg_precommitted = import_vg_from_config_tree(vg->cmd, vg->fid, cft);
+		dm_config_destroy(cft);
+		if (!vg->vg_precommitted)
+			goto_out;
 	}
 
 	if (!new_size || !write_buf) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2915c1d07..daf49827f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -996,32 +996,6 @@ static void _vg_move_cached_precommitted_to_committed(struct volume_group *vg)
 	vg->vg_precommitted = NULL;
 }
 
-/*
- * Update content of precommitted VG
- *
- * TODO: Optimize in the future, since lvmetad needs similar
- *       config tree processing in lvmetad_vg_update().
- */
-static int _vg_update_embedded_copy(struct volume_group *vg, struct volume_group **vg_embedded)
-{
-	struct dm_config_tree *cft;
-
-	_vg_wipe_cached_precommitted(vg);
-
-	/* Copy the VG using an export followed by import */
-	if (!(cft = export_vg_to_config_tree(vg)))
-		return_0;
-
-	if (!(*vg_embedded = import_vg_from_config_tree(vg->cmd, vg->fid, cft))) {
-		dm_config_destroy(cft);
-		return_0;
-	}
-
-	dm_config_destroy(cft);
-
-	return 1;
-}
-
 int lv_has_unknown_segments(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
@@ -3121,9 +3095,6 @@ int vg_write(struct volume_group *vg)
 		}
 	}
 
-	if (!_vg_update_embedded_copy(vg, &vg->vg_precommitted)) /* prepare precommited */
-		return_0;
-
 	lockd_vg_update(vg);
 
 	return 1;


