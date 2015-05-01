From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 20:50:04 +0000 (UTC)
Subject: master - tests: configure use_lvmetad when needed
Message-ID: <20150501205004.9937B60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abdfb1e75ba372072919ddad0f43f8806412d531
Commit:        abdfb1e75ba372072919ddad0f43f8806412d531
Parent:        6a171bbdf5bc579670b225c291421eb8ee14d2c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 1 22:40:58 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 22:49:38 2015 +0200

tests: configure use_lvmetad when needed

---
 test/lib/aux.sh      |    7 +++++--
 test/lib/inittest.sh |    1 -
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c1889ac..c01fb80 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -94,8 +94,11 @@ prepare_lvmetad() {
 
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
-        # Default debug is "-l all" and could be override
-        # by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
+	# Avoid reconfiguring, if already set to use_lvmetad
+	(grep use_lvmetad CONFIG_VALUES 2>/dev/null | tail -1 | grep -q 1) || \
+		aux lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
+	# Default debug is "-l all" and could be override
+	# by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
 	echo "preparing lvmetad..."
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
 		${LVM_TEST_LVMETAD_DEBUG_OPTS--l all} "$@" &
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 98abae6..b577389 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -92,7 +92,6 @@ echo "@PREFIX=$PREFIX"
 if test -n "$LVM_TEST_LVMETAD" ; then
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
-	aux lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
 	aux prepare_lvmetad
 else
 	# lvmetad prepares its own lvmconf


