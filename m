From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:55 +0000 (UTC)
Subject: master - tests: update tests to deal with invisible devices consistently
Message-ID: <20160113134655.BB30260679@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c66a83fdc380f7a4f694481cb3d78d52ce888fa4
Commit:        c66a83fdc380f7a4f694481cb3d78d52ce888fa4
Parent:        84a9f750fe00cd47c4ea5139ed66e0b175b66f00
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 13:55:24 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 13:55:24 2016 +0100

tests: update tests to deal with invisible devices consistently

---
 test/lib/aux.sh                      |    1 +
 test/shell/pvmove-abort.sh           |    4 ++--
 test/shell/pvmove-resume-1.sh        |   20 ++++++++++----------
 test/shell/pvmove-resume-2.sh        |   10 +++++-----
 test/shell/pvmove-resume-multiseg.sh |   18 +++++++++---------
 5 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 216dd19..51dba36 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -880,6 +880,7 @@ log/level = 9
 log/overwrite = 1
 log/syslog = 0
 log/verbose = 0
+report/mark_invisible_devices=0
 EOF
 	}
 
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 336e92a..1fbeb20 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -51,8 +51,8 @@ pvmove --abort "$dev1"
 
 # check if proper pvmove was canceled
 get lv_field $vg name -a | tee out
-not grep "^\[pvmove0\]" out
-grep "^\[pvmove1\]" out
+not grep "^pvmove0" out
+grep "^pvmove1" out
 
 fi
 
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index f4ba5fa..37f2d24 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -88,13 +88,13 @@ test_pvmove_resume() {
 	aux enable_dev "$dev4"
 
 	i=0
-	while get lv_field $vg name -a | grep "^\[pvmove"; do
+	while get lv_field $vg name -a | grep "^pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
 		i=$((i + 1))
 	done
-	while get lv_field $vg1 name -a | grep "^\[pvmove"; do
+	while get lv_field $vg1 name -a | grep "^pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -170,8 +170,8 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg1 name -a | grep "^pvmove0"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -195,8 +195,8 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg1 name -a | grep "^pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b -i0
 }
@@ -215,8 +215,8 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg1 name -a | grep "^pvmove0"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -241,8 +241,8 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg1 name -a | grep "^pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev2"
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index c8643e4..91453e4 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -75,7 +75,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev2"
 
 	i=0
-	while get lv_field $vg name -a | grep "^\[pvmove"; do
+	while get lv_field $vg name -a | grep "^pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -128,7 +128,7 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
 
 	aux enable_dev "$dev2"
 
@@ -148,7 +148,7 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
@@ -166,7 +166,7 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
 
 	aux enable_dev "$dev2"
 
@@ -186,7 +186,7 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 }
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 6982fef..35ee871 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -88,7 +88,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev5"
 
 	i=0
-	while get lv_field $vg name -a | grep "^\[pvmove"; do
+	while get lv_field $vg name -a | grep "^pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -144,8 +144,8 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg name -a | grep "^\[pvmove1\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | grep "^pvmove1"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -169,8 +169,8 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg name -a | grep "^\[pvmove1\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | grep "^pvmove1"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
@@ -189,8 +189,8 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg name -a | grep "^\[pvmove1\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | grep "^pvmove1"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -215,8 +215,8 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | grep "^\[pvmove0\]"
-	get lv_field $vg name -a | grep "^\[pvmove1\]"
+	get lv_field $vg name -a | grep "^pvmove0"
+	get lv_field $vg name -a | grep "^pvmove1"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev3"


