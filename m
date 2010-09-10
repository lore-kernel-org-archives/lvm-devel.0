From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Sep 2010 12:54:11 -0400
Subject: [PATCH] Simplify logic to create 'attr' strings.
In-Reply-To: <4C89FA39.8010107@redhat.com>
References: <4C89FA39.8010107@redhat.com>
Message-ID: <1284137651-11782-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   71 ++++++++--------------------------------------
 1 files changed, 13 insertions(+), 58 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f418c18..bbd450b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4569,32 +4569,12 @@ char *vg_attr(struct dm_pool *mem, const struct volume_group *vg)
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
 	repstr[4] = _alloc_policy_char(vg->alloc);
-
-	if (vg_is_clustered(vg))
-		repstr[5] = 'c';
-	else
-		repstr[5] = '-';
+	repstr[5] = (vg_is_clustered(vg)) ? 'c' : '-';
 	return repstr;
 }
 
@@ -4607,15 +4587,8 @@ char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv)
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
 
@@ -4674,28 +4647,16 @@ char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv)
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
 
@@ -4713,10 +4674,7 @@ char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv)
 	if (lv->status & LOCKED)
 		repstr[2] = toupper(repstr[2]);
 
-	if (lv->status & FIXED_MINOR)
-		repstr[3] = 'm';	/* Fixed Minor */
-	else
-		repstr[3] = '-';
+	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
 	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
 		if (info.suspended)
@@ -4739,10 +4697,7 @@ char *lv_attr(struct dm_pool *mem, const struct logical_volume *lv)
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
-- 
1.7.2.1


