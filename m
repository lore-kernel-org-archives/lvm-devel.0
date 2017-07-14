From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 14 Jul 2017 09:53:53 -0400
Subject: master - raid: use return_0 for better backtracking
Message-ID: <201707141353.v6EDrrWB025122@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1d69fc7c5e8ed301817253f6c8a9f8e806015a03
Commit:        1d69fc7c5e8ed301817253f6c8a9f8e806015a03
Parent:        1c4b7a3c2d2691f6f0accf04af2e31e4379b3baf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jul 14 14:05:21 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 14 15:53:23 2017 +0200

raid: use return_0 for better backtracking

---
 lib/metadata/raid_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ada25ab..e35b999 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1622,7 +1622,8 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 			       allocate_pvs, lv->alloc, 0)) {
 			log_error("Failed to allocate out-of-place reshape space for %s.",
 				  display_lvname(lv));
-			return _lv_alloc_reshape_post_extend(lv, segtype_sav, stripe_size_sav, lv_size_cur);
+			if (!_lv_alloc_reshape_post_extend(lv, segtype_sav, stripe_size_sav, lv_size_cur))
+				return_0;
 		}
 
 		/* pay attention to lv_extend maybe having allocated more because of layout specific rounding */
@@ -1630,7 +1631,7 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 			return_0;
 
 		if (!_lv_alloc_reshape_post_extend(lv, segtype_sav, stripe_size_sav, lv_size_cur))
-			return 0;
+			return_0;
 
 		/* Update and reload mapping for proper size of data SubLVs in the cluster */
 		if (!lv_update_and_reload(lv))


