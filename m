From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:52 -0400
Subject: master - cleanup: drop unused parameter
Message-ID: <201706161513.v5GFDqMa011240@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e96f96a410c7ff977fa8593dff185fbe90615fe
Commit:        9e96f96a410c7ff977fa8593dff185fbe90615fe
Parent:        cdb55c19cd7633cd3467525f6f2b84ef77350d72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 15 11:21:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:02 2017 +0200

cleanup: drop unused parameter

---
 lib/metadata/raid_manip.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0f52ecf..5c3f9ef 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3994,7 +3994,6 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 				    uint32_t new_image_count,
 				    uint32_t new_region_size,
 				    struct dm_list *allocate_pvs,
-				    int update_and_reload,
 				    struct dm_list *removal_lvs)
 {
 	struct logical_volume *log_lv;
@@ -4051,7 +4050,10 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	if (!attach_mirror_log(first_seg(lv), log_lv))
 		return_0;
 
-	return update_and_reload ? _lv_update_reload_fns_reset_eliminate_lvs(lv, 0, removal_lvs, NULL) : 1;
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, removal_lvs, NULL))
+		return_0;
+
+	return 1;
 }
 
 /*
@@ -4786,7 +4788,7 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
 		return_0;
 
 	return _convert_raid1_to_mirror(lv, new_segtype, new_image_count, new_region_size,
-					allocate_pvs, 1, &removal_lvs);
+					allocate_pvs, &removal_lvs);
 }
 
 /*


