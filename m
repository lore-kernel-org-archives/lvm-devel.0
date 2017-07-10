From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:31 -0400
Subject: master - tests: aux.sh check cd result
Message-ID: <201707101232.v6ACWVXu022595@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6be61bf04408855da89f2117d268f1dbe1b98279
Commit:        6be61bf04408855da89f2117d268f1dbe1b98279
Parent:        c87e1afa0327c60621075f581bffb30b33735442
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 1 09:27:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh check cd result

Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2eeb67f..c5944c2 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -585,7 +585,7 @@ teardown() {
 	}
 
 	test -n "$TESTDIR" && {
-		cd "$TESTOLDPWD"
+		cd "$TESTOLDPWD" || die "Failed to enter $TESTOLDPWD"
 		rm -rf "$TESTDIR" || echo BLA
 	}
 


