From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 18 Jul 2017 15:25:38 -0400
Subject: master - tests: avoid endless loops
Message-ID: <201707181925.v6IJPcPA005529@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=466da710e03149187c05dcfd598aa66c32158496
Commit:        466da710e03149187c05dcfd598aa66c32158496
Parent:        9599645bb6a295aafd6cdf6f793fc9068c5d437f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 18 21:17:51 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 18 21:17:51 2017 +0200

tests: avoid endless loops

If there is some problem with device removal avoid generating very long
error logs...
---
 test/shell/pvmove-resume-1.sh |   15 +++++++++++----
 test/shell/pvmove-resume-2.sh |   16 ++++++++++++----
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index ff10199..ddebcb9 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -54,10 +54,17 @@ test_pvmove_resume() {
 
 	wait
 
-	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
-	while dmsetup status "$vg1-$lv1"; do dmsetup remove "$vg1-$lv1" || true; done
-	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
-	while dmsetup status "$vg1-pvmove0"; do dmsetup remove "$vg1-pvmove0" || true; done
+	local finished
+	for i in {1..100}; do
+		finished=1
+		for d in  "$vg-$lv1" "$vg1-$lv1" "$vg-pvmove0" "$vg1-pvmove0" ; do
+			dmsetup status "$d" 2>/dev/null && {
+				dmsetup remove "$d" || finished=0
+			}
+		done
+		test "$finished" -eq 0 || break
+	done
+	test "$finished" -eq 0 && die "Can't remove device"
 
 	check lv_attr_bit type $vg/pvmove0 "p"
 	check lv_attr_bit type $vg1/pvmove0 "p"
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 50c4233..5e9ad81 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -44,9 +44,17 @@ test_pvmove_resume() {
 
 	wait
 
-	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
-	while dmsetup status "$vg-$lv2"; do dmsetup remove "$vg-$lv2" || true; done
-	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
+	local finished
+	for i in {1..100}; do
+		finished=1
+		for d in  "$vg-$lv1" "$vg-$lv2" "$vg-pvmove0" ; do
+			dmsetup status "$d" 2>/dev/null && {
+				dmsetup remove "$d" || finished=0
+			}
+		done
+		test "$finished" -eq 0 || break
+	done
+	test "$finished" -eq 0 && die "Can't remove device"
 
 	check lv_attr_bit type $vg/pvmove0 "p"
 
@@ -59,7 +67,7 @@ test_pvmove_resume() {
 		# errors, based on the fact pvmove is killed -9
 		# Restart clvmd
 		kill "$(< LOCAL_CLVMD)"
-		for i in $(seq 1 100) ; do
+		for i in {1 100} ; do
 			test $i -eq 100 && die "Shutdown of clvmd is too slow."
 			test -e "$CLVMD_PIDFILE" || break
 			sleep .1


