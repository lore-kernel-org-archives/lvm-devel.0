From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 21 Aug 2015 20:27:14 +0000 (UTC)
Subject: master - tests: add test for lvmlockd lock_args
Message-ID: <20150821202714.BDAB460DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d827dd8b053d69adf3cdfa6f3b8071af4b0e3846
Commit:        d827dd8b053d69adf3cdfa6f3b8071af4b0e3846
Parent:        e53758c5f6074f920325afe0a01616f7c663f766
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 21 15:06:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 21 15:09:38 2015 -0500

tests: add test for lvmlockd lock_args

---
 test/shell/lvmlockd-lv-types.sh |  164 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 164 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
new file mode 100644
index 0000000..79cde22
--- /dev/null
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -0,0 +1,164 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Check lvmlockd lock_args for different LV types'
+
+. lib/inittest
+
+test -e LOCAL_LVMLOCKD && skip
+
+if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
+LOCKARGS1="1.0.0:70254592"
+LOCKARGS2="1.0.0:71303168"
+LOCKARGS3="1.0.0:72351744"
+fi
+
+if test -n "$LVM_TEST_LOCK_TYPE_DLM" ; then
+LOCKARGS1="dlm"
+LOCKARGS2="dlm"
+LOCKARGS3="dlm"
+fi
+
+aux prepare_devs 5
+
+vgcreate --shared $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+
+#
+# thin pool, thin lv, thin snap
+#
+
+lvcreate -L 8M -n pool1 $vg
+check lva_field $vg/pool1 lockargs $LOCKARGS1
+
+lvcreate -L 8M -n pool1_meta $vg
+check lva_field $vg/pool1_meta lockargs $LOCKARGS2
+
+lvconvert -y --type thin-pool --poolmetadata $vg/pool1_meta $vg/pool1
+check lva_field $vg/pool1 lockargs $LOCKARGS3
+check lva_field $vg/pool1_tdata lockargs ""
+check lva_field $vg/pool1_tmeta lockargs ""
+
+lvcreate -n thin1 -V 1G --thinpool $vg/pool1
+check lva_field $vg/thin1 lockargs ""
+
+lvcreate -s -n snap1 $vg/thin1
+check lva_field $vg/snap1 lockargs ""
+
+lvchange -ay -K $vg/snap1
+
+lvchange -an $vg/snap1
+lvchange -an $vg/thin1
+lvchange -an $vg/pool1
+lvremove $vg/snap1
+lvremove $vg/thin1
+lvremove $vg/pool1
+
+# the first sanlock lock should be found and reused
+lvcreate -L 8M -n lv1 $vg
+check lva_field $vg/lv1 lockargs $LOCKARGS1
+
+lvchange -an $vg/lv1
+lvremove $vg/lv1
+
+
+#
+# with automatic metadata lv
+#
+
+lvcreate -L 8M -n pool2 $vg
+check lva_field $vg/pool2 lockargs $LOCKARGS1
+
+lvconvert -y --type thin-pool $vg/pool2
+check lva_field $vg/pool2 lockargs $LOCKARGS2
+check lva_field $vg/pool2_tdata lockargs ""
+check lva_field $vg/pool2_tmeta lockargs ""
+
+lvcreate -n thin2 -V 1G --thinpool $vg/pool2
+check lva_field $vg/thin2 lockargs ""
+
+lvchange -an $vg/thin2
+lvchange -an $vg/pool2
+lvremove $vg/thin2
+lvremove $vg/pool2
+
+
+#
+# cache pool, cache lv
+#
+
+lvcreate -L 8M -n cache1 $vg
+check lva_field $vg/cache1 lockargs $LOCKARGS1
+
+lvcreate -L 8M -n cache1_meta $vg
+check lva_field $vg/cache1_meta lockargs $LOCKARGS2
+
+lvconvert -y --type cache-pool --poolmetadata $vg/cache1_meta $vg/cache1
+check lva_field $vg/cache1 lockargs ""
+check lva_field $vg/cache1_cdata lockargs ""
+check lva_field $vg/cache1_cmeta lockargs ""
+
+lvcreate -n lv1 -L 8M $vg
+check lva_field $vg/lv1 lockargs $LOCKARGS1
+
+lvconvert -y --type cache --cachepool $vg/cache1 $vg/lv1
+check lva_field $vg/lv1 lockargs $LOCKARGS1
+check lva_field $vg/cache1 lockargs ""
+check lva_field $vg/cache1_cdata lockargs ""
+check lva_field $vg/cache1_cmeta lockargs ""
+
+lvconvert --splitcache $vg/lv1
+check lva_field $vg/lv1 lockargs $LOCKARGS1
+check lva_field $vg/cache1 lockargs ""
+check lva_field $vg/cache1_cdata lockargs ""
+check lva_field $vg/cache1_cmeta lockargs ""
+
+lvchange -an $vg/cache1
+lvchange -an $vg/lv1
+lvremove $vg/cache1
+lvremove $vg/lv1
+
+#
+# cow snap
+#
+
+lvcreate -n lv2 -L 8M $vg
+check lva_field $vg/lv2 lockargs $LOCKARGS1
+
+lvcreate -s -n lv2snap -L 8M $vg/lv2
+check lva_field $vg/lv2 lockargs $LOCKARGS1
+check lva_field $vg/lv2snap lockargs ""
+
+lvchange -y -an $vg/lv2
+lvremove $vg/lv2snap
+lvremove $vg/lv2
+
+#
+# mirror
+#
+
+lvcreate --type mirror -m 1 -n lv3 -L 8M $vg
+check lva_field $vg/lv3 lockargs $LOCKARGS1
+
+lvchange -an $vg/lv3
+lvremove $vg/lv3
+
+#
+# raid1
+#
+
+lvcreate --type raid1 -m 1 -n lv4 -L 8M $vg
+check lva_field $vg/lv4 lockargs $LOCKARGS1
+
+lvchange -an $vg/lv4
+lvremove $vg/lv4
+
+vgremove $vg
+


