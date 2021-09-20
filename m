From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:47 +0000 (GMT)
Subject: main - clang: ensure new_len is at least 1
Message-ID: <20210920132947.4E41F3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=834f17bb3388ffe7f51aeede15d957a63bcda715
Commit:        834f17bb3388ffe7f51aeede15d957a63bcda715
Parent:        0d9f3dbd954b04e08a27154376b60fe9aca23b0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:17:50 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 10:51:30 2021 +0200

clang: ensure new_len is at least 1

---
 test/unit/run.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/unit/run.c b/test/unit/run.c
index 9cbb60506..206857159 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -125,7 +125,9 @@ static void _print_path_delta(FILE *stream,
 			fprintf(stream, "\n");
 	}
 
-	len = common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b);
+	if (new_len > 0)
+		len = common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b);
+
 	fprintf(stream, "  ");
 	for (d = len; d < 60; d++)
 		fprintf(stream, ".");


