From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Jan 2017 22:40:21 +0000 (UTC)
Subject: master - raid: postpone archiving until metadata are changed
Message-ID: <20170106224021.3A20360506@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4be2be5a441e3a85d50ce5728b9d1b82e7d1fc6
Commit:        a4be2be5a441e3a85d50ce5728b9d1b82e7d1fc6
Parent:        0d2a9ebec6b7555a09f26aa513b2a2f94fc19027
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 6 23:36:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 6 23:39:04 2017 +0100

raid: postpone archiving until metadata are changed

Avoid archiving of lvm2 metadata when there is call of 'lvconvert --repair'
on healthy raid LV.
---
 lib/metadata/raid_manip.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index bceff79..8c88280 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3952,9 +3952,6 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!archive(lv->vg))
-		return_0;
-
 	/*
 	 * How many sub-LVs are being removed?
 	 */
@@ -3972,6 +3969,9 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 		    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs)) {
 			match_count++;
 			if (rebuild) {
+				if ((match_count == 1) &&
+				    !archive(lv->vg))
+					return_0;
 				seg_lv(raid_seg, s)->status |= LV_REBUILD;
 				seg_metalv(raid_seg, s)->status |= LV_REBUILD;
 			}
@@ -4017,6 +4017,9 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	if (rebuild)
 		goto skip_alloc;
 
+	if (!archive(lv->vg))
+		return_0;
+
 	/* Prevent any PVs holding image components from being used for allocation */
 	if (!_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
 		log_error("Failed to prevent PVs holding image components "


