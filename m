From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:04 +0000 (GMT)
Subject: stable-2.02 - bcache: support interrupts when waiting on IO
Message-ID: <20201016191204.B0815396EC99@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=479f0822ad1074cab4bcb1b5404257618cce14b3
Commit:        479f0822ad1074cab4bcb1b5404257618cce14b3
Parent:        5e64aa222b106ef3bd091346ebba807e10dc449e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 17:16:14 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

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
index 2cfb79ba0..dfaec8c53 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Support interruption for bcache waiting.
   Fix bcache when device has too many failing writes.
   Fix bcache waiting for IO completion with failing disks.
   Configure use own python path name order to prefer using python3.
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index e173129fe..f68576a55 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -318,9 +318,7 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 	struct async_engine *e = _to_async(ioe);
 
 	memset(&event, 0, sizeof(event));
-	do {
-		r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
-	} while (r == -EINTR);
+	r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
 
 	if (r < 0) {
 		log_sys_warn("io_getevents");


