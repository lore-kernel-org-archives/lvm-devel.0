From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 22 Apr 2016 09:42:41 +0000 (UTC)
Subject: master - libdm-stats: check for empty region and area lists
Message-ID: <20160422094241.2D91361E7A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17ad8848361aa16ff227038068c3d0771771f095
Commit:        17ad8848361aa16ff227038068c3d0771771f095
Parent:        69c2f560053c0a5217592d571aa9ea03a6dbc267
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Apr 22 10:35:07 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Apr 22 10:35:07 2016 +0100

libdm-stats: check for empty region and area lists

Check that @stats_list and @stats_print returned data in the
_stats_parse_list() and _stats_parse_region() functions before
attempting to operate on region and area values.

This avoids a coverity warning since fgets() could potentially
return no data from the memory buffer returned by the ioctl.

In both cases the ioctl would return an error, preventing these
functions from running, however it is cleaner to test for the
condition explicitly and fail in those cases.
---
 libdm/libdm-stats.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 1dce3eb..f1c0560 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -680,6 +680,10 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 		nr_regions++;
 	}
 
+	if (!nr_regions)
+		/* no region data read from @stats_list */
+		goto bad;
+
 	dms->nr_regions = nr_regions;
 	dms->max_region = max_region - 1;
 	dms->regions = dm_pool_end_object(mem);
@@ -936,6 +940,10 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 		}
 	}
 
+	if (region->start == UINT64_MAX)
+		/* no area data read from @stats_print */
+		goto bad;
+
 	region->len = (start + len) - region->start;
 	region->timescale = timescale;
 	region->counters = dm_pool_end_object(mem);


