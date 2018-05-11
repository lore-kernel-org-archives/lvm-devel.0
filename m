From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 12:36:32 -0400
Subject: master - bcache: disable fallback to old io
Message-ID: <201805111636.w4BGaW20029197@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43620138726da124f5eb58c9347cba8b582271ed
Commit:        43620138726da124f5eb58c9347cba8b582271ed
Parent:        228ed56455b9510ed7943997987ae28459efc1b4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 09:50:25 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 11:35:56 2018 -0500

bcache: disable fallback to old io

All io has been converted to bcache.
---
 lib/label/label.c |   28 ++++++++--------------------
 1 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index f5f30c6..45acd73 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -978,15 +978,9 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	int ret;
 
 	if (!scan_bcache) {
-		if (!dev_open_readonly(dev))
-			return false;
-
-		ret = dev_read(dev, start, len, 0, data);
-
-		if (!dev_close(dev))
-			stack;
-
-		return ret ? true : false;
+		/* Should not happen */
+		log_error("dev_read bcache not set up %s", dev_name(dev));
+		return false;
 	}
 
 	if (dev->bcache_fd <= 0) {
@@ -1015,15 +1009,9 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		return true;
 
 	if (!scan_bcache) {
-		if (!dev_open(dev))
-			return false;
-
-		ret = dev_write(dev, start, len, 0, data);
-
-		if (!dev_close(dev))
-			stack;
-
-		return ret ? true : false;
+		/* Should not happen */
+		log_error("dev_write bcache not set up %s", dev_name(dev));
+		return false;
 	}
 
 	if (dev->bcache_fd <= 0) {
@@ -1056,7 +1044,7 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 		return true;
 
 	if (!scan_bcache) {
-		log_error("dev_write_zeros %s bcache not set up", dev_name(dev));
+		log_error("dev_write_zeros bcache not set up %s", dev_name(dev));
 		return false;
 	}
 
@@ -1090,7 +1078,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 		return true;
 
 	if (!scan_bcache) {
-		log_error("dev_set_bytes %s bcache not set up", dev_name(dev));
+		log_error("dev_set_bytes bcache not set up %s", dev_name(dev));
 		return false;
 	}
 


