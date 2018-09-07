From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 7 Sep 2018 07:49:37 -0400
Subject: master - lvconvert: fix interim segtype regression on raid6 conversions
Message-ID: <201809071149.w87Bnb6N013627@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2e30a64ab10602951443dfbd3481bd6b32f5459
Commit:        e2e30a64ab10602951443dfbd3481bd6b32f5459
Parent:        22a13043683a5647e8cc4e3aead911e5269ffd2f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Sep 7 13:48:13 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Sep 7 13:48:19 2018 +0200

lvconvert: fix interim segtype regression on raid6 conversions

When converting from striped/raid0/raid0_meta
to raid6 with > 2 stripes, allow possible
direct conversion (to raid6_n_6).

In case of 2 stripes, first convert to raid5_n to restripe
to at least 3 data stripes (the raid6 minimum in lvm2) in
a second conversion before finally converting to raid6_n_6.

As before, raid6_n_6 then can be converted
to any other raid6 layout.

Enhance lvconvert-raid-takeover.sh to test the
2 stripes conversions to raid6.

Resolves: rhbz1624038
---
 WHATS_NEW                             |    1 +
 lib/metadata/raid_manip.c             |    6 +++---
 test/shell/lvconvert-raid-takeover.sh |   16 ++++++++++++----
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6003f0a..6575887 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Fix lvconvert striped/raid0/raid0_meta -> raid6 regression.
   Add 'lvm2-activation-generator:' prefix for kmsg messages logged by generator.
   Add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service.
   Reduce max concurrent aios to avoid EMFILE with many devices.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2bc179a..130cd34 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6127,10 +6127,10 @@ static int _set_convenient_raid145610_segtype_to(const struct lv_segment *seg_fr
 	/* striped/raid0 -> */
 	} else if (seg_is_striped(seg_from) || seg_is_any_raid0(seg_from)) {
 		if (segtype_is_any_raid6(*segtype))
-			seg_flag = SEG_RAID6_N_6;
+			seg_flag = seg_from->area_count < 3 ? SEG_RAID5_N : SEG_RAID6_N_6;
 
-		if (segtype_is_linear(*segtype) ||
-		    (!segtype_is_raid4(*segtype) && !segtype_is_raid10(*segtype) && !segtype_is_striped(*segtype)))
+		else if (segtype_is_linear(*segtype) ||
+			 (!segtype_is_raid4(*segtype) && !segtype_is_raid10(*segtype) && !segtype_is_striped(*segtype)))
 			seg_flag = SEG_RAID5_N;
 
 	/* raid1 -> */
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index d1c5d30..d22c11b 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -108,11 +108,19 @@ function _invalid_raid5_conversions
 	not _lvconvert raid6 raid6_n_6 4 6 $vg $lv1
 }
 
-# Check raid6 conversion constrainst of minimum 3 stripes
-_lvcreate striped 2 2 4m $vg $lv1
-not _lvconvert raid6 raid6_n_6 2 4 $vg $lv1
-lvremove -y $vg
+# Check raid6 conversion constrainst for 2 stripes
+for type in striped raid0 raid0_meta
+do
+   _lvcreate $type 2 2 4m $vg $lv1
+   not _lvconvert raid6 raid6_n_6 2 4 $vg $lv1
+   _lvconvert raid6 raid5_n 2 3 $vg $lv1
+   _lvconvert raid6 raid5_n 3 4 $vg $lv1
+   _lvconvert raid6 raid6_n_6 3 5 $vg $lv1
+   lvremove -y $vg
+done
 
+
+# Check raid6 conversion constrainst of minimum 3 stripes
 _lvcreate raid0 3 3 4m $vg $lv1
 _lvconvert raid6 raid6_n_6 3 5 $vg $lv1
 lvremove -y $vg


