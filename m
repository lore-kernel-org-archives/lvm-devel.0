From: David Teigland <teigland@sourceware.org>
Date: Mon, 7 Aug 2017 17:54:12 -0400
Subject: dev-dct-label-scan-10 - scanning: allocate label data struct from mem pool
Message-ID: <201708072154.v77LsCqD004322@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e30e59ddb4a7723e5c9350137cd80a5b548e46d2
Commit:        e30e59ddb4a7723e5c9350137cd80a5b548e46d2
Parent:        70f2ad21bae8a18cfd87cb50d05828b4b064c4d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 7 16:52:14 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 7 16:52:14 2017 -0500

scanning: allocate label data struct from mem pool

Use a separate alloc/free loop for ld structs from
mem pool vs the aio-related structs that are not
from pool.
---
 lib/label/label.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index e5c0b78..05ef4f5 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -447,12 +447,15 @@ static void _free_label_read_list(int do_close)
 {
 	struct label_read_data *ld, *ld2;
 
-	dm_list_iterate_items_safe(ld, ld2, &label_read_list) {
-		dm_list_del(&ld->list);
+	dm_list_iterate_items(ld, &label_read_list) {
 		if (do_close)
 			dev_close(ld->dev);
 		if (ld->aio)
 			dev_async_io_destroy(ld->aio);
+	}
+
+	dm_list_iterate_items_safe(ld, ld2, &label_read_list) {
+		dm_list_del(&ld->list);
 		free(ld);
 	}
 }
@@ -645,23 +648,25 @@ int label_scan_async(struct cmd_context *cmd)
 		 * of the posix_memalign below.  Try using mem pool to allocate
 		 * all the ld structs first, then allocate all aio and aio->buf.
 		 */
-		if (!(ld = malloc(sizeof(*ld))))
+		if (!(ld = dm_malloc(sizeof(*ld))))
 			goto_bad;
 
 		memset(ld, 0, sizeof(*ld));
 
-		if (!(ld->aio = dev_async_io_alloc(buf_len)))
-			goto_bad;
-
 		ld->dev = dev;
-		ld->buf = ld->aio->buf;
-		ld->buf_len = buf_len;
-
 		dm_list_add(&label_read_list, &ld->list);
 		dev_count++;
 	};
 	dev_iter_destroy(iter);
 
+	dm_list_iterate_items(ld, &label_read_list) {
+		if (!(ld->aio = dev_async_io_alloc(buf_len)))
+			goto_bad;
+
+		ld->buf = ld->aio->buf;
+		ld->buf_len = buf_len;
+	}
+
 	/*
 	 * Start the aio reads on each dev.  Flag any that
 	 * fail and the next loop will try a sync read for it.
@@ -748,12 +753,16 @@ bad:
 	dev_iter_destroy(iter);
 	dev_async_context_destroy(ac);
 
-	dm_list_iterate_items_safe(ld, ld2, &label_read_list) {
-		dm_list_del(&ld->list);
+	dm_list_iterate_items(ld, &label_read_list) {
 		dev_close(ld->dev);
 		dev_async_io_destroy(ld->aio);
-		free(ld);
 	}
+
+	dm_list_iterate_items_safe(ld, ld2, &label_read_list) {
+		dm_list_del(&ld->list);
+		dm_free(ld);
+	}
+
 	return 0;
 }
 


