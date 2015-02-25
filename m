From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 20:59:16 +0000 (UTC)
Subject: master - tests: add more systemid tests
Message-ID: <20150225205916.7D65F60D6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebb2205b4c56aa99cb77939eff396665c47f082d
Commit:        ebb2205b4c56aa99cb77939eff396665c47f082d
Parent:        dd6a2028316febc4a44785c1cacacea0e53f8f76
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 12:23:34 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 14:58:49 2015 -0600

tests: add more systemid tests

---
 test/shell/system_id.sh |   71 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 3312ab6..5327153 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -380,11 +380,69 @@ rm -f $SIDFILE
 
 # pvs: pv in a foreign vg not reported
 # pvs --foreign: pv in a foreign vg is reported
-# TODO
+
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg
+vgcreate $vg1 "$dev1"
+# normal pvs sees the vg and pv
+pvs >err
+grep $vg1 err
+grep $dev1 err
+# change the local system_id, making the vg foreign
+echo "$SID2" > $SIDFILE
+# normal pvs does not see the vg or pv
+pvs >err
+not grep $vg1 err
+not grep $dev1 err
+# pvs --foreign does see the vg and pv
+pvs --foreign >err
+grep $vg1 err
+grep $dev1 err
+# change the local system_id back so the vg can be removed
+echo "$SID1" > $SIDFILE
+vgremove $vg1
+rm -f $SIDFILE
 
 # lvs: lvs in a foreign vg not reported
 # lvs --foreign: lvs in a foreign vg are reported
-# TODO
+
+SID1=sidfoofile1
+SID2=sidfoofile2
+SIDFILE=etc/lvm_test.conf
+rm -f $SIDFILE
+echo "$SID1" > $SIDFILE
+aux lvmconf "global/system_id_source = file"
+aux lvmconf "global/system_id_file = $SIDFILE"
+# create a vg
+vgcreate $vg1 "$dev1"
+lvcreate -n $lv1 -l 2 $vg1
+lvchange -an $vg1/$lv1
+# normal lvs sees the vg and lv
+lvs >err
+grep $vg1 err
+grep $lv1 err
+# change the local system_id, making the vg foreign
+echo "$SID2" > $SIDFILE
+# normal lvs does not see the vg or lv
+lvs >err
+not grep $vg1 err
+not grep $lv1 err
+# lvs --foreign does see the vg and lv
+lvs --foreign >err
+grep $vg1 err
+grep $lv1 err
+# change the local system_id back so the vg can be removed
+echo "$SID1" > $SIDFILE
+lvremove $vg1/$lv1
+vgremove $vg1
+rm -f $SIDFILE
+
 
 # use extra_system_ids to read a foreign VG
 # TODO
@@ -418,3 +476,12 @@ rm -f $SIDFILE
 # TODO
 
 
+# --systemid "" equals none
+# TODO
+
+
+# vgcfgbackup --foreign vg
+# TODO
+
+
+


