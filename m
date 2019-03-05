From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:48 -0500
Subject: stable-2.02 - stats: fix error path when region is NULL
Message-ID: <201903051353.x25DrmH6006802@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8fc64c5ee67c90ac33df657ec514216ce2a804b9
Commit:        8fc64c5ee67c90ac33df657ec514216ce2a804b9
Parent:        8d44cd3e47a05db4983bcb8e8e1c08cfe80708ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:12:40 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:57:40 2019 +0100

stats: fix error path when region is NULL

We should not call _stats_cleanup_region_ids() when regions
are NULL.
Also add backtracing for  goto.

(cherry picked from commit 3750b0cff5ab1c41076afdf8275e3fa20aa756d0)
---
 libdm/libdm-stats.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3078596..deb20c9 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4869,24 +4869,24 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 					  group_id, &count, &regroup);
 
 	if (!regions)
-		goto bad;
+		goto_out;
 
 	if (!dm_stats_list(dms, NULL))
-		goto bad;
+		goto_bad;
 
 	/* regroup if there are regions to group */
 	if (regroup && (*regions != DM_STATS_REGION_NOT_PRESENT))
 		if (!_stats_group_file_regions(dms, regions, count, alias))
-			goto bad;
+			goto_bad;
 
 	dm_free(bounds);
 	dm_free((char *) alias);
 	return regions;
 bad:
 	_stats_cleanup_region_ids(dms, regions, count);
-	dm_free(bounds);
-	dm_free(regions);
 out:
+	dm_free(regions);
+	dm_free(bounds);
 	dm_free((char *) alias);
 	return NULL;
 }


