From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 14 Jun 2023 11:26:10 +0000 (GMT)
Subject: main - tests: tmp is used for TMPDIR
Message-ID: <20230614112610.B94853858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4cf005d3959fdee5f78948164f22a0f0aff25173
Commit:        4cf005d3959fdee5f78948164f22a0f0aff25173
Parent:        7ac5dbfd09e771f087a9467aca8a0d5905084459
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jun 14 13:23:41 2023 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jun 14 13:23:41 2023 +0200

tests:  tmp is used for TMPDIR

Fixes tests failing due to previous commit 734d9791f817.
---
 test/shell/pvck-dump.sh           | 4 ++--
 test/shell/pvscan-autoactivate.sh | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 81e164d73..76da38d3e 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -100,8 +100,8 @@ grep "zero metadata copies" m4
 diff m1 m2
 diff m1 m3
 
-not diff m1 m3b > tmp
-grep "metadata text at" tmp
+not diff m1 m3b > out
+grep "metadata text at" out
 
 lvcreate -an -l1 $vg
 
diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 297ceb96d..f57473104 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -169,9 +169,9 @@ _clear_online_files
 
 pvscan --cache -aay "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
-lvs --foreign $vg2 > tmp
-cat tmp
-grep $lv2 tmp
+lvs --foreign $vg2 > out
+cat out
+grep $lv2 out
 check lv_field $vg2/$lv2 lv_active "" --foreign
 
 fi

