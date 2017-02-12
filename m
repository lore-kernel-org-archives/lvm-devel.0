From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 12 Feb 2017 16:30:48 +0000 (UTC)
Subject: master - coverity: fix mem leak on error path in dm stats
Message-ID: <20170212163048.EEFBD610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7d2ee4bc2dd032cd15db028b3c118ce7138c854
Commit:        a7d2ee4bc2dd032cd15db028b3c118ce7138c854
Parent:        0844b20f985177f60db48dc84bcde7170d17a77e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 21:17:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 12 17:28:13 2017 +0100

coverity: fix mem leak on error path in dm stats

Free allocated resouces on error path.
---
 libdm/libdm-stats.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f68874c..032be03 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4842,7 +4842,7 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 		if (!bounds) {
 			log_error("Could not allocate memory for group "
 				  "histogram bounds.");
-			return NULL;
+			goto out;
 		}
 		_stats_copy_histogram_bounds(bounds,
 					     dms->regions[group_id].bounds);
@@ -4869,6 +4869,8 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 bad:
 	_stats_cleanup_region_ids(dms, regions, count);
 	dm_free(bounds);
+	dm_free(regions);
+out:
 	dm_free((char *) alias);
 	return NULL;
 }


