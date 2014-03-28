From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 28 Mar 2014 09:42:13 +0000 (UTC)
Subject: master - tests: expect failing pvs when missing PV
Message-ID: <20140328094213.12A88613AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09b180cfc252f1446fecc7b09672191043a7feb0
Commit:        09b180cfc252f1446fecc7b09672191043a7feb0
Parent:        88a9705222d728d0989c1b4d9aac89ce22c0284b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 10:37:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 10:41:59 2014 +0100

tests: expect failing pvs when missing PV

---
 test/shell/lvmcache-exercise.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 682d582..1e4b86a 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -20,7 +20,8 @@ aux disable_dev "$dev1"
 pvscan
 vgcreate $vg1 "$dev2"
 aux enable_dev "$dev1"
-pvs $(cat DEVICES)
+# dev1 is missing
+fail pvs $(cat DEVICES)
 
 # reappearing device (rhbz 995440)
 lvcreate -aey -m2 --type mirror -l4 --alloc anywhere --corelog -n $lv1 $vg2
@@ -30,7 +31,7 @@ lvconvert --yes --repair $vg2/$lv1
 aux enable_dev "$dev3"
 
 # here it should fix any reappeared devices
-lvs $vg1 $vg1
+lvs $vg1 $vg2
 
 lvs -a $vg2 -o+devices 2>&1 | tee out
 not grep reappeared out


