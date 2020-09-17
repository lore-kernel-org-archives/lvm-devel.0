From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Sep 2020 21:30:42 +0000 (GMT)
Subject: master - tests: lower memory usage
Message-ID: <20200917213042.F0C53388C02B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f019f2580eadbb7893388e0be0e095753f4a9d6
Commit:        7f019f2580eadbb7893388e0be0e095753f4a9d6
Parent:        72b931d66407fedc68735324996fa190ebaf1a3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 17 23:25:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 17 23:27:45 2020 +0200

tests: lower memory usage

Reduce memory needed by test at one time.
---
 test/shell/integrity.sh | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 95c8557cc..f2acc1ee4 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -24,8 +24,9 @@ mkdir -p $mnt
 aux prepare_devs 5 64
 
 printf "%0.sA" {1..16384} >> fileA
-printf "%0.sB" {1..16384} >> fileB
-printf "%0.sC" {1..16384} >> fileC
+# instead of long debug 'printf' log use 'sed' and just replace A->B|C
+sed -e 's,A,B,g' fileA > fileB
+sed -e 's,A,C,g' fileA > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
@@ -35,11 +36,11 @@ dd if=/dev/urandom of=randC bs=512K count=4
 _prepare_vg() {
 	# zero devs so we are sure to find the correct file data
 	# on the underlying devs when corrupting it
-	dd if=/dev/zero of="$dev1" || true
-	dd if=/dev/zero of="$dev2" || true
-	dd if=/dev/zero of="$dev3" || true
-	dd if=/dev/zero of="$dev4" || true
-	dd if=/dev/zero of="$dev5" || true
+	dd if=/dev/zero of="$dev1" bs=1M || true
+	dd if=/dev/zero of="$dev2" bs=1M || true
+	dd if=/dev/zero of="$dev3" bs=1M || true
+	dd if=/dev/zero of="$dev4" bs=1M || true
+	dd if=/dev/zero of="$dev5" bs=1M || true
 	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 	pvs
 }
@@ -66,10 +67,13 @@ _test_fs_with_error() {
 	# on the last 4096 byte block.
 	xxd "$dev1" > dev1.txt
 	tac dev1.txt > dev1.rev
+	rm -f dev1.txt
 	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
+	rm -f dev1.rev
 	tac dev1.rev.bad > dev1.bad
+	rm -f dev1.rev.bad
 	xxd -r dev1.bad > "$dev1"
-	rm dev1.txt dev1.rev dev1.rev.bad dev1.bad
+	rm -f dev1.bad
 
 	lvchange -ay $vg/$lv1
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt


