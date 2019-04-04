From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 4 Apr 2019 04:19:57 -0400
Subject: stable-2.02 - bcache: Fix memory leak
Message-ID: <201904040819.x348Jv0C024817@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b79f1e176f013167ca9798efb55eaf048d64e042
Commit:        b79f1e176f013167ca9798efb55eaf048d64e042
Parent:        81d954df4ed844600c44b99ee68453e1e53fcf31
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Apr 4 10:18:07 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Apr 4 10:19:15 2019 +0200

bcache: Fix memory leak

---
 lib/device/bcache.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 7384a32..f64931f 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -411,6 +411,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 				  (unsigned long long)offset,
 				  (unsigned long long)nbytes,
 				  (unsigned long long)_last_byte_offset);
+			free(io);
 			return false;
 		}
 


