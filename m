From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 12 May 2016 00:07:06 +0000 (UTC)
Subject: master - device: Retry open without O_NOATIME if it fails.
Message-ID: <20160512000706.9509660DCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5314c2a6ae5fe4f802e82a4f31cf2fad398ded9
Commit:        b5314c2a6ae5fe4f802e82a4f31cf2fad398ded9
Parent:        f3d508630d7acdd638afae700973f1d68e43cbcc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 12 01:05:52 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 12 01:05:52 2016 +0100

device:  Retry open without O_NOATIME if it fails.

---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |   13 ++++++++++++-
 lib/device/device.h |    1 +
 3 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 89fa681..e11a40a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.154 - 
 ===============================
+  Retry open without O_NOATIME if it fails (not file owner/CAP_FOWNER).
 
 Version 2.02.153 - 7th May 2016
 ===============================
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 9bf6d2e..a9a2374 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -494,11 +494,22 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 
 #ifdef O_NOATIME
 	/* Don't update atime on device inodes */
-	if (!(dev->flags & DEV_REGULAR))
+	if (!(dev->flags & DEV_REGULAR) && !(dev->flags & DEV_NOT_O_NOATIME))
 		flags |= O_NOATIME;
 #endif
 
 	if ((dev->fd = open(name, flags, 0777)) < 0) {
+#ifdef O_NOATIME
+		if ((errno == EPERM) && (flags & O_NOATIME)) {
+			flags &= ~O_NOATIME;
+			dev->flags |= DEV_NOT_O_NOATIME;
+			if ((dev->fd = open(name, flags, 0777)) >= 0) {
+				log_debug_devs("%s: Not using O_NOATIME", name);
+				goto opened;
+			}
+		}
+#endif
+
 #ifdef O_DIRECT_SUPPORT
 		if (direct && !(dev->flags & DEV_O_DIRECT_TESTED)) {
 			flags &= ~O_DIRECT;
diff --git a/lib/device/device.h b/lib/device/device.h
index aaa009f..fa03f10 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -30,6 +30,7 @@
 #define DEV_OPEN_FAILURE	0x00000080	/* Has last open failed? */
 #define DEV_USED_FOR_LV		0x00000100	/* Is device used for an LV */
 #define DEV_ASSUMED_FOR_LV	0x00000200	/* Is device assumed for an LV */
+#define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 
 /*
  * Support for external device info.


