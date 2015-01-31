From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:35 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - v2 adjust __avoid_pvs_with_other_images_of_lv() to upstream
Message-ID: <20150131141035.0A700601E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=291486655d75f5c1f92364a43b11f41b0faeb38f
Commit:        291486655d75f5c1f92364a43b11f41b0faeb38f
Parent:        dc8fbe0a7f2832fc57899b4f40cc2f905fe94baa
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jan 28 13:48:37 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jan 28 13:48:37 2015 +0100

v2 adjust __avoid_pvs_with_other_images_of_lv() to upstream

---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 220c751..d60c708 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2763,7 +2763,7 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
  * Prevent any PVs holding other image components of @lv from being used for allocation,
  * I.e. remove respective PVs from @allocatable_pvs
  */
-static void __avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+static int __avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
 	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
 }
@@ -2874,7 +2874,7 @@ int lv_raid_replace(struct logical_volume *lv,
 	}
 
 	/* Prevent any PVs holding image components from being used for allocation */
-	if (!_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
+	if (!__avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
 		log_error("Failed to prevent PVs holding image components "
 			  "from being used for allocation.");
 		return 0;


