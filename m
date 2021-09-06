From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  6 Sep 2021 13:25:07 +0000 (GMT)
Subject: main - tests: remove all debug logs when using die
Message-ID: <20210906132507.056843858023@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=337053c56a2d288337449067510301d5a2e4eec5
Commit:        337053c56a2d288337449067510301d5a2e4eec5
Parent:        52b56204764e421b693d94fa38834d71e29deced
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 6 14:59:10 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 6 15:01:11 2021 +0200

tests: remove all debug logs when using die

Since die is called from a shell script, there is no need
to report any recent lvm2 command debug traces.
---
 test/lib/utils.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 0e41589bd..1d1ed48bf 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -15,7 +15,7 @@ IFS_NL='
 '
 
 die() {
-	rm -f debug.log
+	rm -f debug.log*
 	echo -e "$@" >&2
 	return 1
 }


