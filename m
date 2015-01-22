From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 22 Jan 2015 09:14:50 +0000 (UTC)
Subject: master - coverity: missing return value check
Message-ID: <20150122091450.D88276024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0fddc5ab5c892d02fd097828de36ee033dc1e7b3
Commit:        0fddc5ab5c892d02fd097828de36ee033dc1e7b3
Parent:        e0dc3d5efb6da6d45994f88e9d89e6657a183aac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 22 10:11:19 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jan 22 10:11:19 2015 +0100

coverity: missing return value check

Reported by coverity for code added recently - _avoid_pvs_with_other_images_of_lv
which calls process_each_sub_lv and not checking return value.
---
 lib/metadata/raid_manip.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d502379..5c2ca95 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1563,9 +1563,9 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
  * by setting the internal PV_ALLOCATION_PROHIBITED flag to use it to avoid generating
  * pv maps for those PVs.
  */
-static void _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+static int _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
-	for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
+	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
 }
 
 /*
@@ -1667,7 +1667,11 @@ int lv_raid_replace(struct logical_volume *lv,
 	}
 
 	/* Prevent any PVs holding image components from being used for allocation */
-	_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs);
+	if (!_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
+		log_error("Failed to prevent PVs holding image components "
+			  "from being used for allocation.");
+		return 0;
+	}
 
 	/*
 	 * Allocate the new image components first


