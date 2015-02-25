From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 22:12:53 +0000 (UTC)
Subject: master - tests: add more system_id tests
Message-ID: <20150225221253.0B69960F4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efd7480de3c1be4c0e7fe2508158dce930bc2c7c
Commit:        efd7480de3c1be4c0e7fe2508158dce930bc2c7c
Parent:        1248f94a429faa245968a9efe04250f27a53bc18
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 16:13:28 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 16:13:28 2015 -0600

tests: add more system_id tests

---
 test/shell/system_id.sh |  115 ++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 109 insertions(+), 6 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 43d1203..3ef3e8b 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -443,9 +443,114 @@ lvremove $vg1/$lv1
 vgremove $vg1
 rm -f $SIDFILE
 
-
 # use extra_system_ids to read a foreign VG
-# TODO
+
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+LVMLOCAL=etc/lvmlocal.conf
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
+# using --foreign we can see the vg
+vgs --foreign >err
+grep $vg1 err
+# add the first system_id to extra_system_ids so we can see the vg
+echo "local {" > $LVMLOCAL
+echo "  extra_system_ids = [ $SID1" ] >> $LVMLOCAL
+echo "}" >> $LVMLOCAL
+vgs >err
+grep $vg1 err
+vgremove $vg1
+rm -f $SIDFILE
+rm -f $LVMLOCAL
+
+# vgcreate --systemid "" creates a vg without a system_id even if source is set
+SID1=sidfoofile1
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg
+vgcreate --systemid "" $vg1 "$dev1"
+# normal vgs sees the vg
+vgs >err
+grep $vg1 err
+# our system_id is not displayed for the vg
+vgs -o+systemid >err
+not grep $SID1 err
+vgremove $vg1
+rm -f $SIDFILE
+
+# vgchange --systemid "" clears the system_id on owned vg
+SID1=sidfoofile1
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg
+vgcreate $vg1 "$dev1"
+# normal vgs sees the vg
+vgs >err
+grep $vg1 err
+# the vg has our system_id
+vgs -o+systemid >err
+grep $SID1 err
+# clear the system_id
+vgchange --yes --systemid "" $vg1
+# normal vgs sees the vg
+vgs >err
+grep $vg1 err
+# the vg does not have our system_id
+vgs -o+systemid >err
+not grep $SID1 err
+vgremove $vg1
+rm -f $SIDFILE
+
+# vgchange --systemid does not set the system_id on foreign vg
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
+# using --foreign we can see the vg
+vgs --foreign >err
+grep $vg1 err
+# cannot clear the system_id of the foreign vg
+not vgchange --yes --systemid "" $vg1
+# cannot set the system_id of the foreign vg
+not vgchange --yes --systemid foo $vg1
+# change our system_id back so we can remove the vg
+echo "$SID1" > $SIDFILE
+vgremove $vg1
+rm -f $SIDFILE
 
 
 # Test handling of bad system_id source configurations
@@ -473,10 +578,8 @@ rm -f $SIDFILE
 #   correct output
 # . Using vgimport should see that the VG is no longer foreign,
 #   but has been exported.
-# TODO
-
-
-# --systemid "" equals none
+# . pvscan --cache, vgscan --cache should cause the latest
+#   version of a foreign VG to be cached in lvmetad.
 # TODO
 
 


