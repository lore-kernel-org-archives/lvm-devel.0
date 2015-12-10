From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Dec 2015 20:07:06 +0000 (UTC)
Subject: master - cache: support stacked rename
Message-ID: <20151210200706.A3CEB610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf4b74c5eb55cdb77c8a7e7e697fb2d43b39c718
Commit:        bf4b74c5eb55cdb77c8a7e7e697fb2d43b39c718
Parent:        dcb26b5f136ad861356d5c118921a254cae2cab4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 7 13:53:00 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 10 21:01:24 2015 +0100

cache: support stacked rename

Preserve skip_pool flag when running for_each_sub_lv() so
lvrename continues to work when thin-pool is using cached
data LV.
---
 lib/metadata/lv_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2f37f5b..6a93a76 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4154,7 +4154,7 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv))) {
 		if (!fn(org, data))
 			return_0;
-		if (!for_each_sub_lv(org, fn, data))
+		if (!_for_each_sub_lv(org, skip_pools, fn, data))
 			return_0;
 	}
 
@@ -4162,21 +4162,21 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 		if (seg->log_lv) {
 			if (!fn(seg->log_lv, data))
 				return_0;
-			if (!for_each_sub_lv(seg->log_lv, fn, data))
+			if (!_for_each_sub_lv(seg->log_lv, skip_pools, fn, data))
 				return_0;
 		}
 
 		if (seg->metadata_lv) {
 			if (!fn(seg->metadata_lv, data))
 				return_0;
-			if (!for_each_sub_lv(seg->metadata_lv, fn, data))
+			if (!_for_each_sub_lv(seg->metadata_lv, skip_pools, fn, data))
 				return_0;
 		}
 
 		if (seg->pool_lv && !skip_pools) {
 			if (!fn(seg->pool_lv, data))
 				return_0;
-			if (!for_each_sub_lv(seg->pool_lv, fn, data))
+			if (!_for_each_sub_lv(seg->pool_lv, skip_pools, fn, data))
 				return_0;
 		}
 
@@ -4185,7 +4185,7 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 				continue;
 			if (!fn(seg_lv(seg, s), data))
 				return_0;
-			if (!for_each_sub_lv(seg_lv(seg, s), fn, data))
+			if (!_for_each_sub_lv(seg_lv(seg, s), skip_pools, fn, data))
 				return_0;
 		}
 
@@ -4198,7 +4198,7 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 				continue;
 			if (!fn(seg_metalv(seg, s), data))
 				return_0;
-			if (!for_each_sub_lv(seg_metalv(seg, s), fn, data))
+			if (!_for_each_sub_lv(seg_metalv(seg, s), skip_pools, fn, data))
 				return_0;
 		}
 	}


