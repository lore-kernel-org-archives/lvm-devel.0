From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Jul 2018 13:32:32 -0400
Subject: 2018-06-01-stable - lvconvert: improve text about splitmirrors
Message-ID: <201807231732.w6NHWW4P002955@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b394a9f63fd01c926c8c00d78f43afb223b2d203
Commit:        b394a9f63fd01c926c8c00d78f43afb223b2d203
Parent:        9e296c9c6f3fa92fdc839b30012b51ee28d23d1a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 23 12:28:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 23 12:31:28 2018 -0500

lvconvert: improve text about splitmirrors

in messages and man page.
---
 lib/metadata/raid_manip.c |    4 ++--
 tools/args.h              |   14 +++++++++-----
 tools/command-lines.in    |    2 +-
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8f78e1a..705a7f9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3563,7 +3563,7 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	struct volume_group *vg = image_lv->vg;
 
 	if (image_lv->status & LVM_WRITE) {
-		log_error("%s is not read-only - refusing to merge.",
+		log_error("%s cannot be merged because --trackchanges was not used.",
 			  display_lvname(image_lv));
 		return 0;
 	}
@@ -3572,7 +3572,7 @@ int lv_raid_merge(struct logical_volume *image_lv)
 		return_0;
 
 	if (!(p = strstr(lv_name, "_rimage_"))) {
-		log_error("Unable to merge non-mirror image %s.",
+		log_error("Unable to merge non-raid image %s.",
 			  display_lvname(image_lv));
 		return 0;
 	}
diff --git a/tools/args.h b/tools/args.h
index 603a0cf..c2fbac6 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -611,7 +611,9 @@ arg(splitcache_ARG, '\0', "splitcache", 0, 0, 0,
 arg(splitmirrors_ARG, '\0', "splitmirrors", number_VAL, 0, 0,
     "Splits the specified number of images from a raid1 or mirror LV\n"
     "and uses them to create a new LV. If --trackchanges is also specified,\n"
-    "changes to the raid1 LV are tracked while the split LV remains detached.\n")
+    "changes to the raid1 LV are tracked while the split LV remains detached.\n"
+    "If --name is specified, then the images are permanently split from the\n"
+    "original LV and changes are not tracked.\n")
 
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0,
     "Separates a COW snapshot from its origin LV. The LV that is split off\n"
@@ -691,10 +693,12 @@ arg(thinpool_ARG, '\0', "thinpool", lv_VAL, 0, 0,
 arg(trackchanges_ARG, '\0', "trackchanges", 0, 0, 0,
     "Can be used with --splitmirrors on a raid1 LV. This causes\n"
     "changes to the original raid1 LV to be tracked while the split images\n"
-    "remain detached. This allows the read-only detached image(s) to be\n"
-    "merged efficiently back into the raid1 LV later. Only the regions with\n"
-    "changed data are resynchronized during merge. (This option only applies\n"
-    "when using the raid1 LV type.)\n")
+    "remain detached. This is a temporary state that allows the read-only\n"
+    "detached image to be merged efficiently back into the raid1 LV later.\n"
+    "Only the regions with changed data are resynchronized during merge.\n"
+    "While a raid1 LV is tracking changes, operations on it are limited to\n"
+    "merging the split image (see --mergemirrors) or permanently splitting\n"
+    "the image (see --splitmirrors with --name.\n")
 
 /* TODO: hide this? */
 arg(trustcache_ARG, '\0', "trustcache", 0, 0, 0,
diff --git a/tools/command-lines.in b/tools/command-lines.in
index b7aefa3..a8c06ba 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -399,7 +399,7 @@ lvconvert --splitmirrors Number --trackchanges LV_raid1_cache
 OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_split_mirror_images
-DESC: Split images from a raid1 LV and track changes to origin.
+DESC: Split images from a raid1 LV and track changes to origin for later merge.
 RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --mergemirrors LV_linear_raid|VG|Tag ...


