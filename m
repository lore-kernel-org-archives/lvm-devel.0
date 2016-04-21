From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:47 +0000 (UTC)
Subject: master - coverity: drop abadoing object
Message-ID: <20160421231847.0A28A616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c4b717f4db7e3aed2a6e1f8bf7f5ecb722d35e4
Commit:        8c4b717f4db7e3aed2a6e1f8bf7f5ecb722d35e4
Parent:        0bf55186263de96c0f7377c631d27d9679d4df27
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:55:23 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:13:35 2016 +0200

coverity: drop abadoing object

As mempool is destroyed on by caller don't bother for
mempool freeing here.
---
 lib/metadata/metadata.c |   28 +++++++++++-----------------
 1 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e9f5fa5..f9ce080 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4610,10 +4610,10 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 				found_inconsistent = 1;
 			} else {
 				if (!dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1))
-					goto_bad;
+					return_0;
 			}
 			if (!dm_pool_grow_object(mem, dev_name(dev), 0))
-				goto_bad;
+				return_0;
 		}
 	}
 
@@ -4621,7 +4621,7 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 		return 1;
 
 	if (!dm_pool_grow_object(mem, "\0", 1))
-		goto_bad;
+		return_0;
 	used_devnames = dm_pool_end_object(mem);
 
 	found_inconsistent = 0;
@@ -4630,9 +4630,9 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 			if (seg_type(seg, s) == AREA_PV) {
 				if (!(dev = seg_dev(seg, s))) {
 					log_error("Couldn't find device for segment belonging to "
-						  "%s/%s while checking used and assumed devices.",
-						  lv->vg->name, lv->name);
-					goto bad;
+						  "%s while checking used and assumed devices.",
+						  display_lvname(lv));
+					return 0;
 				}
 				if (!(dev->flags & DEV_USED_FOR_LV)) {
 					if (!found_inconsistent) {
@@ -4640,10 +4640,10 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 						found_inconsistent = 1;
 					} else {
 						if (!dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1))
-							goto_bad;
+							return_0;
 					}
 					if (!dm_pool_grow_object(mem, dev_name(dev), 0))
-						goto bad;
+						return_0;
 				}
 			}
 		}
@@ -4651,20 +4651,14 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 
 	if (found_inconsistent) {
 		if (!dm_pool_grow_object(mem, "\0", 1))
-			goto_bad;
+			return_0;
 		assumed_devnames = dm_pool_end_object(mem);
 	}
 
-	log_warn("WARNING: Device mismatch detected for %s/%s which is accessing %s instead of %s.",
-		 lv->vg->name, lv->name, used_devnames, assumed_devnames);
+	log_warn("WARNING: Device mismatch detected for %s which is accessing %s instead of %s.",
+		 display_lvname(lv), used_devnames, assumed_devnames);
 
-	/* This also frees assumed_devnames. */
-	dm_pool_free(mem, (void *) used_devnames);
 	return 1;
-bad:
-	if (found_inconsistent)
-		dm_pool_abandon_object(mem);
-	return 0;
 }
 
 static int _check_devs_used_correspond_with_vg(struct volume_group *vg)


