From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:52:59 +0000 (UTC)
Subject: master - TEST: Wait for lvmetad socket to appear in "aux prepare_lvmetad".
Message-ID: <20121009055259.ABEB5241E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39468b73a33853c2e532375762a2bbf1e76ea406
Commit:        39468b73a33853c2e532375762a2bbf1e76ea406
Parent:        d5f2e6223f90b56fb173997bc2932bc361f54475
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 20:25:14 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

TEST: Wait for lvmetad socket to appear in "aux prepare_lvmetad".

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d1d5e10..37e7f69 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -79,8 +79,8 @@ prepare_lvmetad() {
 	echo "preparing lvmetad..."
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -d wire,debug &
 	echo $! > LOCAL_LVMETAD
-
-	sleep .3
+	while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
+	echo ok
 }
 
 notify_lvmetad() {


