From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 08:20:35 +0000 (UTC)
Subject: master - tests: put devs into ""
Message-ID: <20141007082035.AED80602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=236db9fc0df9784d559fbce49a9fcb5e642e6445
Commit:        236db9fc0df9784d559fbce49a9fcb5e642e6445
Parent:        75c4d268e9b0b70c58f8b8b018fe200aca7b8bb2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 09:54:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 10:19:33 2014 +0200

tests: put devs into ""

---
 test/shell/lvextend-thin.sh             |    2 +-
 test/shell/lvmetad-dump.sh              |    2 +-
 test/shell/lvmetad-lvm1.sh              |    2 +-
 test/shell/lvmetad-lvscan-cache.sh      |    4 +-
 test/shell/lvmetad-override.sh          |    2 +-
 test/shell/lvmetad-pvscan-cache.sh      |    2 +-
 test/shell/lvmetad-pvscan-md.sh         |    4 +-
 test/shell/lvresize-usage.sh            |    4 +-
 test/shell/mirror-names.sh              |    4 +-
 test/shell/process-each-pv-nomda-all.sh |   46 +-
 test/shell/process-each-pv-nomda.sh     |   14 +-
 test/shell/process-each-pv.sh           | 1898 +++++++++++++++----------------
 test/shell/process-each-pvresize.sh     |  707 ++++++------
 test/shell/pvchange-usage.sh            |    2 +-
 test/shell/pvcreate-bootloaderarea.sh   |    2 +-
 test/shell/pvmove-background.sh         |    2 +-
 test/shell/report-select.sh             |   10 +-
 17 files changed, 1351 insertions(+), 1356 deletions(-)

diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index 1a0b440..f9e24ce 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -15,5 +15,5 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_vg 3
 lvcreate -i2 -l2 -T $vg/pool2
-lvextend -l+2 $vg/pool2 $dev2 $dev3
+lvextend -l+2 $vg/pool2 "$dev2" "$dev3"
 should lvextend -l+100%FREE $vg/pool2
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 0c3df3b..14d5753 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -13,7 +13,7 @@
 test -e LOCAL_LVMETAD || skip
 
 aux prepare_pvs 2
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n bar -l 1 $vg1
 
 (echo | aux lvmetad_talk) || skip
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 3745dd0..f071b14 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -25,7 +25,7 @@ pvs | should grep "$dev1"
 pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"
 vgcreate --metadatatype 1 $vg1 "$dev1" "$dev2"
 lvcreate -l1 $vg1
-pvremove -ff -y $dev2
+pvremove -ff -y "$dev2"
 vgchange -an $vg1
 not lvremove $vg1
 not vgremove -ff -y $vg1
diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
index 529753c..e63fd20 100644
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -15,7 +15,7 @@ test -e LOCAL_LVMETAD || skip
 
 aux prepare_pvs 2
 
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n testlv -m 1 -l 1 $vg1
 vgs | grep $vg1
 
@@ -23,7 +23,7 @@ lvscan --cache $vg1/testlv
 
 vgs | grep $vg1
 
-aux disable_dev $dev2
+aux disable_dev "$dev2"
 
 # pvscan --cache already ran for the disabled device above, this should be a
 # no-op (but should not segfault!)
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index 27f15cb..ea76b35 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -14,7 +14,7 @@
 test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
 
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 kill $(< LOCAL_LVMETAD)
 lvchange -ay $vg1 2>&1 | grep "Failed to connect"
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index d309e82..5c48817 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -15,7 +15,7 @@ test -e LOCAL_LVMETAD || skip
 
 aux prepare_pvs 2
 
-vgcreate $vg1 $dev1 $dev2
+vgcreate $vg1 "$dev1" "$dev2"
 vgs | grep $vg1
 
 pvscan --cache
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index dd85bb6..449369d 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -73,5 +73,5 @@ not pvscan --cache "$dev1" 2>&1 | grep "not found"
 not pvscan --cache "$dev2" 2>&1 | grep "not found"
 
 pvs | grep $lvmdev
-pvs | not grep $dev1
-pvs | not grep $dev2
+pvs | not grep "$dev1"
+pvs | not grep "$dev2"
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index a235838..a3ba2cf 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -27,8 +27,8 @@ grep "Reducing stripe size" err
 
 lvremove -ff $vg
 
