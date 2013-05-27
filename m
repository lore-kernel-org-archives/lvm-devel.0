From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 27 May 2013 00:14:05 +0000 (UTC)
Subject: dev-mornfall-nix - test: Make filter extension more robust and composable.
Message-ID: <20130527001405.7C8C161424@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b71acdcdaf36f0456ae20f7b014bdcfe5f70a590
Commit:        b71acdcdaf36f0456ae20f7b014bdcfe5f70a590
Parent:        c290749686f3508a2749d4d0cf88e0cc3db174a9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 02:03:00 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon May 27 02:03:00 2013 +0200

test: Make filter extension more robust and composable.

---
 test/lib/aux.sh                     |    8 ++++++++
 test/shell/lvconvert-thin.sh        |    2 +-
 test/shell/lvcreate-large-raid.sh   |    2 +-
 test/shell/lvcreate-large-raid10.sh |    2 +-
 test/shell/lvcreate-large.sh        |    2 +-
 test/shell/pvcreate-operation-md.sh |    2 +-
 test/shell/vgsplit-stacked.sh       |    2 +-
 7 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a59e785..c1ee319 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -448,6 +448,14 @@ prepare_vg() {
 	vgcreate -c n $vg $devs
 }
 
+extend_filter() {
+    filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+    for rx in "$@"; do
+	filter=$(echo $filter | sed -e "s:\[:[ \"$rx\", :")
+    done
+    lvmconf "$filter"
+}
+
 hide_dev() {
     filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
     for dev in $@; do
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 4634aa2..28eeb8e 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -29,7 +29,7 @@ aux prepare_pvs 4 64
 # build one large PV
 vgcreate $vg1 $(cut -d ' ' -f -3 DEVICES)
 lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize 64T
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter "a|$DM_DEV_DIR/LVMTEST|"
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
 vgcreate $vg -s 64K $(cut -d ' ' -f 4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 8768bb3..56ac793 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -26,7 +26,7 @@ lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
 
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter "a|$DM_DEV_DIR/LVMTEST|"
 
 pvcreate $DM_DEV_DIR/$vg/$lv[12345]
 vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index c9d4a2a..2df054f 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -23,7 +23,7 @@ lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
 lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
 lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter "a|$DM_DEV_DIR/LVMTEST|"
 
 pvcreate $DM_DEV_DIR/$vg/$lv[12345]
 vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index b61ccca..58c0d8a 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -20,7 +20,7 @@ lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
 
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter "a|$DM_DEV_DIR/LVMTEST|"
 
 pvcreate $DM_DEV_DIR/$vg/$lv
 vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 9bdc4a1..02ddaa9 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -22,7 +22,7 @@ test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
-aux lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+aux extend_filter "a|$DM_DEV_DIR/LVMTEST|"
 aux prepare_devs 2
 
 # Have MD use a non-standard name to avoid colliding with an existing MD device
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 62a5304..3eb4de0 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux lvmconf 'devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter "a|$DM_DEV_DIR/LVMTEST|"
 aux prepare_pvs 3
 
 vgcreate $vg1 "$dev1" "$dev2"


