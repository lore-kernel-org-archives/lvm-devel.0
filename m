From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Jun 2013 11:48:09 +0000 (UTC)
Subject: master - debug: add pointer to -DDEBUG_POOL compilation
Message-ID: <20130625114809.D6B5B61386@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=939aeb7058e327686ff0e4f9e22b18893e0a7a3f
Commit:        939aeb7058e327686ff0e4f9e22b18893e0a7a3f
Parent:        a4d6f7939c83f2b60be7e892af7588693e651789
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 16:38:32 2010 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

debug: add pointer to -DDEBUG_POOL compilation

Show 'at' pointer address with pool name.
It's useful for debugging to be able to locate pointer address in the
debug trace log. It's only available when compiled with extra debug
compilation flag DEBUG_POOL in make.tmpl.
---
 libdm/mm/pool-debug.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index 3bd6cab..afaa39e 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -62,7 +62,7 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 	mem->orig_pool = mem;
 
 #ifdef DEBUG_POOL
-	log_debug_mem("Created mempool %s", name);
+	log_debug_mem("Created mempool %s at %p", name, mem);
 #endif
 
 	dm_list_add(&_dm_pools, &mem->list);
@@ -91,8 +91,8 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 static void _pool_stats(struct dm_pool *p, const char *action)
 {
 #ifdef DEBUG_POOL
-	log_debug_mem("%s mempool %s: %u/%u bytes, %u/%u blocks, "
-		      "%u allocations)", action, p->name, p->stats.bytes,
+	log_debug_mem("%s mempool %s at %p: %u/%u bytes, %u/%u blocks, "
+		      "%u allocations)", action, p->name, p, p->stats.bytes,
 		      p->stats.maxbytes, p->stats.blocks_allocated,
 		      p->stats.blocks_max, p->stats.block_serialno);
 #else


