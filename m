From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:25 -0400
Subject: master - tests: add support to run unit test
Message-ID: <201805121626.w4CGQPPD008315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d38a2d64f0cddc951774b63d56b2fb5d9afb336e
Commit:        d38a2d64f0cddc951774b63d56b2fb5d9afb336e
Parent:        7616a7f46ee3de6dfc898b98ed33dbbf9d12cc95
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 18:09:44 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

tests: add support to run unit test

---
 test/lib/aux.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c56767e..977e917 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1351,6 +1351,11 @@ apitest() {
 	"$TESTOLDPWD/api/$1.t" "${@:2}" && rm -f debug.log strace.log
 }
 
+unittest() {
+	test -x "$TESTOLDPWD/unit/unit-test" || skip
+	"$TESTOLDPWD/unit/unit-test" "${@}"
+}
+
 mirror_recovery_works() {
 	case "$(uname -r)" in
 	  3.3.4-5.fc17.i686|3.3.4-5.fc17.x86_64) return 1 ;;


