From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:55 +0000 (UTC)
Subject: master - cleanup: function embeded
Message-ID: <20141024144055.9123D60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b23e125982ea5f1c4b712a31b2133526a8fc12d8
Commit:        b23e125982ea5f1c4b712a31b2133526a8fc12d8
Parent:        21798418fc81a232d00e5a93ce4071004e6f0fed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 13:40:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

cleanup: function embeded

It's used just in one place now.
---
 tools/lvcreate.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7ccd9aa..8c52611 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -283,16 +283,6 @@ static int _determine_snapshot_type(struct volume_group *vg,
 	return 1;
 }
 
-static int _lvcreate_update_pool_params(struct volume_group *vg,
-					struct lvcreate_params *lp)
-{
-	return update_pool_params(lp->segtype, vg, lp->target_attr,
-				  lp->passed_args, lp->extents,
-				  &lp->pool_metadata_size,
-				  &lp->thin_chunk_size_calc_policy, &lp->chunk_size,
-				  &lp->discards, &lp->zero);
-}
-
 /*
  * _determine_cache_argument
  * @vg
@@ -458,7 +448,11 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_pool) {
-		if (!_lvcreate_update_pool_params(vg, lp))
+		if (!update_pool_params(lp->segtype, vg, lp->target_attr,
+					lp->passed_args, lp->extents,
+					&lp->pool_metadata_size,
+					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
+					&lp->discards, &lp->zero))
 			return_0;
 
 		if (!(lp->pool_metadata_extents =


