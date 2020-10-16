From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:05 +0000 (GMT)
Subject: stable-2.02 - bcache: use flexible arrays
Message-ID: <20201016191205.D157038618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8df5038853b927fefc83e4ae75a38411cc2d865
Commit:        e8df5038853b927fefc83e4ae75a38411cc2d865
Parent:        479f0822ad1074cab4bcb1b5404257618cce14b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 30 23:28:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

bcache: use flexible arrays

Cleanup, allocate whole struct with a single malloc call.
---
 lib/device/bcache.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index f68576a55..28fb42133 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -61,23 +61,17 @@ struct control_block {
 struct cb_set {
 	struct dm_list free;
 	struct dm_list allocated;
-	struct control_block *vec;
+	struct control_block vec[];
 } control_block_set;
 
 static struct cb_set *_cb_set_create(unsigned nr)
 {
 	unsigned i;
-	struct cb_set *cbs = malloc(sizeof(*cbs));
+	struct cb_set *cbs = malloc(sizeof(*cbs) + nr * sizeof(*cbs->vec));
 
-	if (!cbs)
+	if (!cbs->vec)
 		return NULL;
 
-	cbs->vec = malloc(nr * sizeof(*cbs->vec));
-	if (!cbs->vec) {
-		free(cbs);
-		return NULL;
-	}
-
 	dm_list_init(&cbs->free);
 	dm_list_init(&cbs->allocated);
 
@@ -97,7 +91,6 @@ static void _cb_set_destroy(struct cb_set *cbs)
 		return;
 	}
 
-	free(cbs->vec);
 	free(cbs);
 }
 


