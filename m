From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 17:38:54 -0400
Subject: master - lv_manip: add extra internal error
Message-ID: <201806222138.w5MLcs9x018675@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=106ee05ba01146abff248a4e7eae77982fda9ebd
Commit:        106ee05ba01146abff248a4e7eae77982fda9ebd
Parent:        6c84a36b539d02a5f975a1e5e98c180621078498
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 20 10:44:13 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 23:37:02 2018 +0200

lv_manip: add extra internal error

Catch error early, when trying to store data into non-allocated area.
---
 lib/metadata/lv_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 27cd2c1..4efe04a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1190,6 +1190,11 @@ int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
 			 display_lvname(seg->lv), seg->le, area_num,
 			 display_lvname(lv), le);
 
+	if (area_num >= seg->area_count) {
+		log_error(INTERNAL_ERROR "Try to set to high area number (%u >= %u) for LV %s.",
+			  area_num, seg->area_count, display_lvname(seg->lv));
+		return 0;
+	}
 	lv->status |= status;
 	if (lv_is_raid_metadata(lv)) {
 		seg->meta_areas[area_num].type = AREA_LV;


