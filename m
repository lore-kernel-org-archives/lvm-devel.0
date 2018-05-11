From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 11 May 2018 00:41:00 -0400
Subject: master - bcache/sync io engine: handle short ios
Message-ID: <201805110441.w4B4f0kD022232@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f780813f295cd927d92d669ab086063adb1534e
Commit:        5f780813f295cd927d92d669ab086063adb1534e
Parent:        39ce38eb8868e367fa796ddb12b1020647d14c63
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 05:37:47 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 05:37:47 2018 +0100

bcache/sync io engine: handle short ios

---
 lib/device/bcache.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 7a221c5..9085d87 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -283,7 +283,6 @@ struct io_engine *create_async_io_engine(void)
 struct sync_io {
         struct dm_list list;
 	void *context;
-	int err;
 };
 
 struct sync_engine {
@@ -306,30 +305,46 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
                         sector_t sb, sector_t se, void *data, void *context)
 {
         int r;
-        uint64_t len = (se - sb) * 512;
+        uint64_t len = (se - sb) * 512, where;
 	struct sync_engine *e = _to_sync(ioe);
 	struct sync_io *io = malloc(sizeof(*io));
-	if (!io)
+	if (!io) {
+		log_warn("unable to allocate sync_io");
         	return false;
+	}
 
-	r = lseek(fd, sb * 512, SEEK_SET);
-	if (r < 0)
+	where = sb * 512;
+	r = lseek(fd, where, SEEK_SET);
+	if (r < 0) {
+        	log_warn("unable to seek to position %llu", (unsigned long long) where);
         	return false;
+	}
 
-	do {
-        	if (d == DIR_READ)
-                        r = read(fd, data, len);
-                else
-                        r = write(fd, data, len);
+	while (len) {
+        	do {
+                	if (d == DIR_READ)
+                                r = read(fd, data, len);
+                        else
+                                r = write(fd, data, len);
+
+        	} while ((r < 0) && ((r == EINTR) || (r == EAGAIN)));
 
-	} while (r == EINTR || r == EAGAIN);
+        	if (r < 0) {
+                	log_warn("io failed %d", r);
+                	return false;
+        	}
+
+                len -= r;
+	}
+
+	if (len) {
+        	log_warn("short io %u bytes remaining", (unsigned) len);
+        	return false;
+	}
 
-	if (r != len)
-        	r = -EIO;
 
 	dm_list_add(&e->complete, &io->list);
 	io->context = context;
-	io->err = r < 0 ? r : 0;
 
 	return true;
 }
@@ -340,7 +355,7 @@ static bool _sync_wait(struct io_engine *ioe, io_complete_fn fn)
 	struct sync_engine *e = _to_sync(ioe);
 
 	dm_list_iterate_items_safe(io, tmp, &e->complete) {
-		fn(io->context, io->err);
+		fn(io->context, 0);
 		dm_list_del(&io->list);
 		dm_free(io);
 	}


