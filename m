From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:07 +0000 (UTC)
Subject: master - metadata: Factor _wipe_outdated_pvs() PVs out of _vg_read().
Message-ID: <20150520174807.AA62C60188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5435346052f491333b79da48bec5ef160cd118d5
Commit:        5435346052f491333b79da48bec5ef160cd118d5
Parent:        1562cd732060f995663a586566b15bc129e62b64
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 15 16:40:26 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:13 2015 +0200

metadata: Factor _wipe_outdated_pvs() PVs out of _vg_read().

---
 lib/metadata/metadata.c |   53 +++++++++++++++++++++++++---------------------
 1 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 19741ba..5456c4e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3224,6 +3224,30 @@ static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
 	return 1;
 }
 
+static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg, struct dm_list *to_check)
+{
+	struct pv_list *pvl, *pvl2;
+	char uuid[64] __attribute__((aligned(8)));
+	dm_list_iterate_items(pvl, to_check) {
+		dm_list_iterate_items(pvl2, &vg->pvs) {
+			if (pvl->pv->dev == pvl2->pv->dev)
+				goto next_pv;
+		}
+		if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
+			return_0;
+		log_warn("WARNING: Removing PV %s (%s) that no longer belongs to VG %s",
+			 pv_dev_name(pvl->pv), uuid, vg->name);
+		if (!pv_write_orphan(cmd, pvl->pv))
+			return_0;
+
+		/* Refresh metadata after orphan write */
+		drop_cached_metadata(vg);
+next_pv:
+		;
+	}
+	return 1;
+}
+
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -3257,9 +3281,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_mda_count = 0;
 	unsigned use_precommitted = precommitted;
 	struct dm_list *pvids;
-	struct pv_list *pvl, *pvl2;
+	struct pv_list *pvl;
 	struct dm_list all_pvs;
-	char uuid[64] __attribute__((aligned(8)));
 	unsigned seqno = 0;
 	int reappeared = 0;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
@@ -3684,28 +3707,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return NULL;
 		}
 
-		dm_list_iterate_items(pvl, &all_pvs) {
-			dm_list_iterate_items(pvl2, &correct_vg->pvs) {
-				if (pvl->pv->dev == pvl2->pv->dev)
-					goto next_pv;
-			}
-			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid))) {
-				_free_pv_list(&all_pvs);
-				release_vg(correct_vg);
-				return_NULL;
-			}
-			log_warn("WARNING: Removing PV %s (%s) that no longer belongs to VG %s",
-				 pv_dev_name(pvl->pv), uuid, correct_vg->name);
-			if (!pv_write_orphan(cmd, pvl->pv)) {
-				_free_pv_list(&all_pvs);
-				release_vg(correct_vg);
-				return_NULL;
-			}
-
-			/* Refresh metadata after orphan write */
-			drop_cached_metadata(correct_vg);
-      next_pv:
-			;
+		if (!_wipe_outdated_pvs(cmd, correct_vg, &all_pvs)) {
+			_free_pv_list(&all_pvs);
+			release_vg(correct_vg);
+			return_NULL;
 		}
 	}
 


