From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:17 -0400
Subject: master - tests: aux.sh replace sed call
Message-ID: <201707101233.v6ACXH4j022761@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84e83ac37e652baa686648f1bfb4215e2c0dd206
Commit:        84e83ac37e652baa686648f1bfb4215e2c0dd206
Parent:        928a49a7c8f78dff4add340107ecc46e6a1b8587
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:11:46 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh replace sed call

Use internal shell vars manips
---
 test/lib/aux.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6ac57d4..e31c4d7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -960,8 +960,7 @@ disable_dev() {
 	done
 
 	test -n "$silent" || for num in $notify; do
-		notify_lvmetad --major "$(echo "$num" | sed -e "s,:.*,,")" \
-		               --minor "$(echo "$num" | sed -e "s,.*:,,")"
+		notify_lvmetad --major "${num%%:*}" --minor "${num##*:}"
 	done
 }
 


