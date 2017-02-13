From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:15:00 +0000 (UTC)
Subject: master - tests: fix dev path
Message-ID: <20170213091500.21FCB60576@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3b1f1a07ac4931ee4b7b843741d8ec09d8eea5c
Commit:        c3b1f1a07ac4931ee4b7b843741d8ec09d8eea5c
Parent:        a3579aafc55bb7fb156f89bba38515846b0c26ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 22:28:40 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:19 2017 +0100

tests: fix dev path

Use proper device path for test devices.
Use mkfs.ext4 and drop  'echo y|' to it.
Use smaller device size to consume less memory and CPU time.
---
 test/shell/lvconvert-raid-regionsize.sh |   21 +++++++-------
 test/shell/lvconvert-raid-takeover.sh   |   46 +++++++++++++++---------------
 2 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 4f0e90d..7a6c7f0 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -14,6 +14,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+which mkfs.ext4 || skip
 aux have_raid 1 9 0 || skip
 
 aux prepare_vg 6
@@ -29,7 +30,7 @@ function _test_regionsize
 	lvconvert --type $type --yes -R $regionsize $vg/$lv
 	[ $? -ne 0 ] && return 1
 	check lv_field $vg/$lv regionsize "$regionsize_str"
-	fsck -fn  /dev/mapper/$vg-$lv
+	fsck -fn "$DM_DEV_DIR/$vg/$lv"
 }
 
 function _test_regionsizes
@@ -47,13 +48,13 @@ function _test_regionsizes
 }
 
 # Create 3-way raid1
-lvcreate --yes -aey --type raid1 -m 2 -R64K -L 64M -n $lv1 $vg
+lvcreate --yes -aey --type raid1 -m 2 -R64K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 3
 check lv_field $vg/$lv1 regionsize "64.00k"
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 _test_regionsizes raid1
 
@@ -61,14 +62,14 @@ _test_regionsizes raid1
 lvremove --yes $vg
 
 # Create 5-way raid6
-lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L 64M -n $lv1 $vg
+lvcreate --yes -aey --type raid6 -i 3 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid6"
 check lv_field $vg/$lv1 stripes 5
 check lv_field $vg/$lv1 stripesize "128.00k"
 check lv_field $vg/$lv1 regionsize "256.00k"
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 _test_regionsizes raid6
 
@@ -76,14 +77,14 @@ _test_regionsizes raid6
 lvremove --yes $vg
 
 # Create 6-way raid01
-lvcreate --yes -aey --type raid10 -i 3 -m 1 --stripesize 128K -R 256K -L 64M -n $lv1 $vg
+lvcreate --yes -aey --type raid10 -i 3 -m 1 --stripesize 128K -R 256K -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "raid10"
 check lv_field $vg/$lv1 stripes 6
 check lv_field $vg/$lv1 stripesize "128.00k"
 check lv_field $vg/$lv1 regionsize "256.00k"
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+mkfs.ext4 -t ext4 "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 _test_regionsizes raid10
 
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index a219829..aa41dba 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -14,12 +14,13 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+which mkfs.ext4 || skip
 aux have_raid 1 9 0 || skip
 
 correct_raid4_layout=0
 aux have_raid 1 9 1 && correct_raid4_layout=1
 
-aux prepare_vg 8 80
+aux prepare_vg 8
 
 function _lvcreate
 {
@@ -33,8 +34,8 @@ function _lvcreate
 	lvcreate -y -aey --type $level -i $req_stripes -L $size -n $lv $vg
 	check lv_field $vg/$lv segtype "$level"
 	check lv_field $vg/$lv stripes $stripes
-	echo y | mkfs -t ext4 /dev/mapper/$vg-$lv
-	fsck -fn  /dev/mapper/$vg-$lv
+	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+	fsck -fn "$DM_DEV_DIR/$vg/$lv"
 }
 
 function _lvconvert
@@ -52,17 +53,16 @@ function _lvconvert
 	[ "${level:0:7}" = "striped" ] && wait_and_check=0
 	[ "${level:0:5}" = "raid0" ] && wait_and_check=0
 
-
 	lvconvert -y --ty $req_level $R $vg/$lv
 	[ $? -ne 0 ] && return $?
 	check lv_field $vg/$lv segtype "$level"
 	check lv_field $vg/$lv stripes $stripes
 	if [ "$wait_and_check" -eq 1 ]
 	then
