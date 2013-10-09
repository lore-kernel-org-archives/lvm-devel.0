From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 22:36:33 +0000 (UTC)
Subject: master - libdm: Fix a data race in dm_pool_{create, destroy}.
Message-ID: <20131009223633.8D447610C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5aad86710be57833879ac0e8609021828949682
Commit:        b5aad86710be57833879ac0e8609021828949682
Parent:        529a13ec8907d5693b64ca7063491db059533820
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 22:19:06 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 10 00:34:35 2013 +0200

libdm: Fix a data race in dm_pool_{create,destroy}.

---
 libdm/mm/pool-fast.c |    4 ++++
 libdm/mm/pool.c      |    9 +++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 2b494d6..edb31a0 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -62,7 +62,9 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 	while (new_size < p->chunk_size)
 		new_size <<= 1;
 	p->chunk_size = new_size;
+	pthread_mutex_lock(&_dm_pools_mutex);
 	dm_list_add(&_dm_pools, &p->list);
+	pthread_mutex_unlock(&_dm_pools_mutex);
 	return p;
 }
 
@@ -77,7 +79,9 @@ void dm_pool_destroy(struct dm_pool *p)
 		c = pr;
 	}
 
+	pthread_mutex_lock(&_dm_pools_mutex);
 	dm_list_del(&p->list);
+	pthread_mutex_unlock(&_dm_pools_mutex);
 	dm_free(p);
 }
 
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index fd08307..ef006a4 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -15,9 +15,10 @@
 
 #include "dmlib.h"
 #include <sys/mman.h>
+#include <pthread.h>
 
-/* FIXME: thread unsafe */
 static DM_LIST_INIT(_dm_pools);
+static pthread_mutex_t _dm_pools_mutex = PTHREAD_MUTEX_INITIALIZER;
 void dm_pools_check_leaks(void);
 
 #ifdef DEBUG_ENFORCE_POOL_LOCKING
@@ -81,8 +82,11 @@ void dm_pools_check_leaks(void)
 {
 	struct dm_pool *p;
 
-	if (dm_list_empty(&_dm_pools))
+	pthread_mutex_lock(&_dm_pools_mutex);
+	if (dm_list_empty(&_dm_pools)) {
+		pthread_mutex_unlock(&_dm_pools_mutex);
 		return;
+	}
 
 	log_error("You have a memory leak (not released memory pool):");
 	dm_list_iterate_items(p, &_dm_pools) {
@@ -94,6 +98,7 @@ void dm_pools_check_leaks(void)
 		log_error(" [%p] %s", p, p->name);
 #endif
 	}
+	pthread_mutex_unlock(&_dm_pools_mutex);
 	log_error(INTERNAL_ERROR "Unreleased memory pool(s) found.");
 }
 


