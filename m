From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:37:10 -0400
Subject: master - bcache: increase max allowed bcache size
Message-ID: <201908161837.x7GIbAia006816@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61fce72a114d23b98bfd4a9d457e3d55297455ef
Commit:        61fce72a114d23b98bfd4a9d457e3d55297455ef
Parent:        987f2733c76cff60eaf71b01f33ec8126121d792
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 16 13:35:09 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:35:09 2019 -0500

bcache: increase max allowed bcache size

from 128MB to 512MB (the default remains 8MB)
---
 lib/label/label.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 3c8e10c..e786c89 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -808,8 +808,8 @@ out:
  * the metadata size.)
  */
 
-#define MIN_BCACHE_BLOCKS 32    /* 4MB */
-#define MAX_BCACHE_BLOCKS 1024
+#define MIN_BCACHE_BLOCKS 32    /* 4MB (32 * 128KB) */
+#define MAX_BCACHE_BLOCKS 4096  /* 512MB (4096 * 128KB) */
 
 static int _setup_bcache(void)
 {


