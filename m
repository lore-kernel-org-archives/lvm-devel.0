From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:04 -0500
Subject: master - device: Add flag to indicate that a code path can support AIO
Message-ID: <201802090132.w191W4BR027192@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a9af3cd0e609e10840202ae1754ab76b6add511
Commit:        7a9af3cd0e609e10840202ae1754ab76b6add511
Parent:        e869a52cc4e0a65f00c8d3f40cf94b6989e60871
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 22 16:56:25 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Feb 6 01:11:00 2018 +0000

device: Add flag to indicate that a code path can support AIO

Until the whole source supports AIO, library code can check for
AIO_SUPPORTED_CODE_PATH to determine whether or not it is OK
to use AIO.
---
 WHATS_NEW            |    1 +
 lib/cache/lvmcache.c |    2 +-
 lib/device/device.h  |    5 +++++
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 911a6e3..87d7de8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add AIO_SUPPORTED_CODE_PATH to indicate whether AIO may be used.
   Configure ensures /usr/bin dir is checked for dmpd tools.
   Restore pvmove support for wide-clustered active volumes (2.02.177).
   Avoid non-exclusive activation of exclusive segment types.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 65728fd..2eaf479 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1156,7 +1156,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	while ((dev = dev_iter_get(iter))) {
 		nr_labels_outstanding++;
-		if (!label_read_callback(dev, UINT64_C(0), 0, _process_label_data, &nr_labels_outstanding))
+		if (!label_read_callback(dev, UINT64_C(0), AIO_SUPPORTED_CODE_PATH, _process_label_data, &nr_labels_outstanding))
 			nr_labels_outstanding--;
 		dev_count++;
 	}
diff --git a/lib/device/device.h b/lib/device/device.h
index d5b076f..2dea689 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -32,6 +32,11 @@
 #define DEV_ASSUMED_FOR_LV	0x00000200	/* Is device assumed for an LV */
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 
+/* ioflags */
+#define AIO_SUPPORTED_CODE_PATH	0x00000001	/* Set if the code path supports AIO */
+
+#define aio_supported_code_path(ioflags)       (((ioflags) & AIO_SUPPORTED_CODE_PATH) ? 1 : 0)
+
 /*
  * Standard format for callback functions.
  * When provided, callback functions are called exactly once.


