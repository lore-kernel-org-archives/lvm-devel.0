From: David Teigland <teigland@sourceware.org>
Date: Fri, 24 Aug 2018 15:55:35 -0400
Subject: master - bcache: reduce MAX_IO to 256
Message-ID: <201808241955.w7OJtZR2006274@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fade9ca3b6ee1432ae8c2878815bbf871cacf92d
Commit:        fade9ca3b6ee1432ae8c2878815bbf871cacf92d
Parent:        3c966e637fe1bec587ceb9ad13aa009db64b4f8e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 24 14:46:51 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 24 14:55:12 2018 -0500

bcache: reduce MAX_IO to 256

This is the number of concurrent async io requests that
the scan layer will submit to the bcache layer.  There
will be an open fd for each of these, so it is best to
keep this well below the default limit for max open files
(1024), otherwise lvm may get EMFILE from open(2) when
there are around 1024 devices to scan on the system.
---
 WHATS_NEW           |    1 +
 lib/device/bcache.c |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fd1b732..bf03c49 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Reduce max concurrent aios to avoid EMFILE with many devices.
   Fix lvconvert conversion attempts to linear.
   Fix lvconvert raid0/raid0_meta -> striped regression.
   Fix lvconvert --splitmirror for mirror type (2.02.178).
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 8d55c36..e759997 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -198,7 +198,15 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	return true;
 }
 
-#define MAX_IO 1024
+/*
+ * MAX_IO is returned to the layer above via bcache_max_prefetches() which
+ * tells the caller how many devices to submit io for concurrently.  There will
+ * be an open file descriptor for each of these, so keep it low enough to avoid
+ * reaching the default max open file limit (1024) when there are over 1024
+ * devices being scanned.
+ */
+
+#define MAX_IO 256
 #define MAX_EVENT 64
 
 static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)


