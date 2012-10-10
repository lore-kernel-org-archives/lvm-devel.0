From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:23:07 +0000 (UTC)
Subject: master - test: drop clustered flag control from thin tests
Message-ID: <20121010192307.689B3AB3C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=876514eb34d3b67cb1063ea2feca49a76be65229
Commit:        876514eb34d3b67cb1063ea2feca49a76be65229
Parent:        d4eded9fd6686310ea653da889f40dbe8358f244
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 10 19:00:46 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 21:22:12 2012 +0200

test: drop clustered flag control from thin tests

---
 test/shell/discards-thin.sh      |    5 +----
 test/shell/lvconvert-thin.sh     |    5 +----
 test/shell/lvcreate-thin-snap.sh |    5 +----
 test/shell/lvcreate-thin.sh      |    5 +----
 4 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 4aa4293..84688b4 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -22,10 +22,7 @@ aux have_thin 1 1 0 || skip
 
 aux prepare_pvs 2 64
 
-clustered=
-test -e LOCAL_CLVMD && clustered="--clustered y"
-
-vgcreate $clustered $vg -s 64K $(cat DEVICES)
+vgcreate $vg -s 64K $(cat DEVICES)
 
 # Create named pool only
 lvcreate -l1 --discards ignore -T $vg/pool
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 32661cd..29beb93 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -19,10 +19,7 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 4 64
 
-clustered=
-test -e LOCAL_CLVMD && clustered="--clustered y"
-
-vgcreate $clustered $vg -s 64K $(cat DEVICES)
+vgcreate $vg -s 64K $(cat DEVICES)
 
 # create mirrored LVs for data and metadata volumes
 lvcreate -l8 -m1 --mirrorlog core -n $lv1 $vg
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 18846e3..23f91f9 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -30,10 +30,7 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 2 64
 
-clustered=
-test -e LOCAL_CLVMD && clustered="--clustered y"
-
-vgcreate $clustered $vg -s 64K $(cat DEVICES)
+vgcreate $vg -s 64K $(cat DEVICES)
 
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 8ad552b..6f60976 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -33,10 +33,7 @@ aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 2 64
 
-clustered=
-test -e LOCAL_CLVMD && clustered="--clustered y"
-
-vgcreate $clustered $vg -s 64K $(cat DEVICES)
+vgcreate $vg -s 64K $(cat DEVICES)
 
 # Create named pool only
 lvcreate -l1 -T $vg/pool1


