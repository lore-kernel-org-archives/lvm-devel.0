From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:53 +0000 (UTC)
Subject: master - debug: extra validation of passed segment
Message-ID: <20150508131653.0273260DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbdf514bbc3f22453c2c72c913e9161935a22bd8
Commit:        cbdf514bbc3f22453c2c72c913e9161935a22bd8
Parent:        29c709f5914ccd9159d84f8920c34b2c6ef51740
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 14:04:22 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:11 2015 +0200

debug: extra validation of passed segment

Always check if passed segment really is correct cache segment.
(Avoids derefernce of possibly NULL seg->pool_lv).
---
 lib/cache_segtype/cache.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index afc0ec6..ca30495 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -282,9 +282,16 @@ static int _cache_add_target_line(struct dev_manager *dm,
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	struct lv_segment *cache_pool_seg = first_seg(seg->pool_lv);
+	struct lv_segment *cache_pool_seg;
 	char *metadata_uuid, *data_uuid, *origin_uuid;
 
+	if (!seg->pool_lv || !seg_is_cache(seg)) {
+		log_error(INTERNAL_ERROR "Passed segment is not cache.");
+		return 0;
+	}
+
+	cache_pool_seg = first_seg(seg->pool_lv);
+
 	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
 		return_0;
 


