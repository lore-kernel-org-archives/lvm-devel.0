From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:52 +0000 (GMT)
Subject: main - cleanup: remove unused code
Message-ID: <20211006134752.1C1953857C56@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a841babaf7f0108797ef18af0777721742c8656c
Commit:        a841babaf7f0108797ef18af0777721742c8656c
Parent:        5ea426e65628218569ede461312d80ba5d1c50fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 13:47:43 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:43:31 2021 +0200

cleanup: remove unused code

---
 lib/metadata/metadata.c | 12 ------------
 lib/metadata/metadata.h |  3 ---
 2 files changed, 15 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 146ce476d..d5ef7f7cb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1648,18 +1648,6 @@ struct lv_list *find_lv_in_vg(const struct volume_group *vg,
 	return NULL;
 }
 
-struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
-				   const struct logical_volume *lv)
-{
-	struct lv_list *lvl;
-
-	dm_list_iterate_items(lvl, ll)
-		if (lvl->lv == lv)
-			return lvl;
-
-	return NULL;
-}
-
 struct logical_volume *find_lv_in_vg_by_lvid(const struct volume_group *vg,
 					     const union lvid *lvid)
 {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 3b3145d2c..95ca320e6 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -395,9 +395,6 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 struct logical_volume *find_lv_in_vg_by_lvid(const struct volume_group *vg,
 					     const union lvid *lvid);
 
-struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
-				   const struct logical_volume *lv);
-
 /* FIXME Merge these functions with ones above */
 struct physical_volume *find_pv(struct volume_group *vg, struct device *dev);
 


