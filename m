From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 23:41:36 +0000 (UTC)
Subject: master - tests: move some tests to better places
Message-ID: <20140327234136.236F6608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd805ff0482b96b21076f9507cedf82c142cdebc
Commit:        bd805ff0482b96b21076f9507cedf82c142cdebc
Parent:        5b44a036b147f8661567fc165e4a7de734a539b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 00:37:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 00:41:19 2014 +0100

tests: move some tests to better places

Some tests already have separate test scripts - so move
those tests to listing and vgcfgbackup files.
---
 test/shell/covercmd.sh          |  147 ++++++++++-----------------------------
 test/shell/listings.sh          |   80 +++++++++++++++++++++
 test/shell/vgcfgbackup-usage.sh |   20 +++--
 3 files changed, 128 insertions(+), 119 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index e5773ad..d9a5382 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,107 +10,53 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 #
-# tests basic functionality of read-ahead and ra regressions
+# tests functionality we don't have in other special test files yet
+# to improve code coverage
 #
 
 . lib/test
 
-aux prepare_devs 5
+aux prepare_pvs 5
 
-TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
-
-pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
-pvcreate "$dev4"
-pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 "$dev5"
+
+pvscan --uuid
+
+# FIXME takes very long time
+#pvck "$dev1"
+
+
 vgcreate $vg $(cat DEVICES)
-lvcreate -l 5 -i5 -I256 -n $lv $vg
+not vgscan $vg
+vgscan --mknodes
+vgs -o all $vg
 
+lvcreate -l 5 -i5 -I256 -n $lv $vg
 lvcreate -aey -l 5 -n $lv1 $vg
 lvcreate -s -l 5 -n $lv2 $vg/$lv1
+pvck "$dev1"
 
-if aux have_readline; then
-# test *scan and *display tools
-cat <<EOF | lvm
-pvscan --uuid
-vgscan --mknodes
-lvscan
-lvmdiskscan
-vgdisplay --units k $vg
-lvdisplay --units g $vg
-pvdisplay -c "$dev1"
-pvdisplay -s "$dev1"
-vgdisplay -c $vg
-vgdisplay -C $vg
-vgdisplay -s $vg
-lvdisplay -c $vg
-lvdisplay -C $vg
-lvdisplay -m $vg
-EOF
-
-for i in h b s k m g t p e H B S K M G T P E; do
-	echo pvdisplay --units $i "$dev1"
-done | lvm
-else
-pvscan --uuid
-vgscan --mknodes
+not lvscan $vg
 lvscan
+
 lvmdiskscan
-vgdisplay --units k $vg
-lvdisplay --units g $vg
-pvdisplay -c "$dev1"
-pvdisplay -s "$dev1"
-vgdisplay -c $vg
-vgdisplay -C $vg
-vgdisplay -s $vg
-lvdisplay -c $vg
-lvdisplay -C $vg
-lvdisplay -m $vg
-
-for i in h b s k m g t p e H B S K M G T P E; do
-	pvdisplay --units $i "$dev1"
-done
-fi
-
-not lvdisplay -C -m $vg
-not lvdisplay -c -v $vg
-not lvdisplay --aligned $vg
-not lvdisplay --noheadings $vg
-not lvdisplay --options lv_name $vg
-not lvdisplay --separator : $vg
-not lvdisplay --sort size $vg
-not lvdisplay --unbuffered $vg
-
-not vgdisplay -C -A
-not vgdisplay -C -c
-not vgdisplay -C -s
-not vgdisplay -c -s
-not vgdisplay -A $vg1
 
 # "-persistent y --major 254 --minor 20"
 # "-persistent n"
-# test various lvm utils
-for i in dumpconfig devtypes formats segtypes tags; do
-	lvm $i
-done
-
 for i in pr "p rw" an ay "-monitor y" "-monitor n" \
         -refresh "-addtag MYTAG" "-deltag MYETAG"; do
 	lvchange -$i $vg/$lv
 done
 
-pvck "$dev1"
-vgs -o all $vg
 lvrename $vg $lv $lv-rename
-vgcfgbackup -f backup.$$ $vg
-vgchange -an $vg
-vgcfgrestore  -f backup.$$ $vg
-pvremove -y -ff "$dev5"
-not vgcfgrestore  -f backup.$$ $vg
-pvcreate -u $TEST_UUID --restorefile  backup.$$ "$dev5"
+not lvrename $vg
+not lvrename $vg-xxx
+not lvrename $vg $vg/$lv-rename $vg1/$lv
+
 vgremove -f $vg
 
+
 # test pvresize functionality
 # missing params
 not pvresize
@@ -121,38 +67,17 @@ not pvresize --setphysicalvolumesize 10M "$dev7"
 pvresize --setphysicalvolumesize 10M "$dev1"
 pvresize "$dev1"
 
-# test various errors and obsoleted tools
-not lvmchange
-not lvmsadc
-not lvmsar
-not pvdata
-
-not lvrename $vg
-not lvrename $vg-xxx
-not lvrename $vg  $vg/$lv-rename $vg/$lv
-not lvscan $vg
-not vgscan $vg
-
-#test vgdisplay -A to select only active VGs
-# all LVs active - VG considered active
-pvcreate -f "$dev1" "$dev2" "$dev3"
 
