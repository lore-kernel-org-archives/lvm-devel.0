From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:27 +0000 (UTC)
Subject: master - tests: skip valgrind testing when assigned to 0
Message-ID: <20140310112727.BA09660F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4eed2c8142dc50e1d359881027aa38a4e4ef2149
Commit:        4eed2c8142dc50e1d359881027aa38a4e4ef2149
Parent:        41e1b12e036ef2079586c4c567eae060c2635062
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 22:53:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

tests: skip valgrind testing when assigned to 0

When LVM_VALGRIND_CLVMD/LVMETAD is set to 0  skip testing.
(Proviosly any value caused to run valgrind testing,
so now '0' skips testing))
---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b2d73a6..1426390 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -39,12 +39,12 @@ prepare_clvmd() {
 
 #	lvmconf "activation/monitoring = 1"
 	local run_valgrind=
-	test -z "$LVM_VALGRIND_CLVMD" || run_valgrind="run_valgrind"
+	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	$run_valgrind lib/clvmd -Isinglenode -d 1 -f &
 	local local_clvmd=$!
 	sleep .3
 	# extra sleep for slow valgrind
-	test -z "$LVM_VALGRIND_CLVMD" || sleep 7
+	test -z "$run_valgrind" || sleep 7
 	# check that it is really running now
 	ps $local_clvmd || die
 	echo $local_clvmd > LOCAL_CLVMD
@@ -77,7 +77,7 @@ prepare_lvmetad() {
 	lvmconf "devices/md_component_detection = 0"
 
 	local run_valgrind=
-	test -z "$LVM_VALGRIND_LVMETAD" || run_valgrind="run_valgrind"
+	test "${LVM_VALGRIND_LVMETAD:-0}" -eq 0 || run_valgrind="run_valgrind"
 
 	echo "preparing lvmetad..."
 	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -l wire,debug &


