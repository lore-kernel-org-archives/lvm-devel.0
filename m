From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 Sep 2020 15:31:14 +0000 (GMT)
Subject: master - tests: update integrity-dmeventd
Message-ID: <20200918153114.992293954452@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fbcba1c40eb5256f262e3442ade42e53dcb88d0
Commit:        9fbcba1c40eb5256f262e3442ade42e53dcb88d0
Parent:        94484762022329d7c9ff64841d26ba1cfe46409e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 16:56:00 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:30:45 2020 +0200

tests: update integrity-dmeventd

Use tee.
Switch to more simple generator with awk
(which doesn't produce long debug trace)
Sync before sleep to provoke raid action.
---
 test/shell/integrity-dmeventd.sh | 37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index a8c41803e..043e93371 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -22,10 +22,11 @@ mkdir -p $mnt
 
 aux prepare_devs 6 64
 
-printf "%0.sA" {1..16384} >> fileA
-# instead of long debug 'printf' log use 'sed' and just replace A->B|C
-sed -e 's,A,B,g' fileA > fileB
-sed -e 's,A,C,g' fileA > fileC
+# Use awk instead of anoyingly long log out from printf
+#printf "%0.sA" {1..16384} >> fileA
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
@@ -143,10 +144,10 @@ aux disable_dev "$dev2"
 
 # wait for dmeventd to call lvconvert --repair which should
 # replace dev2 with dev4
+sync
 sleep 5
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev2" out
 grep "$dev4" out
 
@@ -155,8 +156,7 @@ _verify_data_on_mnt
 
 aux enable_dev "$dev2"
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev2" out
 grep "$dev4" out
 grep "$dev1" out
@@ -185,10 +185,10 @@ aux disable_dev "$dev1"
 
 # wait for dmeventd to call lvconvert --repair which should
 # replace dev1 and dev2 with dev4 and dev5
+sync
 sleep 5
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 grep "$dev4" out
@@ -201,8 +201,7 @@ _verify_data_on_mnt
 aux enable_dev "$dev1"
 aux enable_dev "$dev2"
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 grep "$dev4" out
@@ -233,10 +232,10 @@ aux disable_dev "$dev2"
 
 # wait for dmeventd to call lvconvert --repair which should
 # replace dev2 with dev6
+sync
 sleep 5
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev2" out
 grep "$dev6" out
 
@@ -245,8 +244,7 @@ _verify_data_on_mnt
 
 aux enable_dev "$dev2"
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev2" out
 grep "$dev6" out
 
@@ -273,10 +271,10 @@ aux disable_dev "$dev1"
 
 # wait for dmeventd to call lvconvert --repair which should
 # replace dev1 with dev5
+sync
 sleep 5
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev1" out
 grep "$dev5" out
 
@@ -285,8 +283,7 @@ _verify_data_on_mnt
 
 aux enable_dev "$dev1"
 
-lvs -a -o+devices $vg > out
-cat out
+lvs -a -o+devices $vg | tee out
 not grep "$dev1" out
 grep "$dev5" out
 


