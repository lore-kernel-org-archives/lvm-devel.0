From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:17 -0400
Subject: stable-2.02 - gcc: clean uninitialized var warning
Message-ID: <201907052326.x65NQHPf009705@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0e1019add988b91fb41355566a34a3b2e182569
Commit:        b0e1019add988b91fb41355566a34a3b2e182569
Parent:        9aedf68c32f5ba7217b37e466546b5abb4f33f76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 22:49:24 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

gcc: clean uninitialized var warning

Some older gcc versions shows this (FP) warning:
label/label.c:360: warning: ?????sector???????? may be used uninitialized in this function
---
 lib/label/label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index d6212b1..a535bd4 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -357,7 +357,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label *label = NULL;
 	struct labeller *labeller;
-	uint64_t sector;
+	uint64_t sector = 0;
 	int ret = 0;
 	int pass;
 


