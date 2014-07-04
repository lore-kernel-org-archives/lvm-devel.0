From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:12 +0000 (UTC)
Subject: master - refactor: remove static modifier for lv_raid_image_in_sync and lv_raid_healthy fn
Message-ID: <20140704140012.4A34960F98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4734354ceedffc72314feb5323e73e63d5e8ec8
Commit:        a4734354ceedffc72314feb5323e73e63d5e8ec8
Parent:        9d2c445d0ac10bf54d39d9aa6e8695c469456489
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 1 09:56:03 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:40:17 2014 +0200

refactor: remove static modifier for lv_raid_image_in_sync and lv_raid_healthy fn

...to make use of it in other parts of the code.
---
 lib/metadata/lv.c |   12 ++++++------
 lib/metadata/lv.h |    3 +++
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 308b93d..1ede9d6 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -472,7 +472,7 @@ uint64_t lv_size(const struct logical_volume *lv)
 	return lv->size;
 }
 
-static int _lv_mimage_in_sync(const struct logical_volume *lv)
+int lv_mirror_image_in_sync(const struct logical_volume *lv)
 {
 	dm_percent_t percent;
 	struct lv_segment *seg = first_seg(lv);
@@ -491,7 +491,7 @@ static int _lv_mimage_in_sync(const struct logical_volume *lv)
 	return (percent == DM_PERCENT_100) ? 1 : 0;
 }
 
-static int _lv_raid_image_in_sync(const struct logical_volume *lv)
+int lv_raid_image_in_sync(const struct logical_volume *lv)
 {
 	unsigned s;
 	dm_percent_t percent;
@@ -555,7 +555,7 @@ static int _lv_raid_image_in_sync(const struct logical_volume *lv)
  *
  * Returns: 1 if healthy, 0 if device is not health
  */
-static int _lv_raid_healthy(const struct logical_volume *lv)
+int lv_raid_healthy(const struct logical_volume *lv)
 {
 	unsigned s;
 	char *raid_health;
@@ -662,14 +662,14 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else if (lv_is_thin_pool_data(lv))
 		repstr[0] = 'T';
 	else if (lv->status & MIRROR_IMAGE)
-		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
+		repstr[0] = (lv_mirror_image_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & RAID_IMAGE)
 		/*
 		 * Visible RAID_IMAGES are sub-LVs that have been exposed for
 		 * top-level use by being split from the RAID array with
 		 * '--splitmirrors 1 --trackchanges'.  They always report 'I'.
 		 */
-		repstr[0] = (!lv_is_visible(lv) && _lv_raid_image_in_sync(lv)) ?
+		repstr[0] = (!lv_is_visible(lv) && lv_raid_image_in_sync(lv)) ?
 			'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
@@ -768,7 +768,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		uint64_t n;
 		if (!activation())
 			repstr[8] = 'X';	/* Unknown */
-		else if (!_lv_raid_healthy(lv))
+		else if (!lv_raid_healthy(lv))
 			repstr[8] = 'r';  /* RAID needs 'r'efresh */
 		else if (lv->status & RAID) {
 			if (lv_raid_mismatch_count(lv, &n) && n)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index f298162..3a21f94 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -98,4 +98,7 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 struct logical_volume *lv_ondisk(struct logical_volume *lv);
 struct profile *lv_config_profile(const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
+int lv_mirror_image_in_sync(const struct logical_volume *lv);
+int lv_raid_image_in_sync(const struct logical_volume *lv);
+int lv_raid_healthy(const struct logical_volume *lv);
 #endif /* _LVM_LV_H */


