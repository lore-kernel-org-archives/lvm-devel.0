From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  9 Dec 2016 16:04:30 +0000 (UTC)
Subject: master - libdm: use correct region_id when cleaning up a failed filemap
Message-ID: <20161209160430.94BC460C9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30ad254d84047ffe3eba98943855b53a893390e2
Commit:        30ad254d84047ffe3eba98943855b53a893390e2
Parent:        7fd2fa22ddb3ed97283305100567cc4b5122ddb3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 9 15:50:41 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Dec 9 16:04:13 2016 +0000

libdm: use correct region_id when cleaning up a failed filemap

If we fail to create a region during dm_stats_create_regions_from_fd(),
we must remove all regions that were created to do this to date. This
needs to loop over the table of region_id values that were populated
by _stats_create_file_regions() before the error.

The code for this failure case in the out_remove branch incorrectly
uses the table index as the region_id:

    for (--i; i != DM_STATS_REGION_NOT_PRESENT; i--) {
            if (!dm_stats_delete_region(dms, i))
                    log_error("Could not delete region " FMTu64 ".", i);
    }

This causes the cleanup code to delete a completely unrelated set
of regions (since the index here will always be nr_regions..0).

Fix it to pass the actual region_id stored in regions[i] instead.
---
 libdm/libdm-stats.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3900433..438a1ed 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4382,10 +4382,9 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 
 out_remove:
 	/* clean up regions after create failure */
-	for (--i; i != DM_STATS_REGION_NOT_PRESENT; i--) {
-		if (!dm_stats_delete_region(dms, i))
+	for (--i; i != DM_STATS_REGION_NOT_PRESENT; i--)
+		if (!dm_stats_delete_region(dms, regions[i]))
 			log_error("Could not delete region " FMTu64 ".", i);
-	}
 
 out:
 	dm_pool_free(dms->mem, extents);