-		fsck -fn  /dev/mapper/$vg-$lv
+		fsck -fn "$DM_DEV_DIR/$vg/$lv"
 		aux wait_for_sync $vg $lv
 	fi
-	fsck -fn  /dev/mapper/$vg-$lv
+	fsck -fn "$DM_DEV_DIR/$vg/$lv"
 }
 
 function _invalid_raid5_conversions
@@ -90,28 +90,28 @@ function _invalid_raid5_conversions
 # aux delay_dev "$dev1" 1
 
 # Create 3-way mirror
-lvcreate --yes -aey --type mirror -R 64K -m 2 -L 64M -n $lv1 $vg
+lvcreate --yes -aey --type mirror -R 64K -m 2 -L8M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 3
 check lv_field $vg/$lv1 regionsize "64.00k"
-echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert 3-way to 4-way mirror
 lvconvert -m 3 $vg/$lv1
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 4
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Takeover 4-way mirror to raid1
 lvconvert --yes --type raid1 -R 64k $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 regionsize "64.00k"
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 ## Convert 4-way raid1 to 5-way
 lvconvert -m 4 -R 128K $vg/$lv1
@@ -119,9 +119,9 @@ check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 5
 # FIXME: once lv_raid_chanage_image_count() supports region_size changes
 not check lv_field $vg/$lv1 regionsize "128.00k"
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # FIXME: enable once lvconvert rejects early
 ## Try converting 4-way raid1 to 9-way
@@ -136,7 +136,7 @@ dmsetup status $vg-$lv1
 dmsetup table $vg-$lv1
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 2
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 
 # Convert 2-way raid1 to mirror
 lvconvert --yes --type mirror -R 32K $vg/$lv1
@@ -144,7 +144,7 @@ check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 2
 check lv_field $vg/$lv1 regionsize "32.00k"
 aux wait_for_sync $vg $lv1
-fsck -fn  /dev/mapper/$vg-$lv1
+fsck -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
 
 # Clean up
@@ -159,7 +159,7 @@ then
 #
 
 # Create 3-way striped raid4 (4 legs total)
-_lvcreate raid4 3 4 64M $vg $lv1
+_lvcreate raid4 3 4 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 
 # Convert raid4 -> striped
@@ -272,7 +272,7 @@ _lvconvert striped striped 3 $vg $lv1
 lvremove -y $vg
 
 # Create + convert 4-way raid5 variations
-_lvcreate raid5 4 5 64M $vg $lv1
+_lvcreate raid5 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
 not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
@@ -282,7 +282,7 @@ _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
 _lvconvert raid5_ls raid5_ls 5 $vg $lv1
 lvremove -y $vg
 
-_lvcreate raid5_ls 4 5 64M $vg $lv1
+_lvcreate raid5_ls 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
 not _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
@@ -292,7 +292,7 @@ _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
 _lvconvert raid5_ls raid5_ls 5 $vg $lv1
 lvremove -y $vg
 
-_lvcreate raid5_rs 4 5 64M $vg $lv1
+_lvcreate raid5_rs 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
 not _lvconvert raid6_ra_6 raid6_ra_6 6 $vg $lv1
@@ -302,7 +302,7 @@ _lvconvert raid6_rs_6 raid6_rs_6 6 $vg $lv1
 _lvconvert raid5_rs raid5_rs 5 $vg $lv1
 lvremove -y $vg
 
-_lvcreate raid5_la 4 5 64M $vg $lv1
+_lvcreate raid5_la 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
 not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
@@ -312,7 +312,7 @@ _lvconvert raid6_la_6 raid6_la_6 6 $vg $lv1
 _lvconvert raid5_la raid5_la 5 $vg $lv1
 lvremove -y $vg
 
-_lvcreate raid5_ra 4 5 64M $vg $lv1
+_lvcreate raid5_ra 4 5 8M $vg $lv1
 aux wait_for_sync $vg $lv1
 _invalid_raid5_conversions $vg $lv1
 not _lvconvert raid6_ls_6 raid6_ls_6 6 $vg $lv1
@@ -324,7 +324,7 @@ lvremove -y $vg
 
 else
 
-not lvcreate -y -aey --type raid4 -i 3 -L 64M -n $lv4 $vg
+not lvcreate -y -aey --type raid4 -i 3 -L8M -n $lv4 $vg
 not lvconvert -y --ty raid4 $vg/$lv1
 not lvconvert -y --ty raid4 $vg/$lv2
 


