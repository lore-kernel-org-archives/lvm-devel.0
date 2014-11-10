From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:40 +0000 (UTC)
Subject: master - cleanup: use chunk_size directly
Message-ID: <20141110210640.7E58261069@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e97d2dd286a184fc1d26a9abb60fea9e2b7d44d
Commit:        1e97d2dd286a184fc1d26a9abb60fea9e2b7d44d
Parent:        f5e265a07fb3e083416d9f5cf17bd601a1e3f782
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 9 18:55:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cleanup: use chunk_size directly

---
 lib/cache_segtype/cache.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index c53eb23..11c5b10 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -35,7 +35,6 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 				   const struct dm_config_node *sn,
 				   struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	uint32_t chunk_size;
 	struct logical_volume *data_lv, *meta_lv;
 	const char *str = NULL;
 	struct dm_pool *mem = seg->lv->vg->vgmem;
@@ -56,7 +55,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
 			  "cache metadata in", str);
 
-	if (!dm_config_get_uint32(sn, "chunk_size", &chunk_size))
+	if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
 		return SEG_LOG_ERROR("Couldn't read cache chunk_size in");
 
 	/*
@@ -102,7 +101,6 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		return_0;
 	if (!attach_pool_metadata_lv(seg, meta_lv))
 		return_0;
-	seg->chunk_size = chunk_size;
 
 	return 1;
 }


