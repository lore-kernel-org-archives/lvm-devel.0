From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 17:03:16 +0000 (UTC)
Subject: master - libdm: only free the first histogram explicitly (Coverity)
Message-ID: <20150907170316.92D0A60C19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bc7a86f3aefbb1b805f94a17891c501b7de40b0
Commit:        4bc7a86f3aefbb1b805f94a17891c501b7de40b0
Parent:        ffbf12504d24a25a66de53e11bfcbaac84c51ab5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 17:53:56 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 17:53:56 2015 +0100

libdm: only free the first histogram explicitly (Coverity)

Coverity flags a user-after-free in _stats_histograms_destroy():

>>>     Calling "dm_pool_free" frees pointer "mem->chunk" which has
>>>     already been freed.

This should not be possible since the histograms are destroyed in
reverse order of allocation:

 203         for (n = _nr_areas_region(region) - 1; n; n--)
 204                 if (region->counters[n].histogram)
 205                         dm_pool_free(mem, region->counters[n].histogram);

It appears that Coverity is unaware that pool->chunk is updated
during the call to dm_pool_free() and valgrind flags no errors in
this function when called with multiple allocated histograms.

Since there is no actual need to free the histograms individually
in this way simplify the code and just free the first allocated
object (which will also free all later allocated histograms in a
single call).
---
 libdm/libdm-stats.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 20e3c9b..d20949a 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -200,9 +200,11 @@ static void _stats_histograms_destroy(struct dm_pool *mem,
 	if (!region->counters)
 		return;
 
-	for (n = _nr_areas_region(region) - 1; n; n--)
-		if (region->counters[n].histogram)
-			dm_pool_free(mem, region->counters[n].histogram);
+	/*
+	 * Only the first histogram needs to be freed explicitly.
+	 */
+	if (region->counters[0].histogram)
+		dm_pool_free(mem, region->counters[0].histogram);
 }
 
 static void _stats_region_destroy(struct dm_stats_region *region)


