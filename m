From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:26:37 -0400
Subject: master - tests: aus.sh avoid duplicating arg list
Message-ID: <201707101226.v6ACQbPp021242@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73cb5b486a906779b408b27567d8717617acb3f6
Commit:        73cb5b486a906779b408b27567d8717617acb3f6
Parent:        f612fdd1ddb7b9c3fa837157b3415c6ab5bcfc3b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 10 12:46:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aus.sh avoid duplicating arg list

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a7692cb..6059b6a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -225,7 +225,7 @@ prepare_lvmetad() {
 	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
 	echo -n "## preparing lvmetad..."
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
-		"${LVM_TEST_LVMETAD_DEBUG_OPTS--l all}" "$@" &
+		"${LVM_TEST_LVMETAD_DEBUG_OPTS--l all}" &
 	echo $! > LOCAL_LVMETAD
 	for i in {1..100} ; do
 		test "$i" -eq 100 && die "Startup of lvmetad is too slow."


