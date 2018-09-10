From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Sep 2018 15:08:59 -0400
Subject: master - tests: drop lvmetad parts of system_id test
Message-ID: <201809101908.w8AJ8wlm005924@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b070c14a8b70dd8b8f4f3393e22ea9f1c584de76
Commit:        b070c14a8b70dd8b8f4f3393e22ea9f1c584de76
Parent:        3bcc6c7e6064bd9632557f9678d9d88526d9bbdc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 10 14:08:27 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 10 14:08:27 2018 -0500

tests: drop lvmetad parts of system_id test

---
 test/shell/system_id.sh |  192 -----------------------------------------------
 1 files changed, 0 insertions(+), 192 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index c3fc311..8814d54 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -27,22 +27,6 @@ aux prepare_devs 1
 SIDFILE="etc/lvm_test.conf"
 LVMLOCAL="etc/lvmlocal.conf"
 
-# with clvm enabled, vgcreate with no -c option creates a clustered vg,
-# which should have no system id
-
-if [ -e LOCAL_CLVMD ]; then
-SID1=sidfoolocal
-SID2=""
-print_lvmlocal "  system_id = $SID1"
-aux lvmconf "global/system_id_source = lvmlocal"
-vgcreate $vg1 "$dev1"
-vgs -o+systemid $vg1
-check vg_field $vg1 systemid "$SID2"
-vgremove $vg1
-rm -f "$LVMLOCAL"
-exit 0
-fi
-
 # create vg with system_id using each source
 
 ## none
@@ -596,179 +580,3 @@ check vg_field $vg1 systemid "$SID"
 grep "No system ID found from system_id_source" err
 vgremove $vg1
 
