From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 6 Apr 2017 12:48:40 -0400
Subject: master - lvconvert: prompt on raid1 image changes
Message-ID: <201704061648.v36Gmetf006580@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f65d7ec3a7325165af1a9f722cb760fd363e932
Commit:        0f65d7ec3a7325165af1a9f722cb760fd363e932
Parent:        e350b83d508aca11969ad5429d1095fb2e066432
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 18:47:41 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 18:47:41 2017 +0200

lvconvert: prompt on raid1 image changes

Don't change resilience of raid1 LVs without --yes.

Adjust respective tests.
---
 lib/metadata/raid_manip.c               |    7 +++++++
 test/shell/lvchange-raid.sh             |    6 +++---
 test/shell/lvconvert-cache-raid.sh      |   14 +++++++-------
 test/shell/lvconvert-raid-allocation.sh |   10 +++++-----
 test/shell/lvconvert-raid-takeover.sh   |    4 ++--
 test/shell/lvconvert-raid.sh            |   16 ++++++++--------
 test/shell/lvconvert-thin-raid.sh       |    4 ++--
 test/shell/lvcreate-large-raid.sh       |    2 +-
 8 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 05cbb74..8c58f3c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2999,7 +2999,14 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
 			       const uint32_t new_region_size, struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
+	const char *level = seg->area_count == 1 ? "raid1 with " : "";
+	const char *resil = new_count == 1 ? " loosing all" : (new_count < seg->area_count ? "s reducing" : "s enhancing");
 
