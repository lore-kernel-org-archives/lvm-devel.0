From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 15:01:04 +0000 (UTC)
Subject: master - tests: split bigger test
Message-ID: <20150402150104.E8B5760960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=196602524515756b2ac504937ec6d61d22ba49ed
Commit:        196602524515756b2ac504937ec6d61d22ba49ed
Parent:        a16324b0d3ee2e3166ca0a9b5c87b5a68e756a68
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 16:01:01 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 16:01:01 2015 +0200

tests: split bigger test

Use separate new test and avoid teardown_devs
in the middle of single test.
---
 test/shell/lvcreate-thin-big.sh |   63 +++++++++++++++++++++++++++++++++++++++
 test/shell/lvcreate-thin.sh     |   46 ----------------------------
 2 files changed, 63 insertions(+), 46 deletions(-)

diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
new file mode 100644
index 0000000..1a8fa30
--- /dev/null
+++ b/test/shell/lvcreate-thin-big.sh
@@ -0,0 +1,63 @@
+#!/bin/sh
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# test currently needs to drop
+# 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+
+# Test --poolmetadatasize range
+# allocating large devices for testing
+aux prepare_pvs 10 16500
+vgcreate $vg -s 64K $(cat DEVICES)
+
+# Size 0 is not valid
+invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
+lvcreate -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>out
+grep "WARNING: Minimum" out
+# FIXME: metadata allocation fails, if PV doesn't have at least 16GB
+# i.e. pool metadata device cannot be multisegment
+lvcreate -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
+grep "WARNING: Maximum" out
+check lv_field $vg/pool1_tmeta size "2.00m"
+check lv_field $vg/pool2_tmeta size "16.00g"
+lvremove -ff $vg
+
+# Test automatic calculation of pool metadata size
+lvcreate -L160G -T $vg/pool
+check lv_field $vg/pool lv_metadata_size "80.00m"
+check lv_field $vg/pool chunksize        "128.00k"
+lvremove -ff $vg/pool
+
+lvcreate -L10G --chunksize 256 -T $vg/pool1
+lvcreate -L60G --chunksize 1024 -T $vg/pool2
+check lv_field $vg/pool1_tmeta size "2.50m"
+check lv_field $vg/pool2_tmeta size "3.75m"
+lvremove -ff $vg
+
+# Block size of multiple 64KB needs >= 1.4
+if aux have_thin 1 4 0 ; then
+# Test chunk size is rounded to 64KB boundary
+lvcreate -L10G --poolmetadatasize 4M -T $vg/pool
+check lv_field $vg/pool chunk_size "192.00k"
+fi
+# Old thinpool target required rounding to power of 2
+aux lvmconf "global/thin_disabled_features = [ \"block_size\" ]"
+lvcreate -L10G --poolmetadatasize 4M -T $vg/pool_old
+check lv_field $vg/pool_old chunk_size "256.00k"
+lvremove -ff $vg
+# reset
+#aux lvmconf "global/thin_disabled_features = []"
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 2884d53..66d986b 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -232,49 +232,3 @@ not lvcreate -T mirpool -L4M --alloc anywhere -m1 $vg
 not lvcreate --thinpool mirpool -L4M --alloc anywhere -m1 $vg
 
 vgremove -ff $vg
-
-# Test --poolmetadatasize range
-# allocating large devices for testing
-aux teardown_devs
-aux prepare_pvs 10 16500
-vgcreate $vg -s 64K $(cat DEVICES)
-
-# Size 0 is not valid
-invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
-lvcreate -L4M --chunksize 128 --poolmetadatasize 16k -T $vg/pool1 2>out
-grep "WARNING: Minimum" out
-# FIXME: metadata allocation fails, if PV doesn't have at least 16GB
-# i.e. pool metadata device cannot be multisegment
-lvcreate -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
-grep "WARNING: Maximum" out
-check lv_field $vg/pool1_tmeta size "2.00m"
-check lv_field $vg/pool2_tmeta size "16.00g"
-lvremove -ff $vg
-
-# Test automatic calculation of pool metadata size
-lvcreate -L160G -T $vg/pool
-check lv_field $vg/pool lv_metadata_size "80.00m"
-check lv_field $vg/pool chunksize        "128.00k"
-lvremove -ff $vg/pool
-
-lvcreate -L10G --chunksize 256 -T $vg/pool1
-lvcreate -L60G --chunksize 1024 -T $vg/pool2
-check lv_field $vg/pool1_tmeta size "2.50m"
-check lv_field $vg/pool2_tmeta size "3.75m"
-lvremove -ff $vg
-
-# Block size of multiple 64KB needs >= 1.4
-if aux have_thin 1 4 0 ; then
-# Test chunk size is rounded to 64KB boundary
-lvcreate -L10G --poolmetadatasize 4M -T $vg/pool
-check lv_field $vg/pool chunk_size "192.00k"
-fi
-# Old thinpool target required rounding to power of 2
-aux lvmconf "global/thin_disabled_features = [ \"block_size\" ]"
-lvcreate -L10G --poolmetadatasize 4M -T $vg/pool_old
-check lv_field $vg/pool_old chunk_size "256.00k"
-lvremove -ff $vg
-# reset
-#aux lvmconf "global/thin_disabled_features = []"
-
-vgremove -ff $vg


