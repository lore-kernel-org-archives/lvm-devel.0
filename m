From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  9 Mar 2011 13:18:35 +0100
Subject: [PATCH 4/4] Add pool name to pool-fast as well
In-Reply-To: <cover.1299670163.git.zkabelac@redhat.com>
References: <cover.1299670163.git.zkabelac@redhat.com>
Message-ID: <3febf9d0e2ef73694a66af76e603eeddf0810b9c.1299670163.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's fairly cheap to keep this name - and it could
be useful without 'non pool debug code' compilation.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/pool-fast.c |    2 ++
 libdm/mm/pool.c      |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index ebd982e..377ad99 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -28,6 +28,7 @@ struct dm_pool {
 	struct dm_list list;
 	struct chunk *chunk, *spare_chunk;	/* spare_chunk is a one entry free
 						   list to stop 'bobbling' */
+	const char *name;
 	size_t chunk_size;
 	size_t object_len;
 	unsigned object_alignment;
@@ -51,6 +52,7 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 		return 0;
 	}
 
+	p->name = name;
 	/* round chunk_hint up to the next power of 2 */
 	p->chunk_size = chunk_hint + sizeof(struct chunk);
 	while (new_size < p->chunk_size)
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 35bfffa..825f7ca 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -71,7 +71,7 @@ void dm_pools_check_leaks(void)
 			  p->orig_pool,
 			  p->name, p->stats.bytes);
 #else
-		log_error(" [%p]", p);
+		log_error(" [%p] %s", p, p->name);
 #endif
 	}
 }
-- 
1.7.4.1


