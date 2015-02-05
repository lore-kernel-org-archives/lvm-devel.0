From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:11 +0000 (UTC)
Subject: master - test: Disable lvmetad logging in lvconvert-{mirror, raid}*.
Message-ID: <20150205134211.896776036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0d314bd6dcf22cee8e18c6e21fa06829a0f01ac
Commit:        f0d314bd6dcf22cee8e18c6e21fa06829a0f01ac
Parent:        fa2e84caa80053dbc5a8b42d2d3e2e1492736243
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 21 21:44:53 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

test: Disable lvmetad logging in lvconvert-{mirror,raid}*.

---
 test/lib/aux.sh                      |    5 ++++-
 test/shell/lvconvert-mirror-basic.sh |    2 ++
 test/shell/lvconvert-mirror.sh       |    3 +++
 test/shell/lvconvert-raid.sh         |    3 +++
 4 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9def304..84edb7d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -80,6 +80,7 @@ prepare_dmeventd() {
 }
 
 prepare_lvmetad() {
+	test $# -eq 0 && default_opts="-l wire,debug"
 	rm -f debug.log
 	# skip if we don't have our own lvmetad...
 	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip
@@ -90,8 +91,10 @@ prepare_lvmetad() {
 	local run_valgrind=
 	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
+	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
+
 	echo "preparing lvmetad..."
-	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -l wire,debug &
+	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" $default_opts "$@" &
 	echo $! > LOCAL_LVMETAD
 	while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
 	echo ok
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 07bafb9..ce5b344 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -110,6 +110,8 @@ test_lvconvert() {
 	fi
 }
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
 
 aux prepare_pvs 5 5
 vgcreate -s 32k $vg $(cat DEVICES)
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index d8f057a..6ba2ab2 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -11,6 +11,9 @@
 
 . lib/inittest
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+
 aux prepare_pvs 5 10
 # proper DEVRANGE needs to be set according to extent size
 DEVRANGE="0-32"
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 12e0420..34c94bf 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -11,6 +11,9 @@
 
 . lib/inittest
 
+# disable lvmetad logging as it bogs down test systems
+test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+
 get_image_pvs() {
 	local d
 	local images


