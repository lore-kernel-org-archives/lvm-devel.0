From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:06 +0000 (GMT)
Subject: master - config: drop reading file with mmap
Message-ID: <20200828195906.3F58A394848E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3e04b99f21428d6392d5a430c7b7a321dbd4ed1
Commit:        e3e04b99f21428d6392d5a430c7b7a321dbd4ed1
Parent:        9a88a9c4ce8fc930328e8d7d56fae8e964f8df02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 27 12:49:03 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

config: drop reading file with mmap

While normally the 'mmap' file reading is better utilizing resources,
it has also its odd side with handling errors - so while we normally
use the mmap only for reading regular files from root filesystem
(i.e. lvm.conf) we can't prevent error to happen during the read
of these file - and such error unfortunately ends with SIGBUS error.
Maintaing signal handler would be compilated - so switch to slightly
less effiecient but more error resistant read() functinality.
---
 lib/config/config.c | 54 ++++++++++++++++++++++++-----------------------------
 1 file changed, 24 insertions(+), 30 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index b3e230d19..a25b7db6e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -503,10 +503,10 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 {
 	char *fb, *fe;
 	int r = 0;
-	int use_mmap = 1;
-	off_t mmap_offset = 0;
+	int sz, use_plain_read = 1;
 	char *buf = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
+	size_t rsize;
 
 	if (!_is_file_based_config_source(cs->type)) {
 		log_error(INTERNAL_ERROR "config_file_read_fd: expected file, special file "
@@ -515,26 +515,28 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		return 0;
 	}
 
-	/* Only use mmap with regular files */
+	/* Only use plain read with regular files */
 	if (!(dev->flags & DEV_REGULAR) || size2)
-		use_mmap = 0;
-
-	if (use_mmap) {
-		mmap_offset = offset % lvm_getpagesize();
-		/* memory map the file */
-		fb = mmap((caddr_t) 0, size + mmap_offset, PROT_READ,
-			  MAP_PRIVATE, dev_fd(dev), offset - mmap_offset);
-		if (fb == (caddr_t) (-1)) {
-			log_sys_error("mmap", dev_name(dev));
-			goto out;
+		use_plain_read = 0;
+
+	if (!(buf = malloc(size + size2))) {
+		log_error("Failed to allocate circular buffer.");
+		return 0;
+	}
+
+	if (use_plain_read) {
+		/* Note: also used for lvm.conf to read all settings */
+		for (rsize = 0; rsize < size; rsize += sz) {
+			do {
+				sz = read(dev_fd(dev), buf + rsize, size - rsize);
+			} while ((sz < 0) && ((errno == EINTR) || (errno == EAGAIN)));
+
+			if (sz < 0) {
+				log_sys_error("read", dev_name(dev));
+				goto out;
+			}
 		}
-		fb = fb + mmap_offset;
 	} else {
-		if (!(buf = malloc(size + size2))) {
-			log_error("Failed to allocate circular buffer.");
-			return 0;
-		}
-
 		if (!dev_read_bytes(dev, offset, size, buf))
 			goto out;
 
@@ -542,10 +544,10 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 			if (!dev_read_bytes(dev, offset2, size2, buf + size))
 				goto out;
 		}
-
-		fb = buf;
 	}
 
+	fb = buf;
+
 	/*
 	 * The checksum passed in is the checksum from the mda_header
 	 * preceding this metadata.  They should always match.
@@ -573,15 +575,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 	r = 1;
 
       out:
-	if (!use_mmap)
-		free(buf);
-	else {
-		/* unmap the file */
-		if (munmap(fb - mmap_offset, size + mmap_offset)) {
-			log_sys_error("munmap", dev_name(dev));
-			r = 0;
-		}
-	}
+	free(buf);
 
 	return r;
 }


