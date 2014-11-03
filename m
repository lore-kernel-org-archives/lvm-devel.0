From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:14 +0000 (UTC)
Subject: master - tests: usage of -m0 -Mn
Message-ID: <20141103132414.0566560E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4e96f6b19e2ae7ba8841c1e93ba385cc18ca3c9
Commit:        e4e96f6b19e2ae7ba8841c1e93ba385cc18ca3c9
Parent:        6c32ced6572b857ca954601757268dc4bb688b2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 23:18:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

tests: usage of -m0 -Mn

Test -m0 passed with types.
Check --readahead and thins.
---
 test/shell/lvcreate-thin.sh  |   17 +++++++++++++++++
 test/shell/lvcreate-usage.sh |    2 +-
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 619a40c..733888e 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -200,6 +200,23 @@ not lvcreate --chunksize 256 -l1 -T $vg/pool1
 not lvcreate --chunksize 32 -l1 -T $vg/pool1
 # Too large chunk size (max is 1GB)
 not lvcreate -L4M --chunksize 2G -T $vg/pool1
+# Cannot specify --minor with pool
+fail lvcreate -L10M --minor 100 -T $vg/pool_minor
+
+# FIXME: Currently ambigous - is it for thin, thin-pool, both ?
+fail lvcreate -L4M -Mn -m0 -T --readahead 32 -V20 -n $lv $vg/pool_normal
+
+# Check read-ahead setting will also pass with -Mn -m0
+lvcreate -L4M -Mn -m0 -T --readahead 64k $vg/pool_readahead
+lvcreate -V20M -Mn -m0 -T --readahead 128k -n thin_readahead $vg/pool_readahead
+check lv_field $vg/pool_readahead lv_read_ahead "64.00k"
+check lv_field $vg/thin_readahead lv_read_ahead "128.00k"
+
+if test ! -d /sys/block/dm-2345; then
+# Check some unused minor and support for --minor with thins
+	lvcreate --minor 2345 -T -V20M -n thin_minor $vg/pool_readahead
+	check lv_field $vg/thin_minor lv_minor "2345"
+fi
 
 # Test creation of inactive pool
 lvcreate -an -L4M -T $vg/pool1
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 5d37d9c..fe82005 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -22,7 +22,7 @@ grep "Invalid argument for --type" err
 invalid lvcreate --type $RANDOM -l1 -n $lv1 $vg
 invalid lvcreate --type unknown -l1 -n $lv1 $vg
 
-lvcreate --type linear -aey -l1 -n $lv1 $vg
+lvcreate --type linear -aey -m0 -l1 -n $lv1 $vg
 lvcreate --type snapshot -l1 -n $lv2 $vg/$lv1
 
 # Reject repeated invocation (run 2 times) (bz178216)