-vgcreate $vg1 "$dev1"
-lvcreate -l1 $vg1
-lvcreate -l1 $vg1
-
-# at least one LV active - VG considered active
-vgcreate $vg2 "$dev2"
-lvcreate -l1 $vg2
-lvcreate -l1 -an -Zn $vg2
-
-# no LVs active - VG considered inactive
-vgcreate $vg3 "$dev3"
-lvcreate -l1 -an -Zn $vg3
-lvcreate -l1 -an -Zn $vg3
-
-vgdisplay -s -A | grep $vg1
-vgdisplay -s -A | grep $vg2
-vgdisplay -s -A | not grep $vg3
-
-vgremove -ff $vg1 $vg2 $vg3
+# test various lvm utils
+lvm dumpconfig
+lvm devtypes
+lvm formats
+lvm segtypes
+lvm tags
+
+
+# test obsoleted tools
+not lvm lvmchange
+not lvm lvmsadc
+not lvm lvmsar
+not lvm pvdata
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 42c6ba5..0d69957 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -72,5 +72,85 @@ not diff out out2
 
 aux disable_dev "$dev1"
 pvs -o +pv_uuid | grep BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
+aux enable_dev "$dev1"
+
+if aux have_readline; then
+# test *scan and *display tools
+cat <<EOF | lvm
+vgdisplay --units k $vg
+lvdisplay --units g $vg
+pvdisplay -c "$dev1"
+pvdisplay -s "$dev1"
+vgdisplay -c $vg
+vgdisplay -C $vg
+vgdisplay -s $vg
+lvdisplay -c $vg
+lvdisplay -C $vg
+lvdisplay -m $vg
+EOF
+
+for i in h b s k m g t p e H B S K M G T P E; do
+	echo pvdisplay --units $i "$dev1"
+done | lvm
+else
+pvscan --uuid
+vgscan --mknodes
+lvscan
+lvmdiskscan
+vgdisplay --units k $vg
+lvdisplay --units g $vg
+pvdisplay -c "$dev1"
+pvdisplay -s "$dev1"
+vgdisplay -c $vg
+vgdisplay -C $vg
+vgdisplay -s $vg
+lvdisplay -c $vg
+lvdisplay -C $vg
+lvdisplay -m $vg
+
+for i in h b s k m g t p e H B S K M G T P E; do
+	pvdisplay --units $i "$dev1"
+done
+fi
+
+invalid lvdisplay -C -m $vg
+invalid lvdisplay -c -v $vg
+invalid lvdisplay --aligned $vg
+invalid lvdisplay --noheadings $vg
+invalid lvdisplay --options lv_name $vg
+invalid lvdisplay --separator : $vg
+invalid lvdisplay --sort size $vg
+invalid lvdisplay --unbuffered $vg
+
+
+invalid vgdisplay -C -A
+invalid vgdisplay -C -c
+invalid vgdisplay -C -s
+invalid vgdisplay -c -s
+invalid vgdisplay -A $vg1
 
 vgremove -ff $vg
+
+#test vgdisplay -A to select only active VGs
+# all LVs active - VG considered active
+pvcreate "$dev1" "$dev2" "$dev3"
+
+vgcreate $vg1 "$dev1"
+lvcreate -l1 $vg1
+lvcreate -l1 $vg1
+
+#@least one LV active - VG considered active
+vgcreate $vg2 "$dev2"
+lvcreate -l1 $vg2
+lvcreate -l1 -an -Zn $vg2
+
+# no LVs active - VG considered inactive
+vgcreate $vg3 "$dev3"
+lvcreate -l1 -an -Zn $vg3
+lvcreate -l1 -an -Zn $vg3
+
+vgdisplay -s -A | grep $vg1
+vgdisplay -s -A | grep $vg2
+vgdisplay -s -A | not grep $vg3
+
+vgremove -f $vg1 $vg2 $vg3
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 3d955b5..193bb9d 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -13,6 +13,8 @@
 
 aux prepare_pvs 4
 
+pvcreate --metadatacopies 0 "$dev4"
+
 # No automatic backup
 aux lvmconf "backup/backup = 0"
 
@@ -29,12 +31,12 @@ vgcfgbackup
 test -e etc/backup/$vg1
 test -e etc/backup/$vg2
 
-vgcfgbackup -f bak-%s >out
+vgcfgbackup -f "bak-%s" >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
 # increase seqno
 lvcreate -an -Zn -l1 $vg1
-vgcfgrestore -f bak-$vg1 $vg1
+vgcfgrestore -f "bak-$vg1" $vg1
 vgremove -ff $vg1 $vg2
 
 # vgcfgbackup correctly stores metadata with missing PVs
@@ -48,15 +50,17 @@ lvcreate -l1 -n $lv3 $vg "$dev3"
 vgchange -a n $vg
 pvcreate -ff -y "$dev1"
 pvcreate -ff -y "$dev2"
-vgcfgbackup -f "$(pwd)/backup.$$" $vg
-sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
+vgcfgbackup -f "backup.$$" $vg
+sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "backup.$$" > "backup.$$1"
 pvcreate -ff -y --norestorefile -u $pv1_uuid "$dev1"
 pvcreate -ff -y --norestorefile -u $pv2_uuid "$dev2"
 
 # Try to recover nonexisting vgname
-not vgcfgrestore -f "$(pwd)/backup.$$1" ${vg}_nonexistent
-vgcfgrestore -f "$(pwd)/backup.$$1" $vg
-vgremove -ff $vg
+not vgcfgrestore -f "backup.$$1" ${vg}_nonexistent
+vgcfgrestore -f "backup.$$1" $vg
+vgchange -an $vg
+vgremove -f $vg
+
 
 # vgcfgbackup correctly stores metadata LVM1 with missing PVs
 # FIXME: clvmd seems to have problem with metadata format change here
@@ -67,4 +71,4 @@ vgcreate -M1 -c n $vg $(cat DEVICES)
 lvcreate -l1 -n $lv1 $vg "$dev1"
 pvremove -ff -y "$dev2"
 not lvcreate -l1 -n $lv1 $vg "$dev3"
-vgcfgbackup -f "$(pwd)/backup.$$" $vg
+vgcfgbackup -f "backup.$$" $vg


