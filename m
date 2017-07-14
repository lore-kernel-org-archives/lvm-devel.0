From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Jul 2017 14:31:05 -0400
Subject: master - tests: aux.sh fix double quote
Message-ID: <201707141831.v6EIV5vb007912@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac0945bc4a14dfe8def578f9132e7261f254a279
Commit:        ac0945bc4a14dfe8def578f9132e7261f254a279
Parent:        1c95cf8c6f2d024642920c12d91c5de9e31ff7de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 14 20:16:54 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 14 20:29:38 2017 +0200

tests: aux.sh fix double quote

Patch 72a58ce4b0f68f6e45ae30606fe5af21caa42b43 was wronly placing
double quotes around this variable which we want to pass expanded,
as it's just set of 'space' device args ATM.

TODO consider using array[@] to make this cleaner.
Add shellcheck directive to skip warning here
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a0e05ff..9a48689 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -224,8 +224,9 @@ prepare_lvmetad() {
 	# Default debug is "-l all" and could be override
 	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
 	echo -n "## preparing lvmetad..."
+	# shellcheck disable=SC2086
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
-		"${LVM_TEST_LVMETAD_DEBUG_OPTS--l all}" &
+		${LVM_TEST_LVMETAD_DEBUG_OPTS--l all} &
 	echo $! > LOCAL_LVMETAD
 	for i in {1..100} ; do
 		test "$i" -eq 100 && die "Startup of lvmetad is too slow."


