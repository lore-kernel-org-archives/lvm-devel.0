From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:30 +0000 (UTC)
Subject: dev-mornfall-lvmcache - tests: make filter extension more robust
Message-ID: <20130605120530.178096117A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53fbf2bea3e992f1c21f5f77eacc687ce01143f5
Commit:        53fbf2bea3e992f1c21f5f77eacc687ce01143f5
Parent:        28160cb04a0f7c89854eccb5ed8431b33ecc9d2a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon May 27 02:03:00 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:09 2013 +0200

tests: make filter extension more robust

---
 test/lib/aux.sh                     |   12 ++++++++++++
 test/shell/lvconvert-thin.sh        |    2 +-
 test/shell/lvcreate-large-raid.sh   |    2 +-
 test/shell/lvcreate-large-raid10.sh |    2 +-
 test/shell/lvcreate-large.sh        |    2 +-
 test/shell/pvcreate-operation-md.sh |    4 +++-
 test/shell/snapshots-usage.sh       |    3 +--
 test/shell/vgsplit-stacked.sh       |    2 +-
 8 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0894a66..b92f428 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -448,6 +448,18 @@ prepare_vg() {
 	vgcreate -c n $vg $devs
 }
 
+extend_filter() {
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	for rx in "$@"; do
+		filter=$(echo $filter | sed -e "s:\[:[ \"$rx\", :")
+	done
+	lvmconf "$filter"
+}
+
+extend_filter_LVMTEST() {
+	extend_filter "a|$DM_DEV_DIR/LVMTEST|"
+}
+
 hide_dev() {
 	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for dev in $@; do
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 4634aa2..a84c1d1 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -29,7 +29,7 @@ aux prepare_pvs 4 64
 # build one large PV
 vgcreate $vg1 $(cut -d ' ' -f -3 DEVICES)
 lvcreate -s -l 100%FREE -n $lv $vg1 --virtualsize 64T
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
 vgcreate $vg -s 64K $(cut -d ' ' -f 4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index b1cb274..c0b40db 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -27,7 +27,7 @@ lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
 
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter_LVMTEST
 
 pvcreate $DM_DEV_DIR/$vg/$lv[12345]
 vgcreate $vg1 $DM_DEV_DIR/$vg/$lv[12345]
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index e4dadbd..50dd23a 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -24,7 +24,7 @@ lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
 lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
 lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter_LVMTEST
 
 pvcreate $DM_DEV_DIR/$vg/$lv[12345]
 vgcreate $vg1 $DM_DEV_DIR/$vg/$lv[12345]
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 09e323a..63b2b03 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -20,7 +20,7 @@ lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
 
-aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter_LVMTEST
 
 pvcreate $DM_DEV_DIR/$vg/$lv
 vgcreate $vg1 $DM_DEV_DIR/$vg/$lv
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 9bdc4a1..5e2a28d 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -22,7 +22,9 @@ test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
-aux lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+aux extend_filter_LVMTEST
+aux extend_filter "a|/dev/md.*|"
+
 aux prepare_devs 2
 
 # Have MD use a non-standard name to avoid colliding with an existing MD device
diff --git a/test/shell/snapshots-usage.sh b/test/shell/snapshots-usage.sh
index ae08378..1507d2a 100644
--- a/test/shell/snapshots-usage.sh
+++ b/test/shell/snapshots-usage.sh
@@ -21,10 +21,9 @@ aux prepare_vg
 
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 15P
 
+aux extend_filter_LVMTEST
 aux lvmconf "activation/snapshot_autoextend_percent = 20" \
             "activation/snapshot_autoextend_threshold = 50"
-aux lvmconf 'devices/filter = [ "a|dev/mapper/.*$|", "a|dev/LVMTEST|", "r|.*|" ]'
-aux lvmconf 'devices/global_filter = [ "a|dev/mapper/.*$|", "a|dev/LVMTEST|", "r|.*|" ]'
 
 # Check usability with smallest extent size
 pvcreate --setphysicalvolumesize 4T $DM_DEV_DIR/$vg/$lv
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 62a5304..3256191 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux lvmconf 'devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux extend_filter_LVMTEST
 aux prepare_pvs 3
 
 vgcreate $vg1 "$dev1" "$dev2"


