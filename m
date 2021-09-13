From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:20 +0000 (GMT)
Subject: main - gcc: remove invalid attribute
Message-ID: <20210913103620.860373858006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00ec716b4db371f0e28880e95539b10208f19d37
Commit:        00ec716b4db371f0e28880e95539b10208f19d37
Parent:        9ba76450f4a206ee48b0b6e49d35c2c33032bb58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 23:17:29 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

gcc: remove invalid attribute

In this function parameter 'attribute' is used.
---
 lib/cache_segtype/cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 93d4c5283..05de9d5cd 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -335,7 +335,7 @@ static int _lookup_kallsyms(const char *symbol)
 
 static int _target_present(struct cmd_context *cmd,
 			   const struct lv_segment *seg __attribute__((unused)),
-			   unsigned *attributes __attribute__((unused)))
+			   unsigned *attributes)
 {
 	/* List of features with their kernel target version */
 	static const struct feature {


