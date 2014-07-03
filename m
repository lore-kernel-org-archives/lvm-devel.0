From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  3 Jul 2014 18:06:46 +0000 (UTC)
Subject: master - vgsplit: Fix VG component of lvid.
Message-ID: <20140703180646.E4C2660F7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e1c2769a7092959e5c0076767b4973d4e4dc37c
Commit:        1e1c2769a7092959e5c0076767b4973d4e4dc37c
Parent:        64ce3a8066ead3bc2ee16e9cc286d68057bbe956
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 3 19:06:04 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 3 19:06:04 2014 +0100

vgsplit: Fix VG component of lvid.

Fix VG component of lvid in vgsplit and vgmerge
Update vg_validate() to detect the error.
Call lv_is_active() before moving LV into new VG, not after.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   12 ++++++++++++
 tools/vgmerge.c         |    1 +
 tools/vgsplit.c         |   16 +++++++---------
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 625d58f..96c4c65 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Fix VG component of lvid in vgsplit/vgmerge and check in vg_validate.
   Add lv_full_name and lv_dm_path fields to reports.
   Change lv_path field to suppress devices that never appear in /dev/vg.
   Postpone thin pool lvconvert prompts (2.02.107).
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0a6e9e9..50d44ec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2331,6 +2331,7 @@ int vg_validate(struct volume_group *vg)
 	struct lv_segment *seg;
 	struct dm_str_list *sl;
 	char uuid[64] __attribute__((aligned(8)));
+	char uuid2[64] __attribute__((aligned(8)));
 	int r = 1;
 	unsigned hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
 	unsigned pv_count = 0;
@@ -2427,6 +2428,17 @@ int vg_validate(struct volume_group *vg)
 			r = 0;
 		}
 
+		if (!id_equal(&lvl->lv->lvid.id[0], &lvl->lv->vg->id)) {
+			if (!id_write_format(&lvl->lv->lvid.id[0], uuid,
+					     sizeof(uuid)))
+				stack;
+			if (!id_write_format(&lvl->lv->vg->id, uuid2,
+					     sizeof(uuid2)))
+				stack;
+			log_error(INTERNAL_ERROR "LV %s has VG UUID %s but its VG %s has UUID %s",
+				  lvl->lv->name, uuid, lvl->lv->vg->name, uuid2);
+			r = 0;
+		}
 
 		if (lv_is_cow(lvl->lv))
 			num_snapshots++;
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 3782779..a17a636 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -133,6 +133,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 
 	dm_list_iterate_items(lvl1, &vg_from->lvs) {
 		lvl1->lv->vg = vg_to;
+		lvl1->lv->lvid.id[0] = lvl1->lv->vg->id;
 	}
 
 	while (!dm_list_empty(&vg_from->lvs)) {
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index fb67919..9b0f616 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -16,14 +16,10 @@
 #include "tools.h"
 #include "metadata.h"  /* for 'get_only_segment_using_this_lv' */
 
-/* FIXME Why not (lv->vg == vg) ? */
 static int _lv_is_in_vg(struct volume_group *vg, struct logical_volume *lv)
 {
-	struct lv_list *lvl;
-
-	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv == lvl->lv)
-			 return 1;
+	if (lv->vg == vg)
+		return 1;
 
 	return 0;
 }
@@ -34,14 +30,16 @@ static int _move_one_lv(struct volume_group *vg_from,
 {
 	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
 
-	dm_list_move(&vg_to->lvs, lvh);
-	lv->vg = vg_to;
-
 	if (lv_is_active(lv)) {
 		log_error("Logical volume \"%s\" must be inactive", lv->name);
 		return 0;
 	}
 
+	dm_list_move(&vg_to->lvs, lvh);
+	lv->vg = vg_to;
+
+	lv->lvid.id[0] = lv->vg->id;
+
 	/* Moved pool metadata spare LV */
 	if (vg_from->pool_metadata_spare_lv == lv) {
 		vg_to->pool_metadata_spare_lv = lv;


