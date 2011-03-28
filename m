From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:12 +0200
Subject: [PATCH 1/6] Unreleased pool is INTERNAL_ERROR
In-Reply-To: <cover.1301313391.git.zkabelac@redhat.com>
References: <cover.1301313391.git.zkabelac@redhat.com>
Message-ID: <633b511e98d1f5c4faf5438b489c5cc722bd1a5e.1301313392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's better for catching bugs in test-suite.
(As currently one test does not pass without noticing.)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/pool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 825f7ca..0e2444d 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -64,7 +64,6 @@ void dm_pools_check_leaks(void)
 	if (dm_list_empty(&_dm_pools))
 		return;
 
-	log_error("You have a memory leak (not released memory pool):");
 	dm_list_iterate_items(p, &_dm_pools) {
 #ifdef DEBUG_POOL
 		log_error(" [%p] %s (%u bytes)",
@@ -74,4 +73,5 @@ void dm_pools_check_leaks(void)
 		log_error(" [%p] %s", p, p->name);
 #endif
 	}
+	log_error(INTERNAL_ERROR "Unreleased memory pool(s) found.");
 }
-- 
1.7.4.1


