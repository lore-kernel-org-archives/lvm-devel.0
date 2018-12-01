From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:08:11 -0500
Subject: master - gcc: ensure sector is initilized
Message-ID: <201812010008.wB108B7J031246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a5e3bcf153eddc6a03554e26f6f8d795fead96e
Commit:        5a5e3bcf153eddc6a03554e26f6f8d795fead96e
Parent:        d8ad73e9377adea67819db083d66debc39dec993
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 22:26:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:07:01 2018 +0100

gcc: ensure sector is initilized

Some older gcc errnously report the variable can be used uninitlized.
Quite warning by explicit initalization.
---
 lib/label/label.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 82ebd71..1fb374e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -356,7 +356,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label *label = NULL;
 	struct labeller *labeller;
-	uint64_t sector;
+	uint64_t sector = 0;
 	int ret = 0;
 	int pass;
 


