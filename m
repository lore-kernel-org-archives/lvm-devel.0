From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:49 +0000 (GMT)
Subject: main - metadata: enhance internal error
Message-ID: <20211006134749.CD61F385AC30@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98c57f7ce44788f22499f10f8d6c3f320869aa16
Commit:        98c57f7ce44788f22499f10f8d6c3f320869aa16
Parent:        b7e9ec0cbf55e4a4e1f027be49bf45b11beb5a76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 13:45:34 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:39:58 2021 +0200

metadata: enhance internal error

Consider missing config tree from vg read to be an internal error
since we do not want to 'regenerate' this one in expesive parsing way.

Also if there is any failure on recreating committed VG, make it also
a 'vg_write' error.
---
 lib/metadata/metadata.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f29e73c7c..146ce476d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5225,14 +5225,14 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		}
 
 		if (!vg->committed_cft) {
-			log_warn("WARNING: vg_read no vg copy: copy export failed.");
-			if (!(vg->committed_cft = export_vg_to_config_tree(vg)))
-				goto out;
+			log_error(INTERNAL_ERROR "Missing committed config tree.");
+			goto out;
 		}
 
-		if (!(vg->vg_committed = import_vg_from_config_tree(cmd, vg->fid, vg->committed_cft)))
-			log_warn("WARNING: vg_read no vg copy: copy import failed.");
-
+		if (!(vg->vg_committed = import_vg_from_config_tree(cmd, vg->fid, vg->committed_cft))) {
+			log_error("Failed to import written VG.");
+			goto out;
+		}
 	} else {
 		if (vg->vg_precommitted)
 			log_error(INTERNAL_ERROR "vg_read vg %p vg_precommitted %p", (void *)vg, (void *)vg->vg_precommitted);


