From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Nov 2012 13:28:48 +0000 (UTC)
Subject: master - tests: update thin testing
Message-ID: <20121127132848.137B113BA@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2be940e54910157da05ffe5d828828e4bcd8b25a
Commit:        2be940e54910157da05ffe5d828828e4bcd8b25a
Parent:        0387e70d7698be559d2d7ca8f9cdb8882be7ad0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 27 01:01:38 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 27 14:10:46 2012 +0100

tests: update thin testing

---
 test/shell/lvconvert-thin.sh |   10 ++++++++--
 test/shell/thin-defaults.sh  |   35 +++++++++++++++++++++++++++++++++++
 test/shell/thin-restore.sh   |   34 ++++++++++++++++++++++++++++++++++
 3 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index f21453f..4634aa2 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -24,9 +24,15 @@ prepare_lvs()
 #
 aux have_thin 1 0 0 || skip
 
-aux prepare_pvs 4 6400000
+aux prepare_pvs 4 64
 
-vgcreate $vg -s 64K $(cat DEVICES)
+# build one large PV
+vgcreate $vg1 $(cut -d ' ' -f -3 DEVICES)
+lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize 64T
+aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+
+pvcreate "$DM_DEV_DIR/$vg1/$lv"
+vgcreate $vg -s 64K $(cut -d ' ' -f 4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
 
 # create mirrored LVs for data and metadata volumes
 lvcreate -aey -L10M -m1 --mirrorlog core -n $lv1 $vg
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
new file mode 100644
index 0000000..677d2f1
--- /dev/null
+++ b/test/shell/thin-defaults.sh
@@ -0,0 +1,35 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# test defaults entered through lvm.conf
+
+. lib/test
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -T -L8M $vg/pool0
+
+aux lvmconf "allocation/thin_pool_chunk_size = 128" \
+	    "allocation/thin_pool_discards = \"ignore\"" \
+	    "allocation/thin_pool_zero = 0"
+
+lvcreate -T -L8M $vg/pool1
+
+check lv_field $vg/pool1 chunksize "128.00k"
+check lv_field $vg/pool1 discards "ignore"
+check lv_field $vg/pool1 zero 0
+
+vgremove -f $vg
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
new file mode 100644
index 0000000..7580ae4
--- /dev/null
+++ b/test/shell/thin-restore.sh
@@ -0,0 +1,34 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# test restore operation of thin pool metadata
+
+. lib/test
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 2
+
+lvcreate -T -L8M $vg/pool -V10M -n $lv1
+
+vgcfgbackup -f backup $vg
+
+# use of --force is mandatory
+not vgcfgrestore -f backup $vg
+
+vgcfgrestore -f backup --force $vg
+
+check lv_field $vg/pool transaction_id 1
+
+vgremove -f $vg


