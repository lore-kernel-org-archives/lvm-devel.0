From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 14 Oct 2013 20:16:20 +0000 (UTC)
Subject: master - RAID: Better error message when attempting scrubbing op on thinpool LV
Message-ID: <20131014201620.6CEA160E81@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d97583cfd395e5e31888558361ae9467cea60260
Commit:        d97583cfd395e5e31888558361ae9467cea60260
Parent:        f58b26b6338b2939e6a88174ac2dc185b345118b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Oct 14 15:14:16 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Oct 14 15:14:16 2013 -0500

RAID: Better error message when attempting scrubbing op on thinpool LV

Component LVs of a thinpool can be RAID LVs.  Users who attempt a
scrubbing operation directly on a thinpool will be prompted to
specify the sub-LV they wish the operation to be performed on.  If
neither of the sub-LVs are RAID, then a message telling them that
the operation can only be performed on a RAID LV will be given.
---
 lib/activate/activate.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7621f44..6948060 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -888,6 +888,18 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 	struct dm_status_raid *status;
 
 	if (!seg_is_raid(first_seg(lv))) {
+		/*
+		 * Make it easier for user to know what to do when
+		 * they are using thinpool.
+		 */
+		if (lv_is_thin_pool(lv) &&
+		    (lv_is_raid(seg_lv(first_seg(lv), 0)) ||
+		     lv_is_raid(first_seg(lv)->metadata_lv))) {
+			log_error("Thinpool data or metadata volume"
+				  " must be specified. (e.g. \"%s/%s_tdata\")",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
 		log_error("%s/%s must be a RAID logical volume to"
 			  " perform this action.", lv->vg->name, lv->name);
 		return 0;


