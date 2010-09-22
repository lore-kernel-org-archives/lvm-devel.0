From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:17 -0400
Subject: [PATCH 05/20] Simplify logic to create 'attr' strings.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch addresses code review request to simplify creation of 'attr'
strings.  The simplification is done in this separate patch to more
easily review and ensure the simplification is done without error.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c |   30 ++++++------------------------
 lib/metadata/pv.c |   11 ++---------
 lib/metadata/vg.c |   30 +++++-------------------------
 3 files changed, 13 insertions(+), 58 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0c01c73..6abcdab 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -61,28 +61,16 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[0] = 'v';
 	/* Origin takes precedence over Mirror */
 	else if (lv_is_origin(lv)) {
-		if (lv_is_merging_origin(lv))
-			repstr[0] = 'O';
-		else
-			repstr[0] = 'o';
+		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	}
 	else if (lv->status & MIRRORED) {
-		if (lv->status & MIRROR_NOTSYNCED)
-			repstr[0] = 'M';
-		else
-			repstr[0] = 'm';
+		repstr[0] = (lv->status & MIRROR_NOTSYNCED) ? 'M' : 'm';
 	}else if (lv->status & MIRROR_IMAGE)
-		if (_lv_mimage_in_sync(lv))
-			repstr[0] = 'i';
-		else
-			repstr[0] = 'I';
+		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv)) {
-		if (lv_is_merging_cow(lv))
-			repstr[0] = 'S';
-		else
-			repstr[0] = 's';
+		repstr[0] = (lv_is_merging_cow(lv)) ? 'S' : 's';
 	} else
 		repstr[0] = '-';
 
@@ -100,10 +88,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (lv->status & LOCKED)
 		repstr[2] = toupper(repstr[2]);
 
-	if (lv->status & FIXED_MINOR)
-		repstr[3] = 'm';	/* Fixed Minor */
-	else
-		repstr[3] = '-';
+	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
 	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
 		if (info.suspended)
@@ -126,10 +111,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 				repstr[4] = 'I'; /* Invalid snapshot */
 		}
 
-		if (info.open_count)
-			repstr[5] = 'o';	/* Open */
-		else
-			repstr[5] = '-';
+		repstr[5] = (info.open_count) ? 'o' : '-';
 	} else {
 		repstr[4] = '-';
 		repstr[5] = '-';
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 7c603e1..a21b7d6 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -172,15 +172,8 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 		return NULL;
 	}
 
-	if (pv->status & ALLOCATABLE_PV)
-		repstr[0] = 'a';
-	else
-		repstr[0] = '-';
-
-	if (pv->status & EXPORTED_VG)
-		repstr[1] = 'x';
-	else
-		repstr[1] = '-';
+	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : '-';
+	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
 	return repstr;
 }
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 3315c7e..07cb60a 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -443,31 +443,11 @@ char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 		return NULL;
 	}
 
-	if (vg->status & LVM_WRITE)
-		repstr[0] = 'w';
-	else
-		repstr[0] = 'r';
-
-	if (vg_is_resizeable(vg))
-		repstr[1] = 'z';
-	else
-		repstr[1] = '-';
-
-	if (vg_is_exported(vg))
-		repstr[2] = 'x';
-	else
-		repstr[2] = '-';
-
-	if (vg_missing_pv_count(vg))
-		repstr[3] = 'p';
-	else
-		repstr[3] = '-';
-
+	repstr[0] = (vg->status & LVM_WRITE) ? 'w' : 'r';
+	repstr[1] = (vg_is_resizeable(vg)) ? 'z' : '-';
+	repstr[2] = (vg_is_exported(vg)) ? 'x' : '-';
+	repstr[3] = (vg_missing_pv_count(vg)) ? 'p' : '-';
 	repstr[4] = alloc_policy_char(vg->alloc);
-
-	if (vg_is_clustered(vg))
-		repstr[5] = 'c';
-	else
-		repstr[5] = '-';
+	repstr[5] = (vg_is_clustered(vg)) ? 'c' : '-';
 	return repstr;
 }
-- 
1.7.2.2


