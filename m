From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:53 +0000 (GMT)
Subject: master - bcache: use flexible arrays
Message-ID: <20201002202753.5BBC6398E493@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b44db5d1a7ecc2e8e3cef0852c4397b64ddf0a09
Commit:        b44db5d1a7ecc2e8e3cef0852c4397b64ddf0a09
Parent:        b3c7a2b3f0bc761a14cfe1c8fc768e265a183204
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 30 23:28:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:00:26 2020 +0200

bcache: use flexible arrays

Cleanup, allocate whole struct with a single malloc call.
---
 lib/device/bcache.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index d1749d9ab..2451eda2b 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -66,23 +66,17 @@ struct control_block {
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
 
@@ -102,7 +96,6 @@ static void _cb_set_destroy(struct cb_set *cbs)
 		return;
 	}
 
-	free(cbs->vec);
 	free(cbs);
 }
 


