From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:36 -0400
Subject: master - scan: use 128K bcache block size
Message-ID: <201804231354.w3NDsaKM001493@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b504bb809efa8a3a4db0e494bb80d3720d82e6ff
Commit:        b504bb809efa8a3a4db0e494bb80d3720d82e6ff
Parent:        ae093df3f15f6d125bf85ed921e5a971b170dc23
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 15 10:27:43 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: use 128K bcache block size

---
 lib/label/label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index dc14beb..38db733 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -253,7 +253,7 @@ struct label *label_create(struct labeller *labeller)
 /* global variable for accessing the bcache populated by label scan */
 struct bcache *scan_bcache;
 
-#define BCACHE_BLOCK_SIZE_IN_SECTORS 2048 /* 1MB */
+#define BCACHE_BLOCK_SIZE_IN_SECTORS 256 /* 256*512 = 128K */
 
 static bool _in_bcache(struct device *dev)
 {


