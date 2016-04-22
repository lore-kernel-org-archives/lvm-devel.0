From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 10:54:40 +0000 (UTC)
Subject: master - tests: make test independent on usage [] for hidden LVs
Message-ID: <20160422105440.C379761B98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2dc6b9785658d7bf0cf97170e8e1467b522bded6
Commit:        2dc6b9785658d7bf0cf97170e8e1467b522bded6
Parent:        4ddf5a11cf333fdcf45eec907e12e10c41a9d578
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 12:51:54 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 12:53:09 2016 +0200

tests: make test independent on usage [] for hidden LVs

---
 test/shell/mirror-names.sh           |    6 +++---
 test/shell/pvmove-abort.sh           |    4 ++--
 test/shell/pvmove-resume-1.sh        |   20 ++++++++++----------
 test/shell/pvmove-resume-2.sh        |    8 ++++----
 test/shell/pvmove-resume-multiseg.sh |   22 ++++++++++++----------
 5 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 9c2868a..789cbfc 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -37,11 +37,11 @@ lv_devices_() {
 }
 
 lv_mirror_log_() {
-	test $(get lv_field $1 mirror_log) = $2
+	get lv_field $1 mirror_log | tr -d []
 }
 
 lv_convert_lv_() {
-	get lv_field $1 convert_lv
+	get lv_field $1 convert_lv | tr -d []
 }
 
 enable_devs() {
@@ -87,7 +87,7 @@ lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg
 lv_devices_ $vg/$lv1 ${lv1}_mimage_0 ${lv1}_mimage_1
 
 #COMM "mirror log is ${lv1}_mlog"
-lv_mirror_log_ $vg/$lv1 ${lv1}_mlog
+test $(lv_mirror_log_ $vg/$lv1) = ${lv1}_mlog
 
 # "cleanup"
 check_and_cleanup_lvs_
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index b7e3105..09a6af2 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -53,8 +53,8 @@ pvmove --abort "$dev1"
 
 # check if proper pvmove was canceled
 get lv_field $vg name -a | tee out
-not grep "^pvmove0" out
-grep "^pvmove1" out
+not egrep "^\[?pvmove0" out
+egrep "^\[?pvmove1" out
 
 fi
 
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 8e4b6a7..5167da5 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -89,13 +89,13 @@ test_pvmove_resume() {
 	aux enable_dev "$dev4"
 
 	i=0
-	while get lv_field $vg name -a | grep "^pvmove"; do
+	while get lv_field $vg name -a | egrep "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
 		i=$((i + 1))
 	done
-	while get lv_field $vg1 name -a | grep "^pvmove"; do
+	while get lv_field $vg1 name -a | egrep "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -171,8 +171,8 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg1 name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -196,8 +196,8 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg1 name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b -i0
 }
@@ -216,8 +216,8 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg1 name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -242,8 +242,8 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg1 name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev2"
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 374f4ff..3baa6df 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -129,7 +129,7 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
 
 	aux enable_dev "$dev2"
 
@@ -149,7 +149,7 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
@@ -167,7 +167,7 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
 
 	aux enable_dev "$dev2"
 
@@ -187,7 +187,7 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 }
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 3898f5b..b06400c 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -15,7 +15,7 @@
 # Multisegment variant w/ 2 pvmoves LVs per VG
 
 SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_CLVMD=1
+#SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
@@ -89,7 +89,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev5"
 
 	i=0
-	while get lv_field $vg name -a | grep "^pvmove"; do
+	while get lv_field $vg name -a | grep "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -99,6 +99,8 @@ test_pvmove_resume() {
 	aux kill_tagged_processes
 
 	lvremove -ff $vg
+	# drop debug logs from killed lvm2 commands
+	rm -f debug.log_DEBUG*
 }
 
 lvchange_single() {
@@ -145,8 +147,8 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg name -a | grep "^pvmove1"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove1"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -170,8 +172,8 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg name -a | grep "^pvmove1"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove1"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
@@ -190,8 +192,8 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg name -a | grep "^pvmove1"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove1"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -216,8 +218,8 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^pvmove0"
-	get lv_field $vg name -a | grep "^pvmove1"
+	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | egrep "^\[?pvmove1"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev3"


