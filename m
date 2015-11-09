From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:47 +0000 (UTC)
Subject: master - alloc: use own mem pool for alloc_handle
Message-ID: <20151109092847.86F2F60F24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07046e994fc10882cac20d16666368a6de18a528
Commit:        07046e994fc10882cac20d16666368a6de18a528
Parent:        0c380c316c51920db5b5721863cb1b55bfa9acf1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 4 14:54:07 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:49 2015 +0100

alloc: use own mem pool for alloc_handle

Keep alloc_handle's data in a single mempool and do not
spread them into vgmem pool.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   19 ++++++++++---------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 00b7ee1..7dc5a45 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Use local memory pool for whole alloc_handle manipulation.
   Add missing pointer validation after dm_get_next_target().
   Do not deref NULL pointer in debug message for _match_pv_tags().
   Drop unneeded stat() call when checking for sysfs file.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c9cc6b5..48f470e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3138,7 +3138,6 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
  * If log_area_count > 1 it is always mirrored (not striped).
  */
 static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
-					struct dm_pool *mem,
 					const struct segment_type *segtype,
 					alloc_policy_t alloc, int approx_alloc,
 					uint32_t existing_extents,
@@ -3150,6 +3149,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					uint32_t region_size,
 					struct dm_list *parallel_areas)
 {
+	struct dm_pool *mem;
 	struct alloc_handle *ah;
 	uint32_t s, area_count, alloc_count, parity_count, total_extents;
 	size_t size = 0;
@@ -3199,21 +3199,23 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	size += sizeof(ah->alloced_areas[0]) * alloc_count;
 
+	if (!(mem = dm_pool_create("allocation", 1024))) {
+		log_error("allocation pool creation failed");
+		return NULL;
+	}
+
 	if (!(ah = dm_pool_zalloc(mem, size))) {
 		log_error("allocation handle allocation failed");
+		dm_pool_destroy(mem);
 		return NULL;
 	}
 
 	ah->cmd = cmd;
+	ah->mem = mem;
 
 	if (segtype_is_virtual(segtype))
 		return ah;
 
-	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
-		log_error("allocation pool creation failed");
-		return NULL;
-	}
-
 	ah->area_count = area_count;
 	ah->parity_count = parity_count;
 	ah->region_size = region_size;
@@ -3314,8 +3316,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 void alloc_destroy(struct alloc_handle *ah)
 {
-	if (ah->mem)
-		dm_pool_destroy(ah->mem);
+	dm_pool_destroy(ah->mem);
 }
 
 /*
@@ -3356,7 +3357,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 	if (alloc >= ALLOC_INHERIT)
 		alloc = vg->alloc;
 
-	if (!(ah = _alloc_init(vg->cmd, vg->vgmem, segtype, alloc, approx_alloc,
+	if (!(ah = _alloc_init(vg->cmd, segtype, alloc, approx_alloc,
 			       lv ? lv->le_count : 0, extents, mirrors, stripes, log_count,
 			       vg->extent_size, region_size,
 			       parallel_areas)))


