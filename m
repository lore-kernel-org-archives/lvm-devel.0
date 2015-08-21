From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 21 Aug 2015 20:27:08 +0000 (UTC)
Subject: master - test: allow tests with lvmlockd
Message-ID: <20150821202708.77D7360DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d310e1f90720e5ba387efe7ba0d7cc6266d9f844
Commit:        d310e1f90720e5ba387efe7ba0d7cc6266d9f844
Parent:        81d4c4a84c92f7db8f79a17aced4fb3b86f86aa8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 20 16:09:29 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 21 15:09:38 2015 -0500

test: allow tests with lvmlockd

---
 test/shell/process-each-pv-nomda-all.sh |   10 +++++-----
 test/shell/process-each-pv-nomda.sh     |    6 +++---
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
index 1a2af58..972bb85 100644
--- a/test/shell/process-each-pv-nomda-all.sh
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -13,8 +13,6 @@ test_description='Test process_each_pv with zero mda'
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 14
 
 # for vg1
@@ -41,9 +39,9 @@ pvcreate "$dev14" --metadatacopies 0
 # dev12
 # dev13
 
-vgcreate $vg1 "$dev10"
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+vgcreate $SHARED $vg1 "$dev10"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
 pvs -a | tee err
 grep "$dev10" err
@@ -59,3 +57,5 @@ grep "$dev11" err
 grep "$dev12" err
 grep "$dev13" err
 grep "$dev14" err
+
+vgremove $vg1 $vg2 $vg3
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index 642f2e4..13fddb3 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -13,15 +13,15 @@ test_description='Test process_each_pv with zero mda'
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 2
 
 pvcreate "$dev1" --metadatacopies 0
 pvcreate "$dev2"
 
-vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $SHARED $vg1 "$dev1" "$dev2"
 
 pvdisplay -a -C | tee err
 grep "$dev1" err
 grep "$dev2" err
+
+vgremove $vg1


