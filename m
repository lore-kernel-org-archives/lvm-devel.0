From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Thu, 15 Jun 2017 12:08:57 -0400
Subject: master - test: New test file for validating kernel status during sync ops
Message-ID: <201706151608.v5FG8v9U027525@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3592243afb4bd1b54926b7d8bfef3a0213ca4908
Commit:        3592243afb4bd1b54926b7d8bfef3a0213ca4908
Parent:        6c4b2a6aa16cdb4aff2bd80909dcf43032348a3a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 15 11:06:08 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 15 11:06:08 2017 -0500

test: New test file for validating kernel status during sync ops

First test in this file checks whether 'aa' is ever spotted during
a "recover" operation (it should not be).  More tests should follow
in this file to look for oddities in status output - especially as
it relates to the sync_ratio, dev_health, and sync_action fields.
---
 test/shell/lvconvert-raid-status-validation.sh |   34 ++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
new file mode 100644
index 0000000..0da0b7a
--- /dev/null
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -0,0 +1,34 @@
+#######################################################################
+# This series of tests is meant to validate the correctness of
+# 'dmsetup status' for RAID LVs - especially during various sync action
+# transitions, like: recover, resync, check, repair, idle, reshape, etc
+#######################################################################
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
+
+# check for version 1.9.0
+# - it is the point at which linear->raid1 uses "recover"
+aux have_raid 1 9 0 || skip
+
+aux prepare_pvs 9
+vgcreate -s 2m $vg $(cat DEVICES)
+
+###########################################
+# Upconverted RAID1 should never have all 'a's in status output
+###########################################
+aux delay_dev $dev2 0 100
+lvcreate -aey -l 2 -n $lv1 $vg $dev1
+lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
+while ! check in_sync $vg $lv1; do
+        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+	[ ${a[5]} != "aa" ]
+        sleep .1
+done
+aux enable_dev $dev2
+lvremove -ff $vg
+
+vgremove -ff $vg


