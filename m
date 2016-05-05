From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:35 +0000 (UTC)
Subject: master - cleanup: enhance warning message
Message-ID: <20160505220135.9429760C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed9162cd882426109fba14413ff2840edfd99341
Commit:        ed9162cd882426109fba14413ff2840edfd99341
Parent:        f6575ec824964ee2f830746e12b12a887c95e7f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 21:13:41 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:55:18 2016 +0200

cleanup: enhance warning message

Add WARNING: for log_warn.
Show device name which is marked missing.
---
 lib/metadata/metadata.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c8237d5..c7d3fcf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -691,7 +691,7 @@ static int _check_pv_dev_sizes(struct volume_group *vg)
 		size = pv_size(pvl->pv);
 
 		if (dev_size < size) {
-			log_warn("Device %s has size of %" PRIu64 " sectors which "
+			log_warn("WARNING: Device %s has size of %" PRIu64 " sectors which "
 				 "is smaller than corresponding PV size of %" PRIu64
 				  " sectors. Was device resized?",
 				  pv_dev_name(pvl->pv), dev_size, size);
@@ -3890,7 +3890,7 @@ static int _check_reappeared_pv(struct volume_group *correct_vg,
 	dm_list_iterate_items(pvl, &correct_vg->pvs)
 		if (pv->dev == pvl->pv->dev && is_missing_pv(pvl->pv)) {
 			if (act)
-				log_warn("Missing device %s reappeared, updating "
+				log_warn("WARNING: Missing device %s reappeared, updating "
 					 "metadata for VG %s to version %u.",
 					 pv_dev_name(pvl->pv),  pv_vg_name(pvl->pv), 
 					 correct_vg->seqno);
@@ -3901,9 +3901,11 @@ static int _check_reappeared_pv(struct volume_group *correct_vg,
 				}
 				++ rv;
 			} else if (act)
-				log_warn("Device still marked missing because of allocated data "
-					 "on it, remove volumes and consider vgreduce --removemissing.");
+				log_warn("WARNING: Device %s still marked missing because of allocated data "
+					 "on it, remove volumes and consider vgreduce --removemissing.",
+					 pv_dev_name(pvl->pv));
 		}
+
 	return rv;
 }
 