+	if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to %s%u image%s resilience? [y/n]: ",
+				  lvseg_name(first_seg(lv)), display_lvname(lv), level, new_count, resil) == 'n') {
+		log_error("Logical volume %s NOT converted.", display_lvname(lv));
+		return 0;
+	}
 	if (new_region_size) {
 		seg->region_size = new_region_size;
 		_check_and_adjust_region_size(lv);
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 09ef3fa..34a40dc 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -128,7 +128,7 @@ run_writemostly_check() {
 	# Converting to linear should clear flags and writebehind
 	not lvconvert -m 0 $vg/$lv $d1
 	lvconvert -y -m 0 $vg/$lv $d1
-	lvconvert --type raid1 -m 1 $vg/$lv $d1
+	lvconvert -y --type raid1 -m 1 $vg/$lv $d1
 	check lv_field $vg/$lv raid_write_behind ""
 	check lv_attr_bit health $vg/${lv}_rimage_0 "-"
 	check lv_attr_bit health $vg/${lv}_rimage_1 "-"
@@ -274,7 +274,7 @@ run_checks() {
 		printf "#\n#\n# run_checks: RAID as thinpool data\n#\n#\n"
 
 # Hey, specifying devices for thin allocation doesn't work
-#		lvconvert --thinpool $1/$2 "$dev6"
+#		lvconvert -y --thinpool $1/$2 "$dev6"
 		lvcreate -aey -L 2M -n ${2}_meta $1 "$dev6"
 		lvconvert --thinpool $1/$2 --poolmetadata ${2}_meta
 		lvcreate -T $1/$2 -V 1 -n thinlv
@@ -289,7 +289,7 @@ run_checks() {
 
 		lvrename $1/$2 ${2}_meta
 		lvcreate -aey -L 2M -n $2 $1 "$dev6"
-		lvconvert --thinpool $1/$2 --poolmetadata ${2}_meta
+		lvconvert -y --thinpool $1/$2 --poolmetadata ${2}_meta
 		lvcreate -T $1/$2 -V 1 -n thinlv
 		THIN_POSTFIX="_tmeta"
 
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 3ad91c4..e2fbf94 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -66,8 +66,8 @@ aux wait_for_sync $vg cpool_cmeta
 lvchange --syncaction repair $vg/cpool_cdata
 aux wait_for_sync $vg cpool_cdata
 
-lvconvert --repair -y $vg/cpool_cmeta
-lvconvert --repair -y $vg/cpool_cdata
+lvconvert -y --repair $vg/cpool_cmeta
+lvconvert -y --repair $vg/cpool_cdata
 
 # do not allow reserved names for *new* LVs
 not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta "$dev1"
@@ -87,18 +87,18 @@ lvremove -f $vg
 lvcreate --type cache-pool $vg/cpool -l 10
 lvcreate -n corigin -H $vg/cpool -l 20
 
-lvconvert -m+1 --type raid1 $vg/cpool_cmeta
+lvconvert -y -m +1 --type raid1 $vg/cpool_cmeta
 check lv_field $vg/cpool_cmeta layout "raid,raid1"
 check lv_field $vg/cpool_cmeta role "private,cache,pool,metadata"
 
-lvconvert -m+1 --type raid1 $vg/cpool_cdata
+lvconvert -y -m +1 --type raid1 $vg/cpool_cdata
 check lv_field $vg/cpool_cdata layout "raid,raid1"
 check lv_field $vg/cpool_cdata role "private,cache,pool,data"
 
-not lvconvert -m-1  $vg/cpool_cmeta
-lvconvert -y -m-1  $vg/cpool_cmeta
+not lvconvert -m -1  $vg/cpool_cmeta
+lvconvert -y -m -1  $vg/cpool_cmeta
 check lv_field $vg/cpool_cmeta layout "linear"
-lvconvert -y -m-1  $vg/cpool_cdata
+lvconvert -y -m -1  $vg/cpool_cdata
 check lv_field $vg/cpool_cdata layout "linear"
 
 lvremove -f $vg
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index 87e28fc..b23644c 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -24,11 +24,11 @@ vgcreate -s 256k $vg $(cat DEVICES)
 lvcreate -aey -l 4 -n $lv1 $vg "$dev1:0-1" "$dev2:0-1"
 not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev2"
 not lvconvert --type raid1 -m 1 $vg/$lv1 "$dev1" "$dev3:0-2"
-lvconvert --type raid1 -m 1 $vg/$lv1 "$dev3"
+lvconvert -y --type raid1 -m 1 $vg/$lv1 "$dev3"
 not lvconvert -m 0 $vg/$lv1
 lvconvert -y -m 0 $vg/$lv1
 # RAID conversions are not honoring allocation policy!
-# lvconvert --type raid1 -m 1 --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
+# lvconvert -y --type raid1 -m 1 --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 lvremove -ff $vg
 
 
@@ -48,12 +48,12 @@ aux wait_for_sync $vg $lv1
 # Should not be enough non-overlapping space.
 not lvconvert -m +1 $vg/$lv1 \
     "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
-lvconvert -m +1 $vg/$lv1 "$dev5"
+lvconvert -y -m +1 $vg/$lv1 "$dev5"
 not lvconvert -m 0 $vg/$lv1
 lvconvert -y -m 0 $vg/$lv1
 # Should work due to '--alloc anywhere'
 # RAID conversion not honoring allocation policy!
-#lvconvert -m +1 --alloc anywhere $vg/$lv1 \
+#lvconvert -y -m +1 --alloc anywhere $vg/$lv1 \
 #    "$dev5:0-1" "$dev1" "$dev2" "$dev3" "$dev4"
 lvremove -ff $vg
 
@@ -68,7 +68,7 @@ lvcreate --type raid1 -m 1 -l 3 -n $lv1 $vg \
     "$dev1:0-1" "$dev2:0-1" "$dev3:0-1" "$dev4:0-1"
 aux wait_for_sync $vg $lv1
 aux disable_dev "$dev1"
-lvconvert --repair -y $vg/$lv1 "$dev2" "$dev3" "$dev4"
+lvconvert -y --repair $vg/$lv1 "$dev2" "$dev3" "$dev4"
 #FIXME: ensure non-overlapping images (they should not share PVs)
 aux enable_dev "$dev1"
 lvremove -ff $vg
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index e1b1d98..8e3ffb1 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -132,7 +132,7 @@ aux wait_for_sync $vg $lv1
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert 3-way to 4-way mirror
-lvconvert -m 3 $vg/$lv1
+lvconvert -y -m 3 $vg/$lv1
 detect_error_leak_
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 4
@@ -149,7 +149,7 @@ check lv_field $vg/$lv1 regionsize "64.00k"
 fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 ## Convert 4-way raid1 to 5-way
-lvconvert -m 4 -R 128K $vg/$lv1
+lvconvert -y -m 4 -R 128K $vg/$lv1
 detect_error_leak_
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 5
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index a9b36e2..e173d66 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -75,14 +75,14 @@ for i in 1 2 3; do
 		mirrors=$((j - 1))
 		if [ $i -eq 1 ]
 		then
-			[ $mirrors -eq 0 ] && lvconvert -m $mirrors $vg/$lv1
+			[ $mirrors -eq 0 ] && lvconvert -y -m $mirrors $vg/$lv1
 		else
 			if [ $mirrors -eq 0 ]
 			then
 				not lvconvert -m $mirrors $vg/$lv1
 				lvconvert -y -m $mirrors $vg/$lv1
 			else
-				lvconvert -m $mirrors $vg/$lv1
+				lvconvert -y -m $mirrors $vg/$lv1
 			fi
 		fi
 
@@ -105,13 +105,13 @@ lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg --nosync
 not lvconvert -m +1 $vg/$lv1
 lvchange --resync -y $vg/$lv1
 aux wait_for_sync $vg $lv1
-lvconvert -m +1 $vg/$lv1
+lvconvert -y -m +1 $vg/$lv1
 lvremove -ff $vg
 
 # 3-way to 2-way convert while specifying devices
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
-lvconvert -m1 $vg/$lv1 "$dev2"
+lvconvert -y -m 1 $vg/$lv1 "$dev2"
 lvremove -ff $vg
 
 #
@@ -188,7 +188,7 @@ lvremove -ff $vg
 # Linear to RAID1 conversion ("raid1" default segtype)
 ###########################################
 lvcreate -aey -l 2 -n $lv1 $vg
-lvconvert -m 1 $vg/$lv1 \
+lvconvert -y -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "raid1" }'
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
 lvremove -ff $vg
@@ -197,7 +197,7 @@ lvremove -ff $vg
 # Linear to RAID1 conversion (override "mirror" default segtype)
 ###########################################
 lvcreate -aey -l 2 -n $lv1 $vg
-lvconvert --type raid1 -m 1 $vg/$lv1 \
+lvconvert --yes --type raid1 -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "mirror" }'
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
 lvremove -ff $vg
@@ -207,7 +207,7 @@ lvremove -ff $vg
 ###########################################
 if [ -e LOCAL_CLVMD ]; then
 	lvcreate -l 2 -n $lv1 $vg
-	not lvconvert --type raid1 -m 1 $vg/$lv1 \
+	not lvconvert -y --type raid1 -m 1 $vg/$lv1 \
 		--config 'global { mirror_segtype_default = "mirror" }'
 	lvremove -ff $vg
 fi
@@ -218,7 +218,7 @@ fi
 for i in 1 2 3 ; do
 	lvcreate -aey --type mirror -m $i -l 2 -n $lv1 $vg
 	aux wait_for_sync $vg $lv1
-	lvconvert --type raid1 $vg/$lv1
+	lvconvert -y --type raid1 $vg/$lv1
 	lvremove -ff $vg
 done
 
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 7890350..807b1dc 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -54,7 +54,7 @@ lvremove -ff $vg/data2 $vg/data3 $vg/meta1 $vg/meta2
 lvconvert --merge $vg/${lv1}_tdata_rimage_1
 lvconvert --merge $vg/${lv1}_tmeta_rimage_1
 
-lvconvert -m+1 $vg/${lv1}_tdata "$dev2"
-lvconvert -m+1 $vg/${lv1}_tmeta "$dev1"
+lvconvert -y -m +1 $vg/${lv1}_tdata "$dev2"
+lvconvert -y -m +1 $vg/${lv1}_tmeta "$dev1"
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 4e68b2c..ca3f715 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -99,7 +99,7 @@ lvremove -ff $vg1
 # Convert large 200 TiB linear to RAID1 (belong in different test script?)
 #
 lvcreate -aey -L 200T -n $lv1 $vg1
-lvconvert --type raid1 -m 1 $vg1/$lv1
+lvconvert -y --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
 check raid_leg_status $vg1 $lv1 "aa"
 lvremove -ff $vg1


