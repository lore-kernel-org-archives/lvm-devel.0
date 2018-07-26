From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 25 Jul 2018 20:08:37 -0400
Subject: master - lvconvert: reject conversions on raid1 split trackchanges LVs
Message-ID: <201807260008.w6Q08bA2001900@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a004bb07f14baeed158ac9ea571cf5a6882c436f
Commit:        a004bb07f14baeed158ac9ea571cf5a6882c436f
Parent:        8b0729af0fd357e66e95834e92913ea2a42d4e93
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 26 01:47:39 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jul 26 02:05:54 2018 +0200

lvconvert: reject conversions on raid1 split trackchanges LVs

Prohibit, because the tracking can't continue and
further conversions may fail with bogus error messages.

Resolves: rhbz1579072
---
 WHATS_NEW                                        |    1 +
 test/shell/lvconvert-raid1-split-trackchanges.sh |    7 +++++++
 tools/lvconvert.c                                |    6 ++++++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4502b52..2c5b5d3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  lvconvert: reject conversions on raid1 LVs with split tracked SubLVs
   lvconvert: reject conversions on raid1 split tracked SubLVs
   Add basic creation support for VDO target.
   Never send any discard ioctl with test mode.
diff --git a/test/shell/lvconvert-raid1-split-trackchanges.sh b/test/shell/lvconvert-raid1-split-trackchanges.sh
index e25a632..718c254 100644
--- a/test/shell/lvconvert-raid1-split-trackchanges.sh
+++ b/test/shell/lvconvert-raid1-split-trackchanges.sh
@@ -27,6 +27,13 @@ vgcreate $SHARED -s 512k "$vg" "${DEVICES[@]}"
 lvcreate -y --ty raid1 -m 2 -n $lv1 -l 1 $vg
 lvconvert -y --splitmirrors 1 --trackchanges $vg/$lv1
 
+not lvconvert -y --ty linear $vg/$lv1
+not lvconvert -y --ty striped -i 3 $vg/$lv1
+not lvconvert -y --ty mirror $vg/$lv1
+not lvconvert -y --ty raid4 $vg/$lv1
+not lvconvert -y --ty raid5 $vg/$lv1
+not lvconvert -y --ty raid6 $vg/$lv1
+not lvconvert -y --ty raid10 $vg/$lv1
 not lvconvert -y --ty striped -m 1 $vg/${lv1}_rimage_2
 not lvconvert -y --ty raid1 -m 1 $vg/${lv1}_rimage_2
 not lvconvert -y --ty mirror -m 1 $vg/${lv1}_rimage_2
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a5382ef..dbc5ab0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1161,6 +1161,12 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
 {
 	const char *s;
 
+	if (lv_is_raid_with_tracking(lv)) {
+		log_error("Conversion of tracking raid1 LV %s is not supported.",
+			  display_lvname(lv));
+		return 1;
+	}
+
 	if (lv_is_raid_image(lv) &&
 	    (s = strstr(lv->name, "_rimage_"))) {
 		size_t len = s - lv->name;


