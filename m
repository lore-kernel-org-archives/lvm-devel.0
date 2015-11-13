From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:15 +0000 (UTC)
Subject: master - cleanup: check LVs in one statement
Message-ID: <20151113101915.17CB7610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f2a42c7b79ff99b29a999f0b636f340e5355456
Commit:        1f2a42c7b79ff99b29a999f0b636f340e5355456
Parent:        70af08122e26a3b7397e3f35b0e80a65543e157e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 22:06:27 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:06 2015 +0100

cleanup: check LVs in one statement

Use a single statement to check all LVs we want to
deref via  get_only_segment_using_this_lv().
---
 lib/metadata/lv.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 3126086..0310e70 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -289,17 +289,19 @@ char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv)
 struct logical_volume *lv_parent(const struct logical_volume *lv)
 {
 	struct logical_volume *parent_lv = NULL;
+	struct lv_segment *seg;
 
 	if (lv_is_visible(lv))
 		;
-	else if (lv_is_mirror_image(lv) || lv_is_mirror_log(lv))
-		parent_lv = get_only_segment_using_this_lv(lv)->lv;
-	else if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv))
-		parent_lv = get_only_segment_using_this_lv(lv)->lv;
-	else if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv))
-		parent_lv = get_only_segment_using_this_lv(lv)->lv;
-	else if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))
-		parent_lv = get_only_segment_using_this_lv(lv)->lv;
+	else if ((lv_is_mirror_image(lv) || lv_is_mirror_log(lv)) ||
+		 (lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) ||
+		 (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) ||
+		 (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))) {
+		if (!(seg = get_only_segment_using_this_lv(lv)))
+			stack;
+		else
+			parent_lv = seg->lv;
+	}
 
 	return parent_lv;
 }


