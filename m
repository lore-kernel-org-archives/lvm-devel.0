From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Oct 2014 00:16:22 +0000 (UTC)
Subject: master - test: Add process-each toollib tests.
Message-ID: <20141007001622.823F66036F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86dad329be2fa20a528066776aab77f26a29790c
Commit:        86dad329be2fa20a528066776aab77f26a29790c
Parent:        8dc5f42254b319430d02e2d0ca4cffd36b2cbaca
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 7 01:08:03 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 7 01:15:43 2014 +0100

test: Add process-each toollib tests.

---
 WHATS_NEW                               |    4 +
 test/shell/process-each-pv-nomda-all.sh |   60 ++
 test/shell/process-each-pv-nomda.sh     |   27 +
 test/shell/process-each-pv.sh           | 1285 +++++++++++++++++++++++++++++++
 test/shell/process-each-pvresize.sh     |  561 ++++++++++++++
 5 files changed, 1937 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 875ab20..fa4ff65 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.112 - 
 =====================================
+  Introduce WARN_ flags to control some metadata warning messages.
+  Use process_each_pv in vgreduce.
+  Refactor process_each_pv in toollib.
   Introduce single validation routine for pool chunk size.
   Support --yes like --force in vg/lvremove to skip y|n prompt.
   Support --yes with lvconvert --splitsnapshot.
@@ -14,6 +17,7 @@ Version 2.02.112 -
   Support lvconvert --splitcache and --uncache of cached LV.
   Option --cache has also shortcut -H (i.e. lvcreate -H).
   Refactor lvcreate code and better preserve --type argument.
+  Refactor process_each_lv in toollib.
   Refactor process_each_vg in toollib.
   Pools cannot be used as external origin.
   Use lv_update_and_reload() for snapshot reload.
diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
new file mode 100644
index 0000000..ae9f8e5
--- /dev/null
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -0,0 +1,60 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test process_each_pv with zero mda'
+
+. lib/inittest
+
+aux prepare_devs 14
+
+# for vg1
+pvcreate $dev10
+
+# for vg2
+pvcreate $dev2 --metadatacopies 0
+pvcreate $dev3
+pvcreate $dev4
+pvcreate $dev5
+
+# for vg3
+pvcreate $dev6 --metadatacopies 0
+pvcreate $dev7 --metadatacopies 0
+pvcreate $dev8 --metadatacopies 0
+pvcreate $dev9
+
+# orphan with mda
+pvcreate "$dev11"
+# orphan without mda
+pvcreate "$dev14" --metadatacopies 0
+
+# non-pv devs
+# dev12
+# dev13
+
+vgcreate $vg1 "$dev10"
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+
+pvs -a >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+grep $dev12 err
+grep $dev13 err
+grep $dev14 err
+
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
new file mode 100644
index 0000000..10ce878
--- /dev/null
+++ b/test/shell/process-each-pv-nomda.sh
@@ -0,0 +1,27 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test process_each_pv with zero mda'
+
+. lib/inittest
+
+aux prepare_devs 2
+
+pvcreate $dev1 --metadatacopies 0
+pvcreate $dev2
+
+vgcreate $vg1 "$dev1" "$dev2"
+
+pvdisplay -a -C >err
+cat err
+grep $dev1 err
+grep $dev2 err
+
diff --git a/test/shell/process-each-pv.sh b/test/shell/process-each-pv.sh
new file mode 100644
index 0000000..a24b80b
--- /dev/null
+++ b/test/shell/process-each-pv.sh
@@ -0,0 +1,1285 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise toollib process_each_pv'
+
+. lib/inittest
+
+aux prepare_devs 14
+
+#
+# process_each_pv is used by a number of pv commands:
+# pvdisplay
+# pvresize
+# pvs
+# vgreduce
+#
+# process-each-pvresize.sh covers pvresize,
+# the others are covered here.
+#
+
+
+#
+# set up
+#
+# use use dev10 instead of dev1 because simple grep for
+# dev1 matchines dev10,dev11,etc
+#
+
+vgcreate $vg1 "$dev10"
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+pvchange --addtag V3 "$dev6" "$dev7" "$dev8" "$dev9"
+pvchange --addtag V3D9 "$dev9"
+
+# orphan
+pvcreate "$dev11"
+
+# dev (a non-pv device)
+pvcreate "$dev12"
+pvremove "$dev12"
+
+# dev13 is intentionally untouched so we can
+# test that it is handled appropriately as a non-pv
+
+# orphan
+pvcreate "$dev14"
+
+
+#
+# test pvdisplay
+#
+
+# pv in vg
+pvdisplay -s $dev10 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# pv not in vg (one orphan)
+pvdisplay -s $dev11 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# dev is not a pv
+not pvdisplay -s $dev12 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# two pvs in different vgs
+pvdisplay -s $dev10 $dev2 >err
+grep $dev10 err
+grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# -a is invalid when used alone
+not pvdisplay -a >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one pv and one orphan
+pvdisplay -s $dev10 $dev11 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one pv and one dev (dev refers to a non-pv device)
+not pvdisplay -s $dev10 $dev12 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one orphan and one dev
+not pvdisplay -s $dev11 $dev12 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# all pvs (pvs in vgs and orphan pvs)
+pvdisplay -s >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# all devs (pvs in vgs, orphan pvs, and devs)
+pvdisplay -a -C >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+grep $dev12 err
+grep $dev13 err
+grep $dev14 err
+
+# pv and orphan and dev
+not pvdisplay -s $dev9 $dev11 $dev12 > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# -s option not allowed with -a -C
+not pvdisplay -s -a -C > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# pv and all (all ignored)
+pvdisplay -a -C $dev9 > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# orphan and all (all ignored)
+pvdisplay -a -C $dev11 > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one tag
+pvdisplay -s @V2D3 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# two tags
+pvdisplay -s @V2D3 @V2D45 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and pv
+pvdisplay -s @V2D3 $dev4 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and orphan
+pvdisplay -s @V2D3 $dev11 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and dev
+not pvdisplay -s @V2D3 $dev12 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and all (all ignored)
+pvdisplay @V2D3 -a -C > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and pv redundant
+pvdisplay -s @V2D3 $dev3 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+
+#
+# test pvs
+#
+
+# pv in vg
+pvs $dev10 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# pv not in vg (one orphan)
+pvs $dev11 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# dev is not a pv
+not pvs $dev12 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# two pvs in different vgs
+pvs $dev10 $dev2 >err
+grep $dev10 err
+grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one pv and one orphan
+pvs $dev10 $dev11 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one pv and one dev
+not pvs $dev10 $dev12 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one orphan and one dev
+not pvs $dev11 $dev12 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# all pvs (pvs in vgs and orphan pvs)
+pvs >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# all devs (pvs in vgs, orphan pvs, and devs)
+pvs -a >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+grep $dev12 err
+grep $dev13 err
+grep $dev14 err
+
+# pv and orphan and dev
+not pvs $dev9 $dev11 $dev12 > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# pv and all (all ignored)
+pvs -a $dev9 > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# orphan and all (all ignored)
+pvs -a $dev11 > err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# one tag
+pvs @V2D3 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# two tags
+pvs @V2D3 @V2D45 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and pv
+pvs @V2D3 $dev4 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and orphan
+pvs @V2D3 $dev11 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and dev
+not pvs @V2D3 $dev12 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and all (all ignored)
+pvs @V2D3 -a > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag and pv redundant
+pvs @V2D3 $dev3 > err
+not grep $dev10 err
+not grep $dev2 err
+grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+
+#
+# test vgreduce
+#
+
+# fail without dev
+not vgreduce $vg2
+
+
+# fail with dev and -a
+not vgreduce $vg2 $dev2 -a
+check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+
+
+# remove one pv
+vgreduce $vg2 $dev2
+not check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev2
+
+
+# remove two pvs
+vgreduce $vg2 $dev2 $dev3
+not check pv_field $dev2 vg_name $vg2
+not check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev2 $dev3
+pvchange --addtag V2D3 "$dev3"
+
+
+# remove one pv with tag
+vgreduce $vg2 @V2D3
+check pv_field $dev2 vg_name $vg2
+not check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev3
+pvchange --addtag V2D3 "$dev3"
+
+
+# remove two pvs, each with different tag
+vgreduce $vg2 @V2D3 @V2D4
+check pv_field $dev2 vg_name $vg2
+not check pv_field $dev3 vg_name $vg2
+not check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev3 $dev4
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+
+
+# remove two pvs, both with same tag
+vgreduce $vg2 @V2D45
+check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+not check pv_field $dev4 vg_name $vg2
+not check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev4 $dev5
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+
+# remove two pvs, one by name, one by tag
+vgreduce $vg2 $dev2 @V2D3
+not check pv_field $dev2 vg_name $vg2
+not check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev2 $dev3
+pvchange --addtag V2D3 "$dev3"
+
+
+# remove one pv by tag, where another vg has a pv with same tag
+pvchange --addtag V2D5V3D9 "$dev5"
+pvchange --addtag V2D5V3D9 "$dev9"
+vgreduce $vg2 @V2D5V3D9
+check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+not check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev5
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+
+# fail to remove last pv (don't know which will be last)
+not vgreduce -a $vg2
+# reset
+vgremove $vg2
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+
+# lvcreate on one pv to make it used
+# remove all unused pvs
+lvcreate -n $lv1 -l 2 $vg2 $dev2
+not vgreduce -a $vg2
+check pv_field $dev2 vg_name $vg2
+not check pv_field $dev3 vg_name $vg2
+not check pv_field $dev4 vg_name $vg2
+not check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev3 $dev4 $dev5
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+lvchange -an $vg2/$lv1
+lvremove $vg2/$lv1
+
+
+#
+# tests including pvs without mdas
+#
+
+# remove old config
+vgremove $vg1
+vgremove $vg2
+vgremove $vg3
+pvremove $dev11
+pvremove $dev14
+
+# new config with some pvs that have zero mdas
+
+# for vg1
+pvcreate $dev10
+
+# for vg2
+pvcreate $dev2 --metadatacopies 0
+pvcreate $dev3
+pvcreate $dev4
+pvcreate $dev5
+
+# for vg3
+pvcreate $dev6 --metadatacopies 0
+pvcreate $dev7 --metadatacopies 0
+pvcreate $dev8 --metadatacopies 0
+pvcreate $dev9
+
+# orphan with mda
+pvcreate "$dev11"
+# orphan without mda
+pvcreate "$dev14" --metadatacopies 0
+
+# non-pv devs
+# dev12
+# dev13
+
+vgcreate $vg1 "$dev10"
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+pvchange --addtag V3 "$dev6" "$dev7" "$dev8" "$dev9"
+pvchange --addtag V3D8 "$dev8"
+pvchange --addtag V3D9 "$dev9"
+
+
+#
+# pvdisplay including pvs without mdas
+#
+
+# pv with mda
+pvdisplay -s $dev10 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# pv without mda
+pvdisplay -s $dev2 >err
+not grep $dev10 err
+grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# orphan with mda
+pvdisplay -s $dev11 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# orphan without mda
+pvdisplay -s $dev14 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# pv with mda, pv without mda, orphan with mda, orphan without mda
+pvdisplay -s $dev10 $dev2 $dev11 $dev14 >err
+grep $dev10 err
+grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# tag refering to pv with mda and pv without mda
+pvdisplay -s @V3 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag refering to one pv without mda
+pvdisplay -s @V3D8 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# all pvs (pvs in vgs and orphan pvs)
+pvdisplay -s >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# all devs (pvs in vgs, orphan pvs, and devs)
+pvdisplay -a -C >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+grep $dev12 err
+grep $dev13 err
+grep $dev14 err
+
+#
+# pvs including pvs without mdas
+#
+
+# pv with mda
+pvs $dev10 >err
+grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# pv without mda
+pvs $dev2 >err
+not grep $dev10 err
+grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# orphan with mda
+pvs $dev11 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# orphan without mda
+pvs $dev14 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# pv with mda, pv without mda, orphan with mda, orphan without mda
+pvs $dev10 $dev2 $dev11 $dev14 >err
+grep $dev10 err
+grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+not grep $dev8 err
+not grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# tag refering to pv with mda and pv without mda
+pvs @V3 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# tag refering to one pv without mda
+pvs @V3D8 >err
+not grep $dev10 err
+not grep $dev2 err
+not grep $dev3 err
+not grep $dev4 err
+not grep $dev5 err
+not grep $dev6 err
+not grep $dev7 err
+grep $dev8 err
+not grep $dev9 err
+not grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+not grep $dev14 err
+
+# all pvs (pvs in vgs and orphan pvs)
+pvs >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+not grep $dev12 err
+not grep $dev13 err
+grep $dev14 err
+
+# all devs (pvs in vgs, orphan pvs, and devs)
+pvs -a >err
+grep $dev10 err
+grep $dev2 err
+grep $dev3 err
+grep $dev4 err
+grep $dev5 err
+grep $dev6 err
+grep $dev7 err
+grep $dev8 err
+grep $dev9 err
+grep $dev11 err
+grep $dev12 err
+grep $dev13 err
+grep $dev14 err
+
+
+#
+# vgreduce including pvs without mdas
+#
+
+# remove pv without mda
+vgreduce $vg2 $dev2
+not check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev2
+
+# remove pv with mda and pv without mda
+vgreduce $vg2 $dev2 $dev3
+not check pv_field $dev2 vg_name $vg2
+not check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+# reset
+vgextend $vg2 $dev2
+vgextend $vg2 $dev3
+
+# fail to remove only pv with mda
+not vgreduce $vg3 $dev9
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+
+# remove by tag a pv without mda
+vgreduce $vg3 @V3D8
+check pv_field $dev6 vg_name $vg3
+check pv_field $dev7 vg_name $vg3
+not check pv_field $dev8 vg_name $vg3
+check pv_field $dev9 vg_name $vg3
+check pv_field $dev2 vg_name $vg2
+check pv_field $dev3 vg_name $vg2
+check pv_field $dev4 vg_name $vg2
+check pv_field $dev5 vg_name $vg2
+# reset
+vgextend $vg3 $dev8
+
+
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
new file mode 100644
index 0000000..caa0890
--- /dev/null
+++ b/test/shell/process-each-pvresize.sh
@@ -0,0 +1,561 @@
+#!/bin/sh
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise toollib process_each_pv'
+
+. lib/inittest
+
+aux prepare_devs 14
+
+#
+# process_each_pv is used by a number of pv commands:
+# pvdisplay
+# pvresize
+# pvs
+# vgreduce
+#
+
+
+#
+# set up
+#
+# use use dev10 instead of dev1 because simple grep for
+# dev1 matchines dev10,dev11,etc
+#
+
+vgcreate $vg1 "$dev10"
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+pvchange --addtag V3 "$dev6" "$dev7" "$dev8" "$dev9"
+pvchange --addtag V3D9 "$dev9"
+
+# orphan
+pvcreate "$dev11"
+
+# dev (a non-pv device)
+pvcreate "$dev12"
+pvremove "$dev12"
+
+# dev13 is intentionally untouched so we can
+# test that it is handled appropriately as a non-pv
+
+# orphan
+pvcreate "$dev14"
+
+#
+# test pvresize without orphans and and without non-pv devs
+#
+
+# For pvs in vgs, pvresize setphysicalvolumesize does not give us
+# the size requested, but reduces the requested size by some the
+# amount for alignment, metadata areas and pv headers.  So, when we resize
+# to 30M, the result is 28M, and when we resize to 20M, the result is 16M.
+# For orphans, the resulting size is the same as requested.
+# It suspect that these reduction amounts might be inconsistent, and
+# depend on other changing factors, so it may be that we eventually
+# want to give up checking the exact resulting size, but just check
+# that the result is less than the original size.
+
+old_request="30.00m"
+old_reduced="28.00m"
+new_request="20.00m"
+new_reduced="16.00m"
+
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+
+# one pv
+pvresize --setphysicalvolumesize $new_request $dev10
+check pv_field $dev10 pv_size $new_reduced
+# unchanged
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# two pvs in separate vgs
+pvresize --setphysicalvolumesize $new_request $dev2 $dev6
+check pv_field $dev2 pv_size $new_reduced
+check pv_field $dev6 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# one tag on one pv
+pvresize --setphysicalvolumesize $new_request @V2D4
+check pv_field $dev4 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# one tag on all pvs in one vg
+pvresize --setphysicalvolumesize $new_request @V3
+check pv_field $dev6 pv_size $new_reduced
+check pv_field $dev7 pv_size $new_reduced
+check pv_field $dev8 pv_size $new_reduced
+check pv_field $dev9 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# one tag on some pvs in one vg
+pvresize --setphysicalvolumesize $new_request @V2D45
+check pv_field $dev4 pv_size $new_reduced
+check pv_field $dev5 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# one tag on multiple pvs in separate vgs
+pvchange --addtag V12 "$dev10" "$dev2" "$dev3" "$dev4" "$dev5"
+pvresize --setphysicalvolumesize $new_request @V12
+check pv_field $dev10 pv_size $new_reduced
+check pv_field $dev2 pv_size $new_reduced
+check pv_field $dev3 pv_size $new_reduced
+check pv_field $dev4 pv_size $new_reduced
+check pv_field $dev5 pv_size $new_reduced
+# unchanged
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# one pv and one tag on different pv
+pvresize --setphysicalvolumesize $new_request $dev10 @V3D9
+check pv_field $dev10 pv_size $new_reduced
+check pv_field $dev9 pv_size $new_reduced
+# unchanged
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# redundant pv and tag
+pvresize --setphysicalvolumesize $new_request $dev9 @V3D9
+check pv_field $dev9 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+# two tags on pvs in separate vgs
+pvresize --setphysicalvolumesize $new_request @V3D9 @V2D3
+check pv_field $dev9 pv_size $new_reduced
+check pv_field $dev3 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+
+
+#
+# test pvresize with orphans
+#
+
+old_request="30.00m"
+old_reduced="28.00m"
+old_orphan="30.00m"
+new_request="20.00m"
+new_reduced="16.00m"
+new_orphan="20.00m"
+
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+
+# one orphan
+pvresize --setphysicalvolumesize $new_request $dev11
+check pv_field $dev11 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# two orphans
+pvresize --setphysicalvolumesize $new_request $dev11 $dev14
+check pv_field $dev11 pv_size $new_orphan
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one orphan, one tag
+pvresize --setphysicalvolumesize $new_request @V3D9 $dev14
+check pv_field $dev9 pv_size $new_reduced
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one pv, one orphan, one tag
+pvresize --setphysicalvolumesize $new_request @V3D9 $dev14 $dev10
+check pv_field $dev9 pv_size $new_reduced
+check pv_field $dev10 pv_size $new_reduced
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+
+#
+# test pvresize with non-pv devs
+#
+
+# one dev (non-pv)
+not pvresize --setphysicalvolumesize $new_request $dev13
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+
+# one orphan and one dev (non-pv)
+not pvresize --setphysicalvolumesize $new_request $dev14 $dev13
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one pv and one dev (non-pv)
+not pvresize --setphysicalvolumesize $new_request $dev9 $dev13
+check pv_field $dev9 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one tag and one dev (non-pv)
+not pvresize --setphysicalvolumesize $new_request @V3D9 $dev13
+check pv_field $dev9 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one pv, one orphan, one tag, one dev
+not pvresize --setphysicalvolumesize $new_request @V3D9 $dev13 $dev14 $dev10
+check pv_field $dev9 pv_size $new_reduced
+check pv_field $dev10 pv_size $new_reduced
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+
+#
+# pvresize including pvs without mdas
+#
+
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+
+# one pv without mda
+pvresize --setphysicalvolumesize $new_request $dev2
+check pv_field $dev2 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# two pvs without mdas
+pvresize --setphysicalvolumesize $new_request $dev6 $dev7
+check pv_field $dev6 pv_size $new_reduced
+check pv_field $dev7 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one pv with mda and one pv without mda
+pvresize --setphysicalvolumesize $new_request $dev8 $dev9
+check pv_field $dev8 pv_size $new_reduced
+check pv_field $dev9 pv_size $new_reduced
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one orphan with mda
+pvresize --setphysicalvolumesize $new_request $dev11
+check pv_field $dev11 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev14 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one orphan without mda
+pvresize --setphysicalvolumesize $new_request $dev14
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+check pv_field $dev11 pv_size $old_orphan
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one orphan with mda and one orphan without mda
+pvresize --setphysicalvolumesize $new_request $dev14 $dev11
+check pv_field $dev11 pv_size $new_orphan
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+check pv_field $dev8 pv_size $old_reduced
+check pv_field $dev9 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+
+# one pv with mda and one pv without mda, and
+# one orphan with mda and one orphan without mda
+pvresize --setphysicalvolumesize $new_request $dev8 $dev9 $dev14 $dev11
+check pv_field $dev8 pv_size $new_reduced
+check pv_field $dev9 pv_size $new_reduced
+check pv_field $dev11 pv_size $new_orphan
+check pv_field $dev14 pv_size $new_orphan
+# unchanged
+check pv_field $dev10 pv_size $old_reduced
+check pv_field $dev2 pv_size $old_reduced
+check pv_field $dev3 pv_size $old_reduced
+check pv_field $dev4 pv_size $old_reduced
+check pv_field $dev5 pv_size $old_reduced
+check pv_field $dev6 pv_size $old_reduced
+check pv_field $dev7 pv_size $old_reduced
+# reset back to old size
+pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+


