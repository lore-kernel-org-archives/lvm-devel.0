From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 15 Mar 2016 22:23:47 +0000 (UTC)
Subject: master - tests: stacked resize of thin on raid
Message-ID: <20160315222347.0B9F060D5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=464ebe04db33ac105f5278dbbb244a9f84d582f8
Commit:        464ebe04db33ac105f5278dbbb244a9f84d582f8
Parent:        51ed48f8551cf32539765b5057bb20cc8d9a8777
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 15 23:16:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 15 23:22:52 2016 +0100

tests: stacked resize of thin on raid

---
 test/shell/lvextend-thin-raid.sh |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-thin-raid.sh b/test/shell/lvextend-thin-raid.sh
new file mode 100644
index 0000000..7014985
--- /dev/null
+++ b/test/shell/lvextend-thin-raid.sh
@@ -0,0 +1,35 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+aux have_raid 1 3 0 || skip
+
+aux prepare_vg 3
+
+lvcreate --type raid1 -l2 --nosync -n pool $vg
+lvconvert --yes --thinpool $vg/pool "$dev3"
+
+check lv_field $vg/pool seg_size_pe "2"
+check lv_field $vg/pool_tdata seg_size_pe "2" -a
+
+lvextend -l+3 $vg/pool
+
+check lv_field $vg/pool seg_size_pe "5"
+check lv_field $vg/pool_tdata seg_size_pe "5" -a
+
+vgremove -ff $vg


