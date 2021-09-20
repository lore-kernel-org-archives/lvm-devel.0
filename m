From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 14:26:33 +0000 (GMT)
Subject: main - tests: len always initialized
Message-ID: <20210920142633.B54A03858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1f33a4000018df57b9af40a4b2a38434ad0079d
Commit:        b1f33a4000018df57b9af40a4b2a38434ad0079d
Parent:        133686ebc79b29316d5f913bcce3fe21bbfea9ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 16:24:08 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 16:24:08 2021 +0200

tests: len always initialized

---
 test/unit/run.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/test/unit/run.c b/test/unit/run.c
index 24624aea9..84b867be5 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -125,8 +125,7 @@ static void _print_path_delta(FILE *stream,
 			fprintf(stream, "\n");
 	}
 
-	if (new_len > 0)
-		len = common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b);
+	len = (new_len > 0) ? common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b) : 0;
 
 	fprintf(stream, "  ");
 	for (d = len; d < 60; d++)


