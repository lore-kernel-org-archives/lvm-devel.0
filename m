From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 27 Sep 2012 21:54:21 +0000 (UTC)
Subject: master - RAID: Fix problems with creating, extending and converting large RAID LVs
Message-ID: <20120927215421.7A0FCA33AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=886656e4ac5e5c932d9fbe60d18c063136288a38
Commit:        886656e4ac5e5c932d9fbe60d18c063136288a38
Parent:        662a2122f6224b5404d9f1276868bc3069766c49
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Sep 27 16:51:22 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Sep 27 16:51:22 2012 -0500

RAID: Fix problems with creating, extending and converting large RAID LVs

MD's bitmaps can handle 2^21 regions at most.  The RAID code has always
used a region_size of 1024 sectors.  That means the size of a RAID LV was
limited to 1TiB.  (The user can adjust the region_size when creating a
RAID LV, which can affect the maximum size.)  Thus, creating, extending or
converting to a RAID LV greater than 1TiB would result in a failure to
load the new device-mapper table.

Again, the size of the RAID LV is not limited by how much space is allocated
for the metadata area, but by the limitations of the MD bitmap.  Therefore,
we must adjust the 'region_size' to ensure that the number of regions does
not exceed the limit.  I've added code to do this when extending a RAID LV
(which covers 'create' and 'extend' operations) and when up-converting -
specifically from linear to RAID1.
---
 WHATS_NEW                    |    1 +
 lib/metadata/lv_manip.c      |   12 +++++++-
 lib/metadata/raid_manip.c    |    6 ++++
 test/shell/lvcreate-large.sh |   65 ++++++++++++++++++++++++++++++++++++------
 4 files changed, 74 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 448f306..dc62d77 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Fix inability to create, extend or convert to a large (> 1TiB) RAID LV.
   Add (p)artial attribute to lvs.
   Don't try to issue discards to a missing PV to avoid segfault.
   Prevent lvremove from removing LVs that have any part missing.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6c62bb3..f2d99b8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2660,7 +2660,17 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	seg->area_len += extents;
 	seg->len += extents;
 	lv->le_count += extents;
-	lv->size += (uint64_t) extents *lv->vg->extent_size;
+	lv->size += (uint64_t) extents * lv->vg->extent_size;
+
+	/*
+	 * The MD bitmap is limited to being able to track 2^21 regions.
+	 * The region_size must be adjusted to meet that criteria.
+	 */
+	while (seg_is_raid(seg) && (seg->region_size < (lv->size / (1 << 21)))) {
+		seg->region_size *= 2;
+		log_very_verbose("Forced to adjust RAID region_size to %uS",
+				 seg->region_size);
+	}
 
 	return 1;
 }
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0266013..98a7db3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -731,6 +731,12 @@ static int _raid_add_images(struct logical_volume *lv,
 		seg = first_seg(lv);
 		seg_lv(seg, 0)->status |= RAID_IMAGE | LVM_READ | LVM_WRITE;
 		seg->region_size = RAID_REGION_SIZE;
+		/* MD's bitmap is limited to tracking 2^21 regions */
+		while (seg->region_size < (lv->size / (1 << 21))) {
+			seg->region_size *= 2;
+			log_very_verbose("Setting RAID1 region_size to %uS",
+					 seg->region_size);
+		}
 		seg->segtype = get_segtype_from_string(lv->vg->cmd, "raid1");
 		if (!seg->segtype)
 			return_0;
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index b61ccca..127b434 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -13,28 +13,75 @@
 
 . lib/test
 
-aux prepare_vg 4
+aux prepare_vg 5
 
-lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
+lvcreate -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
+lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
 
 aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 
-pvcreate $DM_DEV_DIR/$vg/$lv
-vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv
+pvcreate $DM_DEV_DIR/$vg/$lv[12345]
+vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
 
 lvcreate -l 100%FREE -n $lv1 $vg1
-check lv_field $vg1/$lv1 size "1024.00t"
+check lv_field $vg1/$lv1 size "1.25p"
 lvresize -f -l 72%VG $vg1/$lv1
-check lv_field $vg1/$lv1 size "737.28t"
+check lv_field $vg1/$lv1 size "921.60t"
 lvremove -ff $vg1/$lv1
 
 lvcreate -l 100%VG -n $lv1 $vg1
-check lv_field $vg1/$lv1 size "1024.00t"
+check lv_field $vg1/$lv1 size "1.25p"
 lvresize -f -l 72%VG $vg1/$lv1
-check lv_field $vg1/$lv1 size "737.28t"
+check lv_field $vg1/$lv1 size "921.60t"
 lvremove -ff $vg1/$lv1
 
-lvremove -ff $vg/$lv
+if aux target_at_least dm-raid 1 1 0; then
+	# bz837927 START
+
+	#
+	# Create large RAID LVs
+	#
+	# We need '--nosync' or our virtual devices won't work
+	lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
+	check lv_field $vg1/$lv1 size "200.00t"
+	lvremove -ff $vg1
+
+	lvcreate --type raid10 -m 1 -i 2 -L 200T -n $lv1 $vg1 --nosync
+	check lv_field $vg1/$lv1 size "200.00t"
+	lvremove -ff $vg1
+
+	for segtype in raid4 raid5 raid6; do
+		lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
+		check lv_field $vg1/$lv1 size "750.00t"
+		lvremove -ff $vg1
+	done
+
+	#
+	# Convert large linear to RAID1 (belong in different test script?)
+	#
+	lvcreate -L 200T -n $lv1 $vg1
+	# Need to deactivate or the up-convert will start sync'ing
+	lvchange -an $vg1/$lv1
+	lvconvert --type raid1 -m 1 $vg1/$lv1
+	check lv_field $vg1/$lv1 size "200.00t"
+	lvremove -ff $vg1
+
+	#
+	# Extending large RAID LV (belong in different script?)
+	#
+	lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
+	check lv_field $vg1/$lv1 size "200.00t"
+	lvextend -L +200T $vg1/$lv1
+	check lv_field $vg1/$lv1 size "400.00t"
+	lvremove -ff $vg1
+
+	# bz837927 END
+fi
+
+lvremove -ff $vg


