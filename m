From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 10 Feb 2017 22:44:36 +0000 (UTC)
Subject: master - lvconvert: remove test code
Message-ID: <20170210224436.D7EF960FB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8296b99a89b849d7d7b5dcac6214582b3eaad639
Commit:        8296b99a89b849d7d7b5dcac6214582b3eaad639
Parent:        28ea66d46d46414d6ab1c452115ff5120f4a9525
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 10 23:43:56 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 10 23:44:27 2017 +0100

lvconvert: remove test code

Remove allocate_pvs from raid_manip.c:_region_size_change_request() API
and lv_extend() using it added for temporary test purpose.

Related: rhbz1366296
---
 lib/metadata/raid_manip.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index dbb6128..25783a8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4122,8 +4122,7 @@ replaced:
  * Change region size on raid @lv to @region_size if
  * different from current region_size and adjusted region size
  */
-static int _region_size_change_requested(struct logical_volume *lv, int yes, const uint32_t region_size,
-					 struct dm_list *allocate_pvs)
+static int _region_size_change_requested(struct logical_volume *lv, int yes, const uint32_t region_size)
 {
 	uint32_t old_region_size;
 	const char *seg_region_size_str;
@@ -4185,7 +4184,6 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 	    _raid_rmeta_extents(lv->vg->cmd, lv->le_count, seg->region_size, lv->vg->extent_size)) {
 		log_error("Region size %s on %s is too small for metadata LV size.",
 			  seg_region_size_str, display_lvname(lv));
-if (!lv_extend(lv, seg->segtype, seg->area_count - seg->segtype->parity_devs, seg->stripe_size, 1, seg->region_size, 0, allocate_pvs, lv->vg->alloc, 0))
 		return 0;
 	}
 
@@ -4290,7 +4288,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	       if (new_segtype == seg->segtype &&
 	           new_region_size != seg->region_size &&
 		   seg_is_raid(seg) && !seg_is_any_raid0(seg))
-			return _region_size_change_requested(lv, yes, new_region_size, allocate_pvs);
+			return _region_size_change_requested(lv, yes, new_region_size);
 	} else
 		region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
 


