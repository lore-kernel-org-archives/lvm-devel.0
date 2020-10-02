From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:57 +0000 (GMT)
Subject: master - debug: update messages
Message-ID: <20201002202757.E2051398E493@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd8212365df356e561fe72e73be804f7313148c8
Commit:        dd8212365df356e561fe72e73be804f7313148c8
Parent:        e7fff97b8dc4c0a9170bed84388f9ccf55b09169
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 29 23:48:45 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:04:16 2020 +0200

debug: update messages

---
 lib/device/dev-io.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 33b9345ee..4f52954fd 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -106,7 +106,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
 		log_sys_error("ioctl BLKGETSIZE64", name);
 		if (do_close && !dev_close_immediate(dev))
-			log_sys_error("close", name);
+			stack;
 		return 0;
 	}
 
@@ -117,7 +117,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	log_very_verbose("%s: size is %" PRIu64 " sectors", name, *size);
 
 	if (do_close && !dev_close_immediate(dev))
-		log_sys_error("close", name);
+		stack;
 
 	return 1;
 }
@@ -133,7 +133,7 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 
 	if (!dev_open_readonly_quiet(dev)) {
 		log_error("Failed to open to get readahead %s", dev_name(dev));
-		return_0;
+		return 0;
 	}
 
 	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {
@@ -449,7 +449,7 @@ int dev_open_readonly_quiet(struct device *dev)
 static void _close(struct device *dev)
 {
 	if (close(dev->fd))
-		log_sys_error("close", dev_name(dev));
+		log_sys_debug("close", dev_name(dev));
 	dev->fd = -1;
 
 	log_debug_devs("Closed %s", dev_name(dev));


