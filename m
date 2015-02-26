From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 26 Feb 2015 19:22:13 +0000 (UTC)
Subject: master - tests: more system_id tests
Message-ID: <20150226192213.628706021A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66d074e913d61bd9e5fa7cc67f25f90b4608b071
Commit:        66d074e913d61bd9e5fa7cc67f25f90b4608b071
Parent:        b5394c8f260d091b7a41d78e3dbae32f90386cc4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 26 13:22:47 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 26 13:23:22 2015 -0600

tests: more system_id tests

---
 test/shell/system_id.sh |  297 ++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 284 insertions(+), 13 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 3ef3e8b..6e80c1a 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -552,39 +552,310 @@ echo "$SID1" > $SIDFILE
 vgremove $vg1
 rm -f $SIDFILE
 
+# vgcfgbackup backs up foreign vg with --foreign
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $LVMLOCAL
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg
+vgcreate $vg1 "$dev1"
+# normal vgs sees the vg
+vgs >err
+grep $vg1 err
+# change the local system_id, making the vg foreign
+echo "$SID2" > $SIDFILE
+# normal vgs doesn't see the vg
+vgs >err
+not grep $vg1 err
+# using --foreign we can back up the vg
+not vgcfgbackup $vg1
+vgcfgbackup --foreign $vg1
+# change our system_id back so we can remove the vg
+echo "$SID1" > $SIDFILE
+vgremove $vg1
+rm -f $SIDFILE
+
+
 
 # Test handling of bad system_id source configurations
 # The commands should proceed without a system_id.
 # Look at the warning/error messages.
 
 # vgcreate with source machineid, where no /etc/machine-id file exists
-# TODO
+if [ ! -e /etc/machine-id ]; then
+SID=""
+aux lvmconf "global/system_id_source = machineid"
+vgcreate $vg1 "$dev1" |& tee err
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID
+grep "No system ID found from system_id_source" err
+vgremove $vg1
+fi
 
 # vgcreate with source uname, but uname is localhost
-# TODO
+# TODO: don't want to change the hostname on the test machine...
 
 # vgcreate with source lvmlocal, but no lvmlocal.conf file
+SID=""
+rm -f $LVMLOCAL
+aux lvmconf "global/system_id_source = lvmlocal"
+vgcreate $vg1 "$dev1" |& tee err
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID
+grep "No system ID found from system_id_source" err
+vgremove $vg1
+rm -f $LVMLOCAL
+
 # vgcreate with source lvmlocal, but no system_id = "x" entry
-# TODO
+SID=""
+LVMLOCAL=etc/lvmlocal.conf
+rm -f $LVMLOCAL
+echo "local {" > $LVMLOCAL
+# echo "  system_id = $SID" >> $LVMLOCAL
+echo "}" >> $LVMLOCAL
+aux lvmconf "global/system_id_source = lvmlocal"
+vgcreate $vg1 "$dev1" |& tee err
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID
+grep "No system ID found from system_id_source" err
+vgremove $vg1
+rm -f $LVMLOCAL
+
+# vgcreate with source lvmlocal, and empty string system_id = ""
+SID=""
+LVMLOCAL=etc/lvmlocal.conf
+rm -f $LVMLOCAL
+echo "local {" > $LVMLOCAL
+echo "  system_id = \"\"" >> $LVMLOCAL
+echo "}" >> $LVMLOCAL
+aux lvmconf "global/system_id_source = lvmlocal"
+vgcreate $vg1 "$dev1" |& tee err
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID
+grep "No system ID found from system_id_source" err
+vgremove $vg1
+rm -f $LVMLOCAL
 
 # vgcreate with source file, but no system_id_file config
+SID=""
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+aux lvmconf "global/system_id_source = file"
+vgcreate $vg1 "$dev1" |& tee err
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID
+grep "No system ID found from system_id_source" err
+vgremove $vg1
+rm -f $SIDFILE
+
 # vgcreate with source file, but system_id_file does not exist
-# TODO
+SID=""
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+vgcreate $vg1 "$dev1" |& tee err
+vgs -o+systemid $vg1
+check vg_field $vg1 systemid $SID
+grep "No system ID found from system_id_source" err
+vgremove $vg1
+rm -f $SIDFILE
 
 
 # Test cases where lvmetad cache of a foreign VG are out of date
 # because the foreign owner has changed the VG.
-# . Using the --foreign option should update the cache and produce
-#   correct output
-# . Using vgimport should see that the VG is no longer foreign,
-#   but has been exported.
-# . pvscan --cache, vgscan --cache should cause the latest
-#   version of a foreign VG to be cached in lvmetad.
-# TODO
 
