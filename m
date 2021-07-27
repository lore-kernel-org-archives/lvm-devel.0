From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:28 +0000 (GMT)
Subject: main - pvck: ensure buffer is 0 terminated
Message-ID: <20210727225028.72990383B82C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=308c6f31c3d79b370b163660f3ec38042a00289f
Commit:        308c6f31c3d79b370b163660f3ec38042a00289f
Parent:        01081b21006abe4d9a0102541982cb0fcaeb22dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 15:12:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:22 2021 +0200

pvck: ensure buffer is 0 terminated

Since readed metadata buffer is passed to printf(),
ensure the buffer is '\0' terminated.
---
 tools/pvck.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index d81966966..b15158746 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -898,7 +898,7 @@ static int _dump_current_text(struct device *dev, struct devicefile *def,
 	int ri = rlocn_index; /* 0 or 1 */
 	int bad = 0;
 
-	if (!(meta_buf = zalloc(meta_size))) {
+	if (!(meta_buf = zalloc(meta_size + 1))) {
 		log_print("CHECK: mda_header_%d.raw_locn[%d] no mem for metadata text size %llu", mn, ri,
 			  (unsigned long long)meta_size);
 		return 0;


