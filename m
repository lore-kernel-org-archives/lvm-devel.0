From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:52 +0000 (GMT)
Subject: master - bcache: support interrupts when waiting on IO
Message-ID: <20201002202752.37C643945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3c7a2b3f0bc761a14cfe1c8fc768e265a183204
Commit:        b3c7a2b3f0bc761a14cfe1c8fc768e265a183204
Parent:        0fe58fc54fb17707ba5ff04bcf7c8a5174784bec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 17:16:14 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 20:57:50 2020 +0200

bcache: support interrupts when waiting on IO

Since lvm2 normally block signals during protected
phase where it does not want to be interrupted.
Support interruptible processing when allowed
in section between sigint_allow() ... sigint_restore())
and let the 'io_getenvents()'  finish with EINTR.
---
 WHATS_NEW           | 1 +
 lib/device/bcache.c | 4 +---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1d38a7360..a93a61b32 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Support interruption for bcache waiting.
   Fix bcache when device has too many failing writes.
   Fix bcache waiting for IO completion with failing disks.
   Configure use own python path name order to prefer using python3.
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 3fb6a0e80..d1749d9ab 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -325,9 +325,7 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 	struct async_engine *e = _to_async(ioe);
 
 	memset(&event, 0, sizeof(event));
-	do {
-		r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
-	} while (r == -EINTR);
+	r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
 
 	if (r < 0) {
 		log_sys_warn("io_getevents");


