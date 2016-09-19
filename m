From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:43 +0000 (UTC)
Subject: master - tests: enhance lvchange of thin pool tests
Message-ID: <20160919120143.2BFFE6053F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3b8834724f445706723b1f1b19ec9bde33faa24
Commit:        b3b8834724f445706723b1f1b19ec9bde33faa24
Parent:        1a30adc062b30ef434857eb6d8345d8b66af120a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 19 13:49:32 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

tests: enhance lvchange of thin pool tests

Validate also content of dmtable.
Check operations with unused thin-pool as well.
---
 test/shell/lvchange-thin.sh |   50 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 96c4b30..f2b33b7 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -23,7 +23,40 @@ aux prepare_pvs 3
 vgcreate -s 128k $vg  "$dev1" "$dev2"
 vgcreate -s 128k $vg2 "$dev3"
 
-lvcreate -V10M -L10M -T $vg/pool -n $lv1
+lvcreate -L10M -T $vg/pool
+
+#
+# Check change operations on a thin-pool without any thin LV
+#
+# discards_ARG  (default is passdown)
+check grep_dmsetup status $vg-pool " discard_passdown"
+lvchange -vvvv --discards nopassdown $vg/pool
+check grep_dmsetup table $vg-pool " no_discard_passdown"
+check grep_dmsetup status $vg-pool " no_discard_passdown"
+
+lvchange --discards passdown $vg/pool
+check grep_dmsetup table $vg-pool -v "passdown"
+check grep_dmsetup status $vg-pool " discard_passdown"
+
+# zero_ARG  (default is 'yes')
+check grep_dmsetup table $vg-pool -v "zeroing"
+lvchange --zero n $vg/pool
+check grep_dmsetup table $vg-pool " skip_block_zeroing"
+lvchange --zero y $vg/pool
+check grep_dmsetup table $vg-pool -v "zeroing"
+
+# errorwhenfull_ARG  (default is 'no')
+check grep_dmsetup status $vg-pool "queue_if_no_space"
+lvchange --errorwhenfull y $vg/pool
+check grep_dmsetup status $vg-pool "error_if_no_space"
+check grep_dmsetup table $vg-pool "error_if_no_space"
+lvchange --errorwhenfull n $vg/pool
+check grep_dmsetup status $vg-pool "queue_if_no_space"
+check grep_dmsetup table $vg-pool -v "error_if_no_space"
+
+
+# Attach thin volume
+lvcreate -V10M -n $lv1 $vg/pool
 lvcreate -L10M -n $lv2 $vg
 
 lvchange -an $vg/$lv1
@@ -73,11 +106,26 @@ lvchange --deltag foo $vg/pool
 
 # discards_ARG
 lvchange --discards nopassdown $vg/pool
+check grep_dmsetup table $vg-pool-tpool " no_discard_passdown"
+check grep_dmsetup status $vg-pool-tpool " no_discard_passdown"
 lvchange --discards passdown $vg/pool
+check grep_dmsetup table $vg-pool-tpool -v "passdown"
+check grep_dmsetup status $vg-pool-tpool " discard_passdown"
 
 # zero_ARG
 lvchange --zero n $vg/pool
+check grep_dmsetup table $vg-pool-tpool " skip_block_zeroing"
 lvchange --zero y $vg/pool
+check grep_dmsetup table $vg-pool-tpool -v "zeroing"
+
+
+lvchange --errorwhenfull y $vg/pool
+check grep_dmsetup status $vg-pool-tpool "error_if_no_space"
+check grep_dmsetup table $vg-pool-tpool "error_if_no_space"
+lvchange --errorwhenfull n $vg/pool
+check grep_dmsetup status $vg-pool-tpool "queue_if_no_space"
+check grep_dmsetup table $vg-pool-tpool -v "error_if_no_space"
+
 
 #
 # Test for disallowed metadata changes


