From: David Teigland <teigland@sourceware.org>
Date: Tue, 20 Nov 2018 10:05:59 -0500
Subject: 2018-06-01-stable - bcache: sync io fixes
Message-ID: <201811201505.wAKF5xVM000321@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb5405ded86209979eef54433d0b90942b2f976a
Commit:        cb5405ded86209979eef54433d0b90942b2f976a
Parent:        f8ce9bf3bc38df8f89021517d7967d94ace129df
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 16 13:09:29 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 20 09:04:37 2018 -0600

bcache: sync io fixes

fix lseek error check
fix read/write error checks
handle zero return from read and write
don't return an error for short io
fix partial read/write loop
---
 lib/device/bcache.c |   73 ++++++++++++++++++++++++++++++++++----------------
 1 files changed, 49 insertions(+), 24 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 571ee7a..7384a32 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -328,7 +328,7 @@ struct io_engine *create_async_io_engine(void)
 	e->aio_context = 0;
 	r = io_setup(MAX_IO, &e->aio_context);
 	if (r < 0) {
-		log_warn("io_setup failed");
+		log_debug("io_setup failed %d", r);
 		dm_free(e);
 		return NULL;
 	}
@@ -371,8 +371,11 @@ static void _sync_destroy(struct io_engine *ioe)
 static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
                         sector_t sb, sector_t se, void *data, void *context)
 {
-        int r;
-        uint64_t len = (se - sb) * 512, where;
+	int rv;
+	off_t off;
+	uint64_t where;
+	uint64_t pos = 0;
+	uint64_t len = (se - sb) * 512;
 	struct sync_engine *e = _to_sync(ioe);
 	struct sync_io *io = malloc(sizeof(*io));
 	if (!io) {
@@ -381,11 +384,17 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 	}
 
 	where = sb * 512;
-	r = lseek(fd, where, SEEK_SET);
-	if (r < 0) {
-        	log_warn("unable to seek to position %llu", (unsigned long long) where);
-        	free(io);
-        	return false;
+
+	off = lseek(fd, where, SEEK_SET);
+	if (off == (off_t) -1) {
+		log_warn("Device seek error %d for offset %llu", errno, (unsigned long long)where);
+		free(io);
+		return false;
+	}
+	if (off != (off_t) where) {
+		log_warn("Device seek failed for offset %llu", (unsigned long long)where);
+		free(io);
+		return false;
 	}
 
 	/*
@@ -430,28 +439,44 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 		len = nbytes;
 	}
 
-	while (len) {
-        	do {
-                	if (d == DIR_READ)
-                                r = read(fd, data, len);
-                        else
-                                r = write(fd, data, len);
+	while (pos < len) {
+		if (d == DIR_READ)
+			rv = read(fd, (char *)data + pos, len - pos);
+		else
+			rv = write(fd, (char *)data + pos, len - pos);
 
-        	} while ((r < 0) && ((r == EINTR) || (r == EAGAIN)));
+		if (rv == -1 && errno == EINTR)
+			continue;
+		if (rv == -1 && errno == EAGAIN)
+			continue;
+
+		if (!rv)
+			break;
 
-        	if (r < 0) {
-                	log_warn("io failed %d", r);
+		if (rv < 0) {
+			if (d == DIR_READ)
+				log_debug("Device read error %d offset %llu len %llu", errno,
+					  (unsigned long long)(where + pos),
+					  (unsigned long long)(len - pos));
+			else
+				log_debug("Device write error %d offset %llu len %llu", errno,
+					  (unsigned long long)(where + pos),
+					  (unsigned long long)(len - pos));
                 	free(io);
                 	return false;
-        	}
-
-                len -= r;
+		}
+		pos += rv;
 	}
 
-	if (len) {
-        	log_warn("short io %u bytes remaining", (unsigned) len);
+	if (pos < len) {
+		if (d == DIR_READ)
+			log_warn("Device read short %u bytes remaining", (unsigned)(len - pos));
+		else
+			log_warn("Device write short %u bytes remaining", (unsigned)(len - pos));
+		/*
         	free(io);
         	return false;
+		*/
 	}
 
 


