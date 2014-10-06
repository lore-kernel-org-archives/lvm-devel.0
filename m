From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:49 +0000 (UTC)
Subject: master - cleanup: error is already logged
Message-ID: <20141006133349.CE57D60DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=916a68585e5078ff3f3190a9f77bee2f7b9b30a2
Commit:        916a68585e5078ff3f3190a9f77bee2f7b9b30a2
Parent:        73c74d582c27400f8cad939a52503e3721c0e153
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 12:01:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:08 2014 +0200

cleanup: error is already logged

Function get_only_segment_using_this_lv() already prints error,
no need to show more internal logic to user as an error.
---
 lib/metadata/pool_manip.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 6e2f2fe..439b8ed 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -215,12 +215,8 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
 	struct lv_segment *pool_seg;
 
-	pool_seg = get_only_segment_using_this_lv(seg->lv);
-
-	if (!pool_seg) {
-		log_error("Failed to find pool_seg for %s", seg->lv->name);
-		return NULL;
-	}
+	if (!(pool_seg = get_only_segment_using_this_lv(seg->lv)))
+		return_NULL;
 
 	if ((lv_is_thin_type(seg->lv) && !seg_is_pool(pool_seg))) {
 		log_error("%s on %s is not a %s pool segment",


