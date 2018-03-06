From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:35 -0500
Subject: master - tests: component activation
Message-ID: <201803061446.w26EkZeF027174@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b05caca77e3df828d69d13ef52f43cc1531d6481
Commit:        b05caca77e3df828d69d13ef52f43cc1531d6481
Parent:        eb3597acb3af2e6f21893b2e3bdfa84f2ca301b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 15:07:25 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:49 2018 +0100

tests: component activation

---
 test/shell/component-cache.sh  |   92 ++++++++++++++++++++++++++++++++++++++++
 test/shell/component-mirror.sh |   70 ++++++++++++++++++++++++++++++
 test/shell/component-raid.sh   |   50 ++++++++++++++++++++++
 test/shell/component-thin.sh   |   49 +++++++++++++++++++++
 4 files changed, 261 insertions(+), 0 deletions(-)

diff --git a/test/shell/component-cache.sh b/test/shell/component-cache.sh
new file mode 100644
index 0000000..2060b31
--- /dev/null
+++ b/test/shell/component-cache.sh
@@ -0,0 +1,92 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise activation of cache component devices
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 5 80
+
+lvcreate --type cache-pool -L 2 -n cpool $vg
+lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
+lvchange -an $vg
+
+for j in 1 2
+do
+
+# Activate supported components
+for i in cpool_cmeta cpool_cdata corigin_corig
+do
+	test ! -e "$DM_DEV_DIR/$vg/$i"
+	lvchange -ay -y $vg/$i
+	# check usable link is there
+	test -e "$DM_DEV_DIR/$vg/$i"
+
+        # cannot take snapshot of any active component LV
+        test "$j" -eq 2 || not lvcreate -s -L1 $vg/$i
+done
+
+# After 1st. phase deactivation works
+# Volumes are left active for vgremove on 2nd.. pass
+test "$j" -eq 2 || lvchange -an $vg
+
+done
+
+# Cannot active cached LV while any component LV is active
+not lvchange -ay $vg/corigin |& tee err
+grep "prohibited" err
+
+lvs -a $vg
+
+# Can split for writethrough|passthrough
+# deactivates all components as well...
+lvconvert --splitcache $vg/corigin
+lvs -a $vg
+
+# Cannot cache LV while components are active
+lvcreate -L 4 -n $lv2 $vg
+lvchange -ay -y $vg/cpool_cmeta
+
+not lvconvert -y --cachepool $vg/cpool -H $lv2
+
+lvremove -f $vg
+lvs -a $vg
+
+if aux have_thin 1 0 0 ; then
+
+lvcreate --type cache-pool -L 2 -n cpool $vg
+lvcreate -H -L 4 -n tpool --cachepool $vg/cpool
+lvchange -an $vg
+lvs -a $vg
+# Cannot convert to thin-pool with component LV active
+lvchange -ay -y $vg/cpool_cmeta
+
+# Conversion does not need to activate data device, so it can proceed ??
+lvconvert -y --thinpool $vg/tpool
+
+# Thin-pool cannot be activated
+not lvchange -ay $vg/tpool |& tee err
+grep "prohibited" err
+
+lvs -a $vg
+
+fi
+
+lvs -a $vg
+
+# And final removal works
+vgremove -f $vg
diff --git a/test/shell/component-mirror.sh b/test/shell/component-mirror.sh
new file mode 100644
index 0000000..b565c98
--- /dev/null
+++ b/test/shell/component-mirror.sh
@@ -0,0 +1,70 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise activation of mirror component devices
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 5 80
+
+lvcreate -aey --type mirror -L 2 -m 1 -n $lv1 $vg
+lvchange -an $vg
+
+lvs -a
+
+lvchange -an $vg
+
+for k in 1 2
+do
+
+# Activate supported components
+for i in ${lv1}_mimage_0 ${lv1}_mimage_1 ${lv1}_mlog
+do
+	test ! -e "$DM_DEV_DIR/$vg/$i"
+	lvchange -ay -y $vg/$i
+	# check usable link is there
+	test -e "$DM_DEV_DIR/$vg/$i"
+done
+
+# Deactivation works in 1st. pass
+test $k -eq 2 || lvchange -an $vg
+
+done
+
+# Cannot be resized
+not lvextend -L+20 $vg/$lv1 |& tee err
+grep "Cannot resize" err
+
+not lvresize -L-20 $vg/$lv1 |& tee err
+grep "Cannot resize" err
+
+# Cannot be converted
+lvcreate -aey -L10 -n $lv2 $vg
+not lvconvert -y -s $vg/$lv1 $lv2 |& tee err
+grep "Cannot use" err
+
+# Cannot be splitted
+not lvconvert --splitmirrors 1 -n split $vg/$lv1 |& tee err
+grep "Cannot convert" err
+
+# Cannot add new leg
+not lvconvert -m+1 $vg/$lv1 |& tee err
+grep "Cannot convert" err
+
+lvs -a
+
+vgremove -f $vg
diff --git a/test/shell/component-raid.sh b/test/shell/component-raid.sh
new file mode 100644
index 0000000..84f823f
--- /dev/null
+++ b/test/shell/component-raid.sh
@@ -0,0 +1,50 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise activation of raid component devices
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 5 80
+
+lvcreate --type raid1 -L 2 -m 1 -n $lv1 $vg
+lvchange -an $vg
+
+lvs -a $vg
+
+for k in 1 2
+do
+
+# Activate supported components
+for j in 0 1
+do
+for i in ${lv1}_rimage_$j ${lv1}_rmeta_$j
+do
+	test ! -e "$DM_DEV_DIR/$vg/$i"
+	lvchange -ay -y $vg/$i
+	# check usable link is there
+	test -e "$DM_DEV_DIR/$vg/$i"
+done
+done
+
+# Deactivation works in 1st. pass
+test $k -eq 2 || lvchange -an $vg
+
+done
+
+# And final removal works
+vgremove -f $vg
diff --git a/test/shell/component-thin.sh b/test/shell/component-thin.sh
new file mode 100644
index 0000000..4b1a35b
--- /dev/null
+++ b/test/shell/component-thin.sh
@@ -0,0 +1,49 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise activation of thin component devices
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 5 80
+
+lvcreate -T -L2 -V20 $vg/pool -n $lv1
+
+lvs -a
+
+lvchange -an $vg
+
+for i in pool_tdata pool_tmeta
+do
+	lvchange -ay -y $vg/$i
+	# check usable is there
+	test -e "$DM_DEV_DIR/$vg/$i"
+done
+
+lvs -a
+
+# When component LVs are active, thin-pool cannot be actived
+not lvcreate -V20 $vg/pool
+
+
+# FIXME: ATM removal of thin volumes goes 1-by-1 and needs to activate thin-pool.
+# And thin-pool cannot be activate thus vgremove fails.
+# To fix this it would need to be able to remove volumes without activation.
+should vgremove -f $vg
+
+# -ff bypass activation failure
+vgremove -ff $vg


