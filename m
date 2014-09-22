From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:46 +0000 (UTC)
Subject: dev-dct-process-latest - raid: add missing archive call
Message-ID: <20140922153746.ED98160D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08bde75093665001e7b30a7491c5bb9a53383d56
Commit:        08bde75093665001e7b30a7491c5bb9a53383d56
Parent:        569184a3bb124f94bc79c1a1d042f686270e7864
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:30:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:45:49 2014 +0200

raid: add missing archive call

Before starting to update raid metadata, archive existing unmodified one.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f65d7fb..a84ef4b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Archive metadata before starting their modification in raid target.
   Add missing vg_revert in suspend_lv() error path in raid target.
   Add missing backup of lvm2 metadata after some raid modifications.
   Use vg memory pool for extent allocation.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 989244c..4bfe9c9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -520,6 +520,9 @@ static int _raid_add_images(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (!archive(lv->vg))
+		return_0;
+
 	dm_list_init(&meta_lvs); /* For image addition */
 	dm_list_init(&data_lvs); /* For image addition */
 
@@ -909,6 +912,9 @@ static int _raid_remove_images(struct logical_volume *lv,
 	struct dm_list removal_list;
 	struct lv_list *lvl;
 
+	if (!archive(lv->vg))
+		return_0;
+
 	dm_list_init(&removal_list);
 
 	if (!_raid_extract_images(lv, new_count, pvs, 1,
@@ -1313,6 +1319,9 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (!archive(lv->vg))
+		return_0;
+
 	for (s = 0; s < seg->area_count; s++) {
 		log_debug_metadata("Allocating new metadata LV for %s",
 				   seg_lv(seg, s)->name);
@@ -1543,6 +1552,9 @@ int lv_raid_replace(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (!archive(lv->vg))
+		return_0;
+
 	/*
 	 * How many sub-LVs are being removed?
 	 */
@@ -1767,6 +1779,9 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 		return 0;
 	}
 
+	if (!archive(lv->vg))
+		return_0;
+
 	log_debug("Attempting to remove missing devices from %s LV, %s",
 		  seg->segtype->ops->name(seg), lv->name);
 


