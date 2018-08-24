From: David Teigland <teigland@sourceware.org>
Date: Fri, 24 Aug 2018 15:51:06 -0400
Subject: 2018-06-01-stable - bcache: reduce MAX_IO to 256
Message-ID: <201808241951.w7OJp6PR005843@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a991664dec02b62681a4a3eea7fbee2fc3a88700
Commit:        a991664dec02b62681a4a3eea7fbee2fc3a88700
Parent:        ab1aa0a4fb9b422b177bba35f1bd96fda2330189
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 24 14:46:51 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 24 14:50:53 2018 -0500

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
index 63ec994..1a00b78 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -4,6 +4,7 @@ Version 2.02.182 -
   Fix lvconvert raid0/raid0_meta -> striped regression.
   Fix lvconvert --splitmirror for mirror type (2.02.178).
   Do not pair cache policy and cache metadata format.
+  Reduce max concurrent aios to avoid EMFILE with many devices.
 
 Version 2.02.181 - 01 August 2018
 =================================
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index b1f7d2a..531d83b 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -196,7 +196,15 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
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


