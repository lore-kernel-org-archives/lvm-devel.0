From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:33 +0000 (UTC)
Subject: master - tests: move conf preparing
Message-ID: <20150501130833.C686E60366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c18e969e30a44ec392f40414e1f134ff70cecb38
Commit:        c18e969e30a44ec392f40414e1f134ff70cecb38
Parent:        0eea780bceccb5e1693429529f292b2fb36afadd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 13:57:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: move conf preparing

If the test in the middle is restarting lvmetad
avoid conf regenerating.
---
 test/lib/aux.sh      |    2 --
 test/lib/inittest.sh |    1 +
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c6b05f8..e20b6b0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -90,8 +90,6 @@ prepare_lvmetad() {
 	if test -z "${installed_testsuite+varset}"; then
 		(which lvmetad 2>/dev/null | grep -q "$abs_builddir") || skip
 	fi
-	lvmconf "global/use_lvmetad = 1" \
-		"devices/md_component_detection = 0"
 
 	local run_valgrind=
 	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index dd4f060..d5c80f4 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -92,6 +92,7 @@ echo "@PREFIX=$PREFIX"
 if test -n "$LVM_TEST_LVMETAD" ; then
 	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
 	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
+	aux lvmconf "global/use_lvmetad = 1" "devices/md_component_detection = 0"
 	aux prepare_lvmetad
 else
 	# lvmetad prepares its own lvmconf


