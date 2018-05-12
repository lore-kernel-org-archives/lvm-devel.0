From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:13 -0400
Subject: master - tests: aux extra protection for rm -rf
Message-ID: <201805121626.w4CGQDfD007906@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7a23e7dd2f7fde59760a3d3f7c980d7a8f657a7
Commit:        a7a23e7dd2f7fde59760a3d3f7c980d7a8f657a7
Parent:        38b4354494d3e6742d082c82ae7fc957be44e7e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 00:05:27 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:05:50 2018 +0200

tests: aux extra protection for rm -rf

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 877934c..c56767e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -633,7 +633,7 @@ teardown() {
 	test -n "$TESTDIR" && {
 		cd "$TESTOLDPWD" || die "Failed to enter $TESTOLDPWD"
 		# after this delete no further write is possible
-		rm -rf "$TESTDIR" || echo BLA
+		rm -rf "${TESTDIR:?}" || echo BLA
 	}
 
 	echo "ok"


