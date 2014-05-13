From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 May 2014 09:04:35 +0000 (UTC)
Subject: master - tests: updates
Message-ID: <20140513090435.428FF60FFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b766b064837110a09d448376ea61af174260ae7
Commit:        7b766b064837110a09d448376ea61af174260ae7
Parent:        6f057e3c6640f25676b0c5d0fe93912ac91244bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 13 10:28:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 13 10:28:55 2014 +0200

tests: updates

Move thin test out of listing.
---
 test/shell/listings.sh         |    2 +-
 test/shell/lvcreate-thin.sh    |    6 +++---
 test/shell/snapshot-maxsize.sh |    5 ++---
 test/shell/snapshot-usage.sh   |   10 ++++++----
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 79c9c89..2121ecd 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -65,10 +65,10 @@ lvcreate -aey -l2 --type mirror -m2 -n $lv3 $vg
 test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
 dmsetup ls|grep "$PREFIX"|grep -v "LVMTEST.*pv."
+
 lvcreate -l2 -s $vg/$lv3
 lvcreate -l1 -s -n inval $vg/$lv3
 lvcreate -l4 -I4 -i2 -n stripe $vg
-lvcreate -T $vg/pool -I4 -i2 -l5 -V1P -n thin
 # Invalidate snapshot
 not dd if=/dev/zero of="$DM_DEV_DIR/$vg/inval" bs=4K
 invalid lvscan "$dev1"
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 0873ce1..7ea4fcf 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -135,7 +135,7 @@ lvremove -ff $vg
 check vg_field $vg lv_count 0
 
 # Create thin snapshot of thinLV
-lvcreate -L10M -V10M -T $vg/pool --name lv1
+lvcreate -L10M -I4 -i2 -V10M -T $vg/pool --name lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg/lv1"
 lvcreate -K -s $vg/lv1 --name snap_lv1
 fsck -n "$DM_DEV_DIR/$vg/snap_lv1"
@@ -145,8 +145,10 @@ lvcreate --type snapshot $vg/lv1 --name lv6
 lvcreate --type snapshot $vg/lv1 --name lv4
 lvcreate --type snapshot $vg/lv1 --name $vg/lv5
 
+lvdisplay --maps $vg
 check_lv_field_modules_ thin-pool,thin lv1 snap_lv1 lv2 lv3 lv4 lv5 lv6
 check vg_field $vg lv_count 8
+
 lvremove -ff $vg
 
 
@@ -163,8 +165,6 @@ check vg_field $vg lv_count 6
 lvremove -ff $vg
 check vg_field $vg lv_count 0
 
-lvdisplay $vg
-
 # Fail cases
 # Too small pool size (1 extent 64KB) for given chunk size
 not lvcreate --chunksize 256 -l1 -T $vg/pool1
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index a20e306..e1380c6 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -24,8 +24,7 @@ lvcreate -L2 -s $vg/$lv1 -n $lv2
 
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1
 
-get lv_field $vg/$lv2 lv_attr | tee attrs
-# Snapshot must not be invalid here
-grep -v "....I" attrs
+# Snapshot must not be 'I'nvalid here
+check lv_attr_bit state $vg/$lv2 "a"
 
 vgremove -f $vg
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 095fddb..589ed43 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -145,6 +145,7 @@ lvextend -l+33 $vg1/lvol1
 check lv_field $vg1/lvol1 size "$EXPECT3"
 
 fill 20K
+
 lvremove -f $vg1
 
 # Check snapshot really deletes COW header for read-only snapshot
@@ -172,11 +173,12 @@ fsck -n "$DM_DEV_DIR/$vg1/snap"
 # we have 2 valid results  (unsure about correct version number)
 check lv_field $vg1/snap data_percent "$EXPECT4"
 
-# Can't test >= 16T devices on 32bit
-if test "$TSIZE" = 15P ; then
-
 vgremove -ff $vg1
 
+
+# Can't test >= 16T devices on 32bit
+test "$TSIZE" = 15P || exit 0
+
 # Check usability with largest extent size
 pvcreate "$DM_DEV_DIR/$vg/$lv"
 vgcreate -s 4G $vg1 "$DM_DEV_DIR/$vg/$lv"
@@ -189,4 +191,4 @@ lvremove -ff $vg1
 lvcreate -V15E -l1 -n $lv1 -s $vg1
 check lv_field $vg1/$lv1 origin_size "15.00e"
 
-fi
+vgremove -ff $vg1


