From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Jan 2022 17:42:19 +0000 (GMT)
Subject: main - remove unused variable
Message-ID: <20220113174219.A268A385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c80ea88477b3511562036748d3bf837bf7b3e8b
Commit:        0c80ea88477b3511562036748d3bf837bf7b3e8b
Parent:        18f451e09e943eb3d51f8394f6fe8967e1e9f565
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 13 11:41:09 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 13 11:41:39 2022 -0600

remove unused variable

resulting from commit cb798ee1c102aadde93965a894c5aa59d4e76e4a
  "lvmcache: remove lvmcache_update_vg_from_write"
---
 lib/metadata/metadata.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7e5605820..db0e511ec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3100,7 +3100,6 @@ static int _vg_commit_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda, *tmda;
 	DM_LIST_INIT(ignored);
-	int failed = 0;
 	int good = 0;
 
 	/* Rearrange the metadata_areas_in_use so ignored mdas come first. */
@@ -3115,11 +3114,9 @@ static int _vg_commit_mdas(struct volume_group *vg)
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->status & MDA_FAILED)
 			continue;
-		failed = 0;
 		if (mda->ops->vg_commit &&
 		    !mda->ops->vg_commit(vg->fid, vg, mda)) {
 			stack;
-			failed = 1;
 		} else
 			good++;
 	}