+test ! -e LOCAL_LVMETAD && exit 0
+
+# When a foreign vg is newer on disk than in lvmetad, using --foreign
+# should find the newer version.  This simulates a foreign host changing
+# foreign vg by turning off lvmetad when we create an lv in the vg.
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg with an lv
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l 2 -an $vg1
+# normal vgs sees the vg and lv
+vgs >err
+grep $vg1 err
+check lv_exists $vg1 $lv1
+# go around lvmetad to create another lv in the vg,
+# forcing the lvmetad copy to be older than on disk.
+aux lvmconf 'global/use_lvmetad = 0'
+lvcreate -n $lv2 -l 2 -an $vg1
+aux lvmconf 'global/use_lvmetad = 1'
+# verify that the second lv is not in lvmetad
+lvs $vg1 >err
+grep $lv1 err
+not grep $lv2 err
+# change our system_id, making the vg foreign
+echo "$SID2" > $SIDFILE
+vgs >err
+not grep $vg1 err
+# using --foreign, we will get the latest vg from disk
+lvs --foreign $vg1 >err
+grep $vg1 err
+grep $lv1 err
+grep $lv2 err
+# change our system_id back to match the vg so it's not foreign
+echo "$SID1" > $SIDFILE
+lvremove $vg1/$lv1
+lvremove $vg1/$lv2
+vgremove $vg1
+rm -f $SIDFILE
+
+# vgimport should find the exported vg on disk even though
+# lvmetad's copy of the vg shows it's foreign.
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg with an lv
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l 2 -an $vg1
+# normal vgs sees the vg and lv
+vgs >err
+grep $vg1 err
+check lv_exists $vg1 $lv1
+# go around lvmetad to export the vg so that lvmetad still
+# has the original vg owned by SID1 in its cache
+aux lvmconf 'global/use_lvmetad = 0'
+vgexport $vg1
+aux lvmconf 'global/use_lvmetad = 1'
+# change the local system_id so the lvmetad copy of the vg is foreign
+echo "$SID2" > $SIDFILE
+# verify that lvmetad thinks the vg is foreign
+# (don't use --foreign to verify this because that will cause
+# the lvmetad cache to be updated, which we don't want yet)
+not vgs $vg1
+# attempt to import the vg that has been exported, but
+# which lvmetad thinks is foreign
+vgimport $vg1
+# verify that the imported vg has our system_id
+vgs -o+systemid $vg1 >err
+grep $vg1 err
+grep $SID2 err
+check lv_exists $vg1 $lv1
+lvremove $vg1/$lv1
+vgremove $vg1
+rm -f $SIDFILE
 
-# vgcfgbackup --foreign vg
-# TODO
+# pvscan --cache should cause the latest version of a foreign VG to be
+# cached in lvmetad.  Without the --cache option, pvscan will see the old
+# version of the VG.
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg with an lv
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l 2 -an $vg1
+# normal vgs sees the vg and lv
+vgs >err
+grep $vg1 err
+check lv_exists $vg1 $lv1
+# go around lvmetad to create another lv in the vg,
+# forcing the lvmetad copy to be older than on disk.
+aux lvmconf 'global/use_lvmetad = 0'
+lvcreate -n $lv2 -l 2 -an $vg1
+aux lvmconf 'global/use_lvmetad = 1'
+# verify that the second lv is not in lvmetad
+lvs $vg1 >err
+grep $lv1 err
+not grep $lv2 err
+# verify that after pvscan without --cache, lvmetad still
+# reports the old version
+pvscan
+lvs $vg1 >err
+grep $lv1 err
+not grep $lv2 err
+# change our system_id, making the vg foreign
+echo "$SID2" > $SIDFILE
+not vgs $vg1 >err
+not grep $vg1 err
+# use pvscan --cache to update the foreign vg in lvmetad
+pvscan --cache
+not vgs $vg1 >err
+not grep $vg1 err
+# change our system_id back to SID1 so we can check that
+# lvmetad has the latest copy of the vg (without having
+# to use --foreign to check)
+echo "$SID1" > $SIDFILE
+vgs $vg1 >err
+grep $vg1 err
+lvs $vg1 >err
+grep $lv1 err
+grep $lv2 err
+lvremove $vg1/$lv1
+lvremove $vg1/$lv2
+vgremove $vg1
+rm -f $SIDFILE
 
+# repeat the same test for vgscan instead of pvscan
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg with an lv
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l 2 -an $vg1
+# normal vgs sees the vg and lv
+vgs >err
+grep $vg1 err
+check lv_exists $vg1 $lv1
+# go around lvmetad to create another lv in the vg,
+# forcing the lvmetad copy to be older than on disk.
+aux lvmconf 'global/use_lvmetad = 0'
+lvcreate -n $lv2 -l 2 -an $vg1
+aux lvmconf 'global/use_lvmetad = 1'
+# verify that the second lv is not in lvmetad
+lvs $vg1 >err
+grep $lv1 err
+not grep $lv2 err
+# verify that after vgscan without --cache, lvmetad still
+# reports the old version
+vgscan
+lvs $vg1 >err
+grep $lv1 err
+not grep $lv2 err
+# change our system_id, making the vg foreign
+echo "$SID2" > $SIDFILE
+not vgs $vg1 >err
+not grep $vg1 err
+# use vgscan --cache to update the foreign vg in lvmetad
+vgscan --cache
+not vgs $vg1 >err
+not grep $vg1 err
+# change our system_id back to SID1 so we can check that
+# lvmetad has the latest copy of the vg (without having
+# to use --foreign to check)
+echo "$SID1" > $SIDFILE
+vgs $vg1 >err
+grep $vg1 err
+lvs $vg1 >err
+grep $lv1 err
+grep $lv2 err
+lvremove $vg1/$lv1
+lvremove $vg1/$lv2
+vgremove $vg1
+rm -f $SIDFILE
 
 