-
-# When a foreign vg is newer on disk than in lvmetad, using --foreign
-# should find the newer version.  This simulates a foreign host changing
-# foreign vg by turning off lvmetad when we create an lv in the vg.
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-# create a vg with an lv
-vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l 2 -an $vg1
-# normal vgs sees the vg and lv
-vgs >err
-grep $vg1 err
-check lv_exists $vg1 $lv1
-# go around lvmetad to create another lv in the vg,
-# forcing the lvmetad copy to be older than on disk.
-aux lvmconf 'global/use_lvmetad = 0'
-lvcreate -n $lv2 -l 2 -an $vg1
-aux lvmconf 'global/use_lvmetad = 1'
-# verify that the second lv is not in lvmetad
-lvs $vg1 >err
-grep $lv1 err
-not grep $lv2 err
-# change our system_id, making the vg foreign
-echo "$SID2" > "$SIDFILE"
-vgs >err
-not grep $vg1 err
-# using --foreign, we will get the latest vg from disk
-lvs --foreign $vg1 >err
-grep $vg1 err
-grep $lv1 err
-grep $lv2 err
-# change our system_id back to match the vg so it's not foreign
-echo "$SID1" > "$SIDFILE"
-lvremove $vg1/$lv1
-lvremove $vg1/$lv2
-vgremove $vg1
-
-# vgimport should find the exported vg on disk even though
-# lvmetad's copy of the vg shows it's foreign.
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-# create a vg with an lv
-vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l 2 -an $vg1
-# normal vgs sees the vg and lv
-vgs >err
-grep $vg1 err
-check lv_exists $vg1 $lv1
-# go around lvmetad to export the vg so that lvmetad still
-# has the original vg owned by SID1 in its cache
-aux lvmconf 'global/use_lvmetad = 0'
-vgexport $vg1
-aux lvmconf 'global/use_lvmetad = 1'
-# change the local system_id so the lvmetad copy of the vg is foreign
-echo "$SID2" > "$SIDFILE"
-# verify that lvmetad thinks the vg is foreign
-# (don't use --foreign to verify this because that will cause
-# the lvmetad cache to be updated, which we don't want yet)
-not vgs $vg1
-# attempt to import the vg that has been exported, but
-# which lvmetad thinks is foreign
-vgimport $vg1
-# verify that the imported vg has our system_id
-vgs -o+systemid $vg1 >err
-grep $vg1 err
-grep $SID2 err
-check lv_exists $vg1 $lv1
-lvremove $vg1/$lv1
-vgremove $vg1
-rm -f "$SIDFILE"
-
-# pvscan --cache should cause the latest version of a foreign VG to be
-# cached in lvmetad.  Without the --cache option, pvscan will see the old
-# version of the VG.
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-# create a vg with an lv
-vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l 2 -an $vg1
-# normal vgs sees the vg and lv
-vgs >err
-grep $vg1 err
-check lv_exists $vg1 $lv1
-# go around lvmetad to create another lv in the vg,
-# forcing the lvmetad copy to be older than on disk.
-aux lvmconf 'global/use_lvmetad = 0'
-lvcreate -n $lv2 -l 2 -an $vg1
-aux lvmconf 'global/use_lvmetad = 1'
-# verify that the second lv is not in lvmetad
-lvs $vg1 >err
-grep $lv1 err
-not grep $lv2 err
-# verify that after pvscan without --cache, lvmetad still
-# reports the old version
-pvscan
-lvs $vg1 >err
-grep $lv1 err
-not grep $lv2 err
-# change our system_id, making the vg foreign
-echo "$SID2" > "$SIDFILE"
-not vgs $vg1 >err
-not grep $vg1 err
-# use pvscan --cache to update the foreign vg in lvmetad
-pvscan --cache
-not vgs $vg1 >err
-not grep $vg1 err
-# change our system_id back to SID1 so we can check that
-# lvmetad has the latest copy of the vg (without having
-# to use --foreign to check)
-echo "$SID1" > "$SIDFILE"
-vgs $vg1 >err
-grep $vg1 err
-lvs $vg1 >err
-grep $lv1 err
-grep $lv2 err
-lvremove $vg1/$lv1
-lvremove $vg1/$lv2
-vgremove $vg1
-
-# repeat the same test for vgscan instead of pvscan
-SID1=sidfoofile1
-SID2=sidfoofile2
-echo "$SID1" > "$SIDFILE"
-aux lvmconf "global/system_id_source = file" \
-	    "global/system_id_file = \"$SIDFILE\""
-# create a vg with an lv
-vgcreate $vg1 "$dev1"
-lvcreate -n $lv1 -l 2 -an $vg1
-# normal vgs sees the vg and lv
-vgs >err
-grep $vg1 err
-check lv_exists $vg1 $lv1
-# go around lvmetad to create another lv in the vg,
-# forcing the lvmetad copy to be older than on disk.
-aux lvmconf 'global/use_lvmetad = 0'
-lvcreate -n $lv2 -l 2 -an $vg1
-aux lvmconf 'global/use_lvmetad = 1'
-# verify that the second lv is not in lvmetad
-lvs $vg1 >err
-grep $lv1 err
-not grep $lv2 err
-# verify that after vgscan without --cache, lvmetad still
-# reports the old version
-vgscan
-lvs $vg1 >err
-grep $lv1 err
-not grep $lv2 err
-# change our system_id, making the vg foreign
-echo "$SID2" > "$SIDFILE"
-not vgs $vg1 >err
-not grep $vg1 err
-# use vgscan --cache to update the foreign vg in lvmetad
-vgscan --cache
-not vgs $vg1 >err
-not grep $vg1 err
-# change our system_id back to SID1 so we can check that
-# lvmetad has the latest copy of the vg (without having
-# to use --foreign to check)
-echo "$SID1" > "$SIDFILE"
-vgs $vg1 >err
-grep $vg1 err
-lvs $vg1 >err
-grep $lv1 err
-grep $lv2 err
-lvremove $vg1/$lv1
-lvremove $vg1/$lv2
-vgremove $vg1


