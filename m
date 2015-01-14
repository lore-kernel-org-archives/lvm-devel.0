From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 13:54:48 +0000 (UTC)
Subject: master - cleanup: properly align code lines
Message-ID: <20150114135448.6FC0360C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0f26440eed53fd34faf2773a9a7faf6deaf7d66
Commit:        d0f26440eed53fd34faf2773a9a7faf6deaf7d66
Parent:        d202f43fff6ff7d12540440ae6b16a0ec2c7de5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 14 12:51:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 14:50:08 2015 +0100

cleanup: properly align code lines

Misaligned indetion in branches.
---
 lib/activate/dev_manager.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 18092db..c134e1b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -145,26 +145,26 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		if (!dm_get_status_cache(seg_status->mem, params,
 			(struct dm_status_cache **) &seg_status->status))
 				return_0;
-			seg_status->type = SEG_STATUS_CACHE;
+		seg_status->type = SEG_STATUS_CACHE;
 	} else if (!strcmp(segtype->name, "raid")) {
 		if (!dm_get_status_raid(seg_status->mem, params,
-			(struct dm_status_raid **) &seg_status->status))
-				return_0;
-			seg_status->type = SEG_STATUS_RAID;
+					(struct dm_status_raid **) &seg_status->status))
+			return_0;
+		seg_status->type = SEG_STATUS_RAID;
 	} else if (!strcmp(segtype->name, "thin")) {
 		if (!dm_get_status_thin(seg_status->mem, params,
-			(struct dm_status_thin **) &seg_status->status))
-				return_0;
-			seg_status->type = SEG_STATUS_THIN;
+					(struct dm_status_thin **) &seg_status->status))
+			return_0;
+		seg_status->type = SEG_STATUS_THIN;
 	} else if (!strcmp(segtype->name, "thin-pool")) {
 		if (!dm_get_status_thin_pool(seg_status->mem, params,
-			(struct dm_status_thin_pool **) &seg_status->status))
-				return_0;
-			seg_status->type = SEG_STATUS_THIN_POOL;
+					     (struct dm_status_thin_pool **) &seg_status->status))
+			return_0;
+		seg_status->type = SEG_STATUS_THIN_POOL;
 	} else if (!strcmp(segtype->name, "snapshot")) {
 		if (!dm_get_status_snapshot(seg_status->mem, params,
-			(struct dm_status_snapshot **) &seg_status->status))
-				return_0;
+					    (struct dm_status_snapshot **) &seg_status->status))
+			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
 	}
 


