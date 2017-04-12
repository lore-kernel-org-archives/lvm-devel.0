From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 12 Apr 2017 08:40:07 -0400
Subject: master - lvconvert: fix failing valid regionsize change
Message-ID: <201704121240.v3CCe7B6022022@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=532388fad510c7ba706ecbd4b5fbd2643134d63b
Commit:        532388fad510c7ba706ecbd4b5fbd2643134d63b
Parent:        01b5820d03c41516222675eb458ce6eb3dff53a7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 12 14:38:49 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 12 14:38:49 2017 +0200

lvconvert: fix failing valid regionsize change

Reshape check failed when regionsize changed and current raid type
was provided with no other change requested (stripes or stripesize).

E.g. "lvconvert --type raid6 --regionsize 256K" on a raid6 LV
with != 256K regionsize.

Enable --type in test script.
---
 lib/metadata/raid_manip.c               |   10 ++++------
 test/shell/lvconvert-raid-regionsize.sh |    2 +-
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f99788f..9614179 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2389,7 +2389,7 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 	if (seg_is_any_raid10(seg) && seg->area_count > 2 &&
 	    stripes && stripes < seg->area_count - seg->segtype->parity_devs) {
 		log_error("Can't remove stripes from raid10");
-		goto err;
+		return 2;
 	}
 
 	if (data_copies != seg->data_copies) {
@@ -2400,22 +2400,20 @@ static int _reshape_requested(const struct logical_volume *lv, const struct segm
 	/* Change layout (e.g. raid5_ls -> raid5_ra) keeping # of stripes */
 	if (seg->segtype != segtype) {
 		if (stripes && stripes != _data_rimages_count(seg, seg->area_count))
-			goto err;
+			return 2;
 
 		return 1;
 	}
 
 	if (stripes && stripes == _data_rimages_count(seg, seg->area_count) &&
-	    stripe_size == seg->stripe_size) {
+	    stripe_size == seg->stripe_size &&
+	    region_size == seg->region_size) {
 		log_error("LV %s already has %u stripes.",
 			  display_lvname(lv), stripes);
 		return 2;
 	}
 
 	return (stripes || stripe_size) ? 1 : 0;
-
-err:
-	return 2;
 }
 
 /*
diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 9baa99a..7a6c7f0 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -27,7 +27,7 @@ function _test_regionsize
 	local vg=$4
 	local lv=$5
 
-	lvconvert --yes -R $regionsize $vg/$lv
+	lvconvert --type $type --yes -R $regionsize $vg/$lv
 	[ $? -ne 0 ] && return 1
 	check lv_field $vg/$lv regionsize "$regionsize_str"
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"


