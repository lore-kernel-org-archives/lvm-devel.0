From: Milan Broz <mbroz@redhat.com>
Date: Wed, 25 Mar 2009 18:07:22 +0100
Subject: [PATCH] fix dm debug pool issues
Message-ID: <49CA64CA.6010708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

fix some issues when compiling with -D DEBUG_POOL 

- fix compilation issues

- fix wrong pool object maipulation (lvm dumpconfig triggers assert)

Signed-off-by: Milan Broz <mbroz@redhat.com>

diff --git a/lib/config/config.c b/lib/config/config.c
index c80f18e..224f2ce 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -457,9 +457,9 @@ static int _write_config(struct config_node *n, int only_one,
 			line_append(" {");
 			if (!_line_end(outline))
 				return_0;
+			_write_config(n->child, 0, outline, level + 1);
 			if (!_line_start(outline))
 				return_0;
-			_write_config(n->child, 0, outline, level + 1);
 			line_append("%s}", space);
 		} else {
 			/* it's a value */
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index b656cc2..911f8e2 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -14,6 +14,7 @@
  */
 
 #include "dmlib.h"
+#include <assert.h>
 
 struct block {
 	struct block *next;
@@ -43,7 +44,7 @@ struct dm_pool {
 /* by default things come out aligned for doubles */
 #define DEFAULT_ALIGNMENT __alignof__ (double)
 
-struct pool *dm_pool_create(const char *name, size_t chunk_hint)
+struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 {
 	struct dm_pool *mem = dm_malloc(sizeof(*mem));
 
@@ -130,8 +131,6 @@ static void _append_block(struct dm_pool *p, struct block *b)
 
 static struct block *_new_block(size_t s, unsigned alignment)
 {
-	static const char *_oom = "Out of memory";
-
 	/* FIXME: I'm currently ignoring the alignment arg. */
 	size_t len = sizeof(struct block) + s;
 	struct block *b = dm_malloc(len);
@@ -144,12 +143,12 @@ static struct block *_new_block(size_t s, unsigned alignment)
 	assert(alignment == DEFAULT_ALIGNMENT);
 
 	if (!b) {
-		log_err(_oom);
+		log_err("Out of memory");
 		return NULL;
 	}
 
 	if (!(b->data = dm_malloc(s))) {
-		log_err(_oom);
+		log_err("Out of memory");
 		dm_free(b);
 		return NULL;
 	}