-lvcreate -L 10M -n lv $vg $dev1
-lvextend -L +10M $vg/lv $dev2
+lvcreate -L 10M -n lv $vg "$dev1"
+lvextend -L +10M $vg/lv "$dev2"
 
 # Attempt to reduce with lvextend and vice versa:
 not lvextend -L 16M $vg/lv
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 0e064ed..9022ff9 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -27,8 +27,8 @@ lv_devices_() {
 	devs=$(get lv_devices "$lv")
 
 	for d in $devs; do
-		(echo "$devices" | grep $d) || return 1
-		devices=$(echo $devices | sed "s/$d//")
+		(echo "$devices" | grep "$d") || return 1
+		devices=$(echo "$devices" | sed "s/$d//")
 	done
 
 	test -z "$(echo $devices | sed 's/ //g')"
diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
index ae9f8e5..93eb0bd 100644
--- a/test/shell/process-each-pv-nomda-all.sh
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -16,19 +16,19 @@ test_description='Test process_each_pv with zero mda'
 aux prepare_devs 14
 
 # for vg1
-pvcreate $dev10
+pvcreate "$dev10"
 
 # for vg2
-pvcreate $dev2 --metadatacopies 0
-pvcreate $dev3
-pvcreate $dev4
-pvcreate $dev5
+pvcreate "$dev2" --metadatacopies 0
+pvcreate "$dev3"
+pvcreate "$dev4"
+pvcreate "$dev5"
 
 # for vg3
-pvcreate $dev6 --metadatacopies 0
-pvcreate $dev7 --metadatacopies 0
-pvcreate $dev8 --metadatacopies 0
-pvcreate $dev9
+pvcreate "$dev6" --metadatacopies 0
+pvcreate "$dev7" --metadatacopies 0
+pvcreate "$dev8" --metadatacopies 0
+pvcreate "$dev9"
 
 # orphan with mda
 pvcreate "$dev11"
@@ -43,18 +43,18 @@ vgcreate $vg1 "$dev10"
 vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
 vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
-pvs -a >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-grep $dev12 err
-grep $dev13 err
-grep $dev14 err
+pvs -a | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+grep "$dev12" err
+grep "$dev13" err
+grep "$dev14" err
 
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index 10ce878..82e6bc4 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,13 +15,11 @@ test_description='Test process_each_pv with zero mda'
 
 aux prepare_devs 2
 
-pvcreate $dev1 --metadatacopies 0
-pvcreate $dev2
+pvcreate "$dev1" --metadatacopies 0
+pvcreate "$dev2"
 
 vgcreate $vg1 "$dev1" "$dev2"
 
-pvdisplay -a -C >err
-cat err
-grep $dev1 err
-grep $dev2 err
-
+pvdisplay -a -C | tee err
+grep "$dev1" err
+grep "$dev2" err
diff --git a/test/shell/process-each-pv.sh b/test/shell/process-each-pv.sh
index a24b80b..d3a1863 100644
--- a/test/shell/process-each-pv.sh
+++ b/test/shell/process-each-pv.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -66,340 +66,340 @@ pvcreate "$dev14"
 #
 
 # pv in vg
-pvdisplay -s $dev10 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev10" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # pv not in vg (one orphan)
-pvdisplay -s $dev11 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # dev is not a pv
-not pvdisplay -s $dev12 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -s "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # two pvs in different vgs
-pvdisplay -s $dev10 $dev2 >err
-grep $dev10 err
-grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev10" "$dev2" | tee err
+grep "$dev10" err
+grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # -a is invalid when used alone
-not pvdisplay -a >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -a | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one pv and one orphan
-pvdisplay -s $dev10 $dev11 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev10" "$dev11" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one pv and one dev (dev refers to a non-pv device)
-not pvdisplay -s $dev10 $dev12 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -s "$dev10" "$dev12" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one orphan and one dev
-not pvdisplay -s $dev11 $dev12 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -s "$dev11" "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # all pvs (pvs in vgs and orphan pvs)
-pvdisplay -s >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvdisplay -s | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # all devs (pvs in vgs, orphan pvs, and devs)
-pvdisplay -a -C >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-grep $dev12 err
-grep $dev13 err
-grep $dev14 err
+pvdisplay -a -C | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+grep "$dev12" err
+grep "$dev13" err
+grep "$dev14" err
 
 # pv and orphan and dev
-not pvdisplay -s $dev9 $dev11 $dev12 > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -s "$dev9" "$dev11" "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # -s option not allowed with -a -C
-not pvdisplay -s -a -C > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -s -a -C | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # pv and all (all ignored)
-pvdisplay -a -C $dev9 > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -a -C "$dev9" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # orphan and all (all ignored)
-pvdisplay -a -C $dev11 > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -a -C "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one tag
-pvdisplay -s @V2D3 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V2D3 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # two tags
-pvdisplay -s @V2D3 @V2D45 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V2D3 @V2D45 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and pv
-pvdisplay -s @V2D3 $dev4 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V2D3 "$dev4" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and orphan
-pvdisplay -s @V2D3 $dev11 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V2D3 "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and dev
-not pvdisplay -s @V2D3 $dev12 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvdisplay -s @V2D3 "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and all (all ignored)
-pvdisplay @V2D3 -a -C > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay @V2D3 -a -C | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and pv redundant
-pvdisplay -s @V2D3 $dev3 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V2D3 "$dev3" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 
 #
@@ -407,308 +407,308 @@ not grep $dev14 err
 #
 
 # pv in vg
-pvs $dev10 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev10" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # pv not in vg (one orphan)
-pvs $dev11 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # dev is not a pv
-not pvs $dev12 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvs "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # two pvs in different vgs
-pvs $dev10 $dev2 >err
-grep $dev10 err
-grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev10" "$dev2" | tee err
+grep "$dev10" err
+grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one pv and one orphan
-pvs $dev10 $dev11 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev10" "$dev11" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one pv and one dev
-not pvs $dev10 $dev12 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvs "$dev10" "$dev12" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one orphan and one dev
-not pvs $dev11 $dev12 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvs "$dev11" "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # all pvs (pvs in vgs and orphan pvs)
-pvs >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvs | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # all devs (pvs in vgs, orphan pvs, and devs)
-pvs -a >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-grep $dev12 err
-grep $dev13 err
-grep $dev14 err
+pvs -a | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+grep "$dev12" err
+grep "$dev13" err
+grep "$dev14" err
 
 # pv and orphan and dev
-not pvs $dev9 $dev11 $dev12 > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvs "$dev9" "$dev11" "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # pv and all (all ignored)
-pvs -a $dev9 > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs -a "$dev9" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # orphan and all (all ignored)
-pvs -a $dev11 > err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs -a "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # one tag
-pvs @V2D3 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V2D3 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # two tags
-pvs @V2D3 @V2D45 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V2D3 @V2D45 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and pv
-pvs @V2D3 $dev4 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V2D3 "$dev4" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and orphan
-pvs @V2D3 $dev11 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V2D3 "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and dev
-not pvs @V2D3 $dev12 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+not pvs @V2D3 "$dev12" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and all (all ignored)
-pvs @V2D3 -a > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V2D3 -a | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag and pv redundant
-pvs @V2D3 $dev3 > err
-not grep $dev10 err
-not grep $dev2 err
-grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V2D3 "$dev3" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 
 #
@@ -720,73 +720,73 @@ not vgreduce $vg2
 
 
 # fail with dev and -a
-not vgreduce $vg2 $dev2 -a
-check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+not vgreduce $vg2 "$dev2" -a
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 
 
 # remove one pv
-vgreduce $vg2 $dev2
-not check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+vgreduce $vg2 "$dev2"
+not check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev2
+vgextend $vg2 "$dev2"
 
 
 # remove two pvs
-vgreduce $vg2 $dev2 $dev3
-not check pv_field $dev2 vg_name $vg2
-not check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+vgreduce $vg2 "$dev2" "$dev3"
+not check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev2 $dev3
+vgextend $vg2 "$dev2" "$dev3"
 pvchange --addtag V2D3 "$dev3"
 
 
 # remove one pv with tag
 vgreduce $vg2 @V2D3
-check pv_field $dev2 vg_name $vg2
-not check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev3
+vgextend $vg2 "$dev3"
 pvchange --addtag V2D3 "$dev3"
 
 
 # remove two pvs, each with different tag
 vgreduce $vg2 @V2D3 @V2D4
-check pv_field $dev2 vg_name $vg2
-not check pv_field $dev3 vg_name $vg2
-not check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+not check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev3 $dev4
+vgextend $vg2 "$dev3" "$dev4"
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
 pvchange --addtag V2D45 "$dev4"
@@ -794,16 +794,16 @@ pvchange --addtag V2D45 "$dev4"
 
 # remove two pvs, both with same tag
 vgreduce $vg2 @V2D45
-check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-not check pv_field $dev4 vg_name $vg2
-not check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+not check pv_field "$dev4" vg_name $vg2
+not check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev4 $dev5
+vgextend $vg2 "$dev4" "$dev5"
 pvchange --addtag V2D4 "$dev4"
 pvchange --addtag V2D45 "$dev4"
 pvchange --addtag V2D5 "$dev5"
@@ -811,17 +811,17 @@ pvchange --addtag V2D45 "$dev5"
 
 
 # remove two pvs, one by name, one by tag
-vgreduce $vg2 $dev2 @V2D3
-not check pv_field $dev2 vg_name $vg2
-not check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+vgreduce $vg2 "$dev2" @V2D3
+not check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev2 $dev3
+vgextend $vg2 "$dev2" "$dev3"
 pvchange --addtag V2D3 "$dev3"
 
 
@@ -829,16 +829,16 @@ pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D5V3D9 "$dev5"
 pvchange --addtag V2D5V3D9 "$dev9"
 vgreduce $vg2 @V2D5V3D9
-check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-not check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+not check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev5
+vgextend $vg2 "$dev5"
 pvchange --addtag V2D5 "$dev5"
 pvchange --addtag V2D45 "$dev5"
 
@@ -857,18 +857,18 @@ pvchange --addtag V2D45 "$dev5"
 
 # lvcreate on one pv to make it used
 # remove all unused pvs
-lvcreate -n $lv1 -l 2 $vg2 $dev2
+lvcreate -n $lv1 -l 2 $vg2 "$dev2"
 not vgreduce -a $vg2
-check pv_field $dev2 vg_name $vg2
-not check pv_field $dev3 vg_name $vg2
-not check pv_field $dev4 vg_name $vg2
-not check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+not check pv_field "$dev4" vg_name $vg2
+not check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev3 $dev4 $dev5
+vgextend $vg2 "$dev3" "$dev4" "$dev5"
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
 pvchange --addtag V2D45 "$dev4"
@@ -886,25 +886,25 @@ lvremove $vg2/$lv1
 vgremove $vg1
 vgremove $vg2
 vgremove $vg3
-pvremove $dev11
-pvremove $dev14
+pvremove "$dev11"
+pvremove "$dev14"
 
 # new config with some pvs that have zero mdas
 
 # for vg1
-pvcreate $dev10
+pvcreate "$dev10"
 
 # for vg2
-pvcreate $dev2 --metadatacopies 0
-pvcreate $dev3
-pvcreate $dev4
-pvcreate $dev5
+pvcreate "$dev2" --metadatacopies 0
+pvcreate "$dev3"
+pvcreate "$dev4"
+pvcreate "$dev5"
 
 # for vg3
-pvcreate $dev6 --metadatacopies 0
-pvcreate $dev7 --metadatacopies 0
-pvcreate $dev8 --metadatacopies 0
-pvcreate $dev9
+pvcreate "$dev6" --metadatacopies 0
+pvcreate "$dev7" --metadatacopies 0
+pvcreate "$dev8" --metadatacopies 0
+pvcreate "$dev9"
 
 # orphan with mda
 pvcreate "$dev11"
@@ -935,296 +935,296 @@ pvchange --addtag V3D9 "$dev9"
 #
 
 # pv with mda
-pvdisplay -s $dev10 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev10" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # pv without mda
-pvdisplay -s $dev2 >err
-not grep $dev10 err
-grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev2" | tee err
+not grep "$dev10" err
+grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # orphan with mda
-pvdisplay -s $dev11 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # orphan without mda
-pvdisplay -s $dev14 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvdisplay -s "$dev14" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # pv with mda, pv without mda, orphan with mda, orphan without mda
-pvdisplay -s $dev10 $dev2 $dev11 $dev14 >err
-grep $dev10 err
-grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvdisplay -s "$dev10" "$dev2" "$dev11" "$dev14" | tee err
+grep "$dev10" err
+grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # tag refering to pv with mda and pv without mda
-pvdisplay -s @V3 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V3 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag refering to one pv without mda
-pvdisplay -s @V3D8 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvdisplay -s @V3D8 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # all pvs (pvs in vgs and orphan pvs)
-pvdisplay -s >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvdisplay -s | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # all devs (pvs in vgs, orphan pvs, and devs)
-pvdisplay -a -C >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-grep $dev12 err
-grep $dev13 err
-grep $dev14 err
+pvdisplay -a -C | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+grep "$dev12" err
+grep "$dev13" err
+grep "$dev14" err
 
 #
 # pvs including pvs without mdas
 #
 
 # pv with mda
-pvs $dev10 >err
-grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev10" | tee err
+grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # pv without mda
-pvs $dev2 >err
-not grep $dev10 err
-grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev2" | tee err
+not grep "$dev10" err
+grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # orphan with mda
-pvs $dev11 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs "$dev11" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # orphan without mda
-pvs $dev14 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvs "$dev14" | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # pv with mda, pv without mda, orphan with mda, orphan without mda
-pvs $dev10 $dev2 $dev11 $dev14 >err
-grep $dev10 err
-grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-not grep $dev8 err
-not grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvs "$dev10" "$dev2" "$dev11" "$dev14" | tee err
+grep "$dev10" err
+grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+not grep "$dev8" err
+not grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # tag refering to pv with mda and pv without mda
-pvs @V3 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V3 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # tag refering to one pv without mda
-pvs @V3D8 >err
-not grep $dev10 err
-not grep $dev2 err
-not grep $dev3 err
-not grep $dev4 err
-not grep $dev5 err
-not grep $dev6 err
-not grep $dev7 err
-grep $dev8 err
-not grep $dev9 err
-not grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-not grep $dev14 err
+pvs @V3D8 | tee err
+not grep "$dev10" err
+not grep "$dev2" err
+not grep "$dev3" err
+not grep "$dev4" err
+not grep "$dev5" err
+not grep "$dev6" err
+not grep "$dev7" err
+grep "$dev8" err
+not grep "$dev9" err
+not grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+not grep "$dev14" err
 
 # all pvs (pvs in vgs and orphan pvs)
-pvs >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-not grep $dev12 err
-not grep $dev13 err
-grep $dev14 err
+pvs | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+not grep "$dev12" err
+not grep "$dev13" err
+grep "$dev14" err
 
 # all devs (pvs in vgs, orphan pvs, and devs)
-pvs -a >err
-grep $dev10 err
-grep $dev2 err
-grep $dev3 err
-grep $dev4 err
-grep $dev5 err
-grep $dev6 err
-grep $dev7 err
-grep $dev8 err
-grep $dev9 err
-grep $dev11 err
-grep $dev12 err
-grep $dev13 err
-grep $dev14 err
+pvs -a | tee err
+grep "$dev10" err
+grep "$dev2" err
+grep "$dev3" err
+grep "$dev4" err
+grep "$dev5" err
+grep "$dev6" err
+grep "$dev7" err
+grep "$dev8" err
+grep "$dev9" err
+grep "$dev11" err
+grep "$dev12" err
+grep "$dev13" err
+grep "$dev14" err
 
 
 #
@@ -1232,54 +1232,52 @@ grep $dev14 err
 #
 
 # remove pv without mda
-vgreduce $vg2 $dev2
-not check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+vgreduce $vg2 "$dev2"
+not check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev2
+vgextend $vg2 "$dev2"
 
 # remove pv with mda and pv without mda
-vgreduce $vg2 $dev2 $dev3
-not check pv_field $dev2 vg_name $vg2
-not check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
+vgreduce $vg2 "$dev2" "$dev3"
+not check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
 # reset
-vgextend $vg2 $dev2
-vgextend $vg2 $dev3
+vgextend $vg2 "$dev2"
+vgextend $vg2 "$dev3"
 
 # fail to remove only pv with mda
-not vgreduce $vg3 $dev9
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
-check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
+not vgreduce $vg3 "$dev9"
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
 
 # remove by tag a pv without mda
 vgreduce $vg3 @V3D8
-check pv_field $dev6 vg_name $vg3
-check pv_field $dev7 vg_name $vg3
-not check pv_field $dev8 vg_name $vg3
-check pv_field $dev9 vg_name $vg3
-check pv_field $dev2 vg_name $vg2
-check pv_field $dev3 vg_name $vg2
-check pv_field $dev4 vg_name $vg2
-check pv_field $dev5 vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+not check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
 # reset
-vgextend $vg3 $dev8
-
-
+vgextend $vg3 "$dev8"
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index caa0890..02fe081 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -76,152 +76,152 @@ old_reduced="28.00m"
 new_request="20.00m"
 new_reduced="16.00m"
 
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 
 # one pv
-pvresize --setphysicalvolumesize $new_request $dev10
-check pv_field $dev10 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev10"
+check pv_field "$dev10" pv_size $new_reduced
 # unchanged
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # two pvs in separate vgs
-pvresize --setphysicalvolumesize $new_request $dev2 $dev6
-check pv_field $dev2 pv_size $new_reduced
-check pv_field $dev6 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev2" "$dev6"
+check pv_field "$dev2" pv_size $new_reduced
+check pv_field "$dev6" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on one pv
 pvresize --setphysicalvolumesize $new_request @V2D4
-check pv_field $dev4 pv_size $new_reduced
+check pv_field "$dev4" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on all pvs in one vg
 pvresize --setphysicalvolumesize $new_request @V3
-check pv_field $dev6 pv_size $new_reduced
-check pv_field $dev7 pv_size $new_reduced
-check pv_field $dev8 pv_size $new_reduced
-check pv_field $dev9 pv_size $new_reduced
+check pv_field "$dev6" pv_size $new_reduced
+check pv_field "$dev7" pv_size $new_reduced
+check pv_field "$dev8" pv_size $new_reduced
+check pv_field "$dev9" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on some pvs in one vg
 pvresize --setphysicalvolumesize $new_request @V2D45
-check pv_field $dev4 pv_size $new_reduced
-check pv_field $dev5 pv_size $new_reduced
+check pv_field "$dev4" pv_size $new_reduced
+check pv_field "$dev5" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on multiple pvs in separate vgs
 pvchange --addtag V12 "$dev10" "$dev2" "$dev3" "$dev4" "$dev5"
 pvresize --setphysicalvolumesize $new_request @V12
-check pv_field $dev10 pv_size $new_reduced
-check pv_field $dev2 pv_size $new_reduced
-check pv_field $dev3 pv_size $new_reduced
-check pv_field $dev4 pv_size $new_reduced
-check pv_field $dev5 pv_size $new_reduced
+check pv_field "$dev10" pv_size $new_reduced
+check pv_field "$dev2" pv_size $new_reduced
+check pv_field "$dev3" pv_size $new_reduced
+check pv_field "$dev4" pv_size $new_reduced
+check pv_field "$dev5" pv_size $new_reduced
 # unchanged
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one pv and one tag on different pv
-pvresize --setphysicalvolumesize $new_request $dev10 @V3D9
-check pv_field $dev10 pv_size $new_reduced
-check pv_field $dev9 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev10" @V3D9
+check pv_field "$dev10" pv_size $new_reduced
+check pv_field "$dev9" pv_size $new_reduced
 # unchanged
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # redundant pv and tag
-pvresize --setphysicalvolumesize $new_request $dev9 @V3D9
-check pv_field $dev9 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev9" @V3D9
+check pv_field "$dev9" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # two tags on pvs in separate vgs
 pvresize --setphysicalvolumesize $new_request @V3D9 @V2D3
-check pv_field $dev9 pv_size $new_reduced
-check pv_field $dev3 pv_size $new_reduced
+check pv_field "$dev9" pv_size $new_reduced
+check pv_field "$dev3" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 
 #
@@ -235,91 +235,91 @@ new_request="20.00m"
 new_reduced="16.00m"
 new_orphan="20.00m"
 
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 
 # one orphan
-pvresize --setphysicalvolumesize $new_request $dev11
-check pv_field $dev11 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request "$dev11"
+check pv_field "$dev11" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # two orphans
-pvresize --setphysicalvolumesize $new_request $dev11 $dev14
-check pv_field $dev11 pv_size $new_orphan
-check pv_field $dev14 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request "$dev11" "$dev14"
+check pv_field "$dev11" pv_size $new_orphan
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one orphan, one tag
-pvresize --setphysicalvolumesize $new_request @V3D9 $dev14
-check pv_field $dev9 pv_size $new_reduced
-check pv_field $dev14 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request @V3D9 "$dev14"
+check pv_field "$dev9" pv_size $new_reduced
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one pv, one orphan, one tag
-pvresize --setphysicalvolumesize $new_request @V3D9 $dev14 $dev10
-check pv_field $dev9 pv_size $new_reduced
-check pv_field $dev10 pv_size $new_reduced
-check pv_field $dev14 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request @V3D9 "$dev14" "$dev10"
+check pv_field "$dev9" pv_size $new_reduced
+check pv_field "$dev10" pv_size $new_reduced
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 
 #
@@ -327,235 +327,234 @@ pvresize --setphysicalvolumesize $old_request $dev11 $dev14
 #
 
 # one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request $dev13
+not pvresize --setphysicalvolumesize $new_request "$dev13"
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 
 # one orphan and one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request $dev14 $dev13
-check pv_field $dev14 pv_size $new_orphan
+not pvresize --setphysicalvolumesize $new_request "$dev14" "$dev13"
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one pv and one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request $dev9 $dev13
-check pv_field $dev9 pv_size $new_reduced
+not pvresize --setphysicalvolumesize $new_request "$dev9" "$dev13"
+check pv_field "$dev9" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one tag and one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request @V3D9 $dev13
-check pv_field $dev9 pv_size $new_reduced
+not pvresize --setphysicalvolumesize $new_request @V3D9 "$dev13"
+check pv_field "$dev9" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one pv, one orphan, one tag, one dev
-not pvresize --setphysicalvolumesize $new_request @V3D9 $dev13 $dev14 $dev10
-check pv_field $dev9 pv_size $new_reduced
-check pv_field $dev10 pv_size $new_reduced
-check pv_field $dev14 pv_size $new_orphan
+not pvresize --setphysicalvolumesize $new_request @V3D9 "$dev13" "$dev14" "$dev10"
+check pv_field "$dev9" pv_size $new_reduced
+check pv_field "$dev10" pv_size $new_reduced
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 
 #
 # pvresize including pvs without mdas
 #
 
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 
 # one pv without mda
-pvresize --setphysicalvolumesize $new_request $dev2
-check pv_field $dev2 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev2"
+check pv_field "$dev2" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # two pvs without mdas
-pvresize --setphysicalvolumesize $new_request $dev6 $dev7
-check pv_field $dev6 pv_size $new_reduced
-check pv_field $dev7 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev6" "$dev7"
+check pv_field "$dev6" pv_size $new_reduced
+check pv_field "$dev7" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one pv with mda and one pv without mda
-pvresize --setphysicalvolumesize $new_request $dev8 $dev9
-check pv_field $dev8 pv_size $new_reduced
-check pv_field $dev9 pv_size $new_reduced
+pvresize --setphysicalvolumesize $new_request "$dev8" "$dev9"
+check pv_field "$dev8" pv_size $new_reduced
+check pv_field "$dev9" pv_size $new_reduced
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one orphan with mda
-pvresize --setphysicalvolumesize $new_request $dev11
-check pv_field $dev11 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request "$dev11"
+check pv_field "$dev11" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev14 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one orphan without mda
-pvresize --setphysicalvolumesize $new_request $dev14
-check pv_field $dev14 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request "$dev14"
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
-check pv_field $dev11 pv_size $old_orphan
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
+check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one orphan with mda and one orphan without mda
-pvresize --setphysicalvolumesize $new_request $dev14 $dev11
-check pv_field $dev11 pv_size $new_orphan
-check pv_field $dev14 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request "$dev14" "$dev11"
+check pv_field "$dev11" pv_size $new_orphan
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
-check pv_field $dev8 pv_size $old_reduced
-check pv_field $dev9 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
+check pv_field "$dev8" pv_size $old_reduced
+check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 
 # one pv with mda and one pv without mda, and
 # one orphan with mda and one orphan without mda
-pvresize --setphysicalvolumesize $new_request $dev8 $dev9 $dev14 $dev11
-check pv_field $dev8 pv_size $new_reduced
-check pv_field $dev9 pv_size $new_reduced
-check pv_field $dev11 pv_size $new_orphan
-check pv_field $dev14 pv_size $new_orphan
+pvresize --setphysicalvolumesize $new_request "$dev8" "$dev9" "$dev14" "$dev11"
+check pv_field "$dev8" pv_size $new_reduced
+check pv_field "$dev9" pv_size $new_reduced
+check pv_field "$dev11" pv_size $new_orphan
+check pv_field "$dev14" pv_size $new_orphan
 # unchanged
-check pv_field $dev10 pv_size $old_reduced
-check pv_field $dev2 pv_size $old_reduced
-check pv_field $dev3 pv_size $old_reduced
-check pv_field $dev4 pv_size $old_reduced
-check pv_field $dev5 pv_size $old_reduced
-check pv_field $dev6 pv_size $old_reduced
-check pv_field $dev7 pv_size $old_reduced
+check pv_field "$dev10" pv_size $old_reduced
+check pv_field "$dev2" pv_size $old_reduced
+check pv_field "$dev3" pv_size $old_reduced
+check pv_field "$dev4" pv_size $old_reduced
+check pv_field "$dev5" pv_size $old_reduced
+check pv_field "$dev6" pv_size $old_reduced
+check pv_field "$dev7" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request $dev10 $dev2 $dev3 $dev4 $dev5 $dev6 $dev7 $dev8 $dev9
-pvresize --setphysicalvolumesize $old_request $dev11 $dev14
-
+pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 72ab16b..e5695b6 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -20,7 +20,7 @@ check_changed_uuid_() {
 aux prepare_pvs 4
 
 # check 'allocatable' pv attribute
-pvcreate $dev1
+pvcreate "$dev1"
 check pv_field "$dev1" pv_attr ---
 vgcreate $vg1 "$dev1"
 check pv_field "$dev1" pv_attr a--
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 42349e4..53a9839 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -27,7 +27,7 @@ check pv_field "$dev1" ba_size "786432"
 check pv_field "$dev1" pe_start "1048576"
 
 #COMM 'pvcreate with booloader area size - test corner cases'
-dev_size=$(pvs -o pv_size --noheadings $dev1)
+dev_size=$(pvs -o pv_size --noheadings "$dev1")
 pv_size=$[dev_size - 1048576] # device size - 1m pe_start = area for data
 
 # try to use the whole data area for bootloader area, remaining data area is zero then (pe_start = pv_size)
diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index 8f59301..590c77b 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -19,7 +19,7 @@ for mode in "--atomic" ""
 do
 lvcreate -aey -l1 -n $lv1 $vg "$dev1"
 
-lvs -o +devices | grep $dev1
+lvs -o +devices | grep "$dev1"
 pvmove $mode -i 1 -b "$dev1" "$dev2"
 sleep 5 # arbitrary...
 lvs -o +devices | not grep "pvmove"
diff --git a/test/shell/report-select.sh b/test/shell/report-select.sh
index fb12bd6..11a4efd 100644
--- a/test/shell/report-select.sh
+++ b/test/shell/report-select.sh
@@ -19,13 +19,13 @@ aux prepare_pvs 6 16
 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
 # create $VGS with assorted tags
-vgcreate $vg1 --vgmetadatacopies 2 --addtag "vg_tag3" --addtag "vg_tag2" -s 4m $dev1 $dev2 $dev3
-vgcreate $vg2 --addtag "vg_tag2" -s 4m $dev4 $dev5
-vgcreate $vg3 --addtag "vg_tag1" -s 4m $dev6
+vgcreate $vg1 --vgmetadatacopies 2 --addtag "vg_tag3" --addtag "vg_tag2" -s 4m "$dev1" "$dev2" "$dev3"
+vgcreate $vg2 --addtag "vg_tag2" -s 4m "$dev4" "$dev5"
+vgcreate $vg3 --addtag "vg_tag1" -s 4m "$dev6"
 
 # add PV assorted tags
-pvchange --addtag "pv_tag3" --addtag "pv_tag1" --addtag "pv_tag2" $dev1
-pvchange --addtag "pv_tag1" --addtag "pv_tag4" $dev6
+pvchange --addtag "pv_tag3" --addtag "pv_tag1" --addtag "pv_tag2" "$dev1"
+pvchange --addtag "pv_tag1" --addtag "pv_tag4" "$dev6"
 
 # create $LVS with assorted tags and various sizes
 lvcreate --addtag 'lv_tag2.-+/=!:&#' --addtag "lv_tag1" -L8m -n "vol1" $vg1


