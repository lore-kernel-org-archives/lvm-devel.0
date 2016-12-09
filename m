From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  9 Dec 2016 10:56:08 +0000 (UTC)
Subject: master - libdm-stats: fix dm_stats_delete_region() performance
Message-ID: <20161209105608.1F5C860AB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dd0bd0255d585feca61000432d2de9552ede4e0
Commit:        6dd0bd0255d585feca61000432d2de9552ede4e0
Parent:        0ce9ae3cda9411f8f2a5491b07a6c4f06ab44da1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Dec 8 20:55:47 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Dec 9 10:55:39 2016 +0000

libdm-stats: fix dm_stats_delete_region() performance

Fix a silly bug in dm_stats_delete_region() that hugely inflates
runtimes when deleting a large number of regions.

For ~50,000 regions this change reduces the runtime from 98s to
6s on my test systems (a ~93% reduction).

The bug exists because dm_stats_delete_region() applies a truth
test to the return value of dm_stats_get_nr_areas(); this is
never correct usage - it will walk the entire region table and
calculate area counts for each region (which is roughly O(n^2)
in the number of regions, as dm_stats_delete_region() is being
called inside a region walk).

Although the individual area calculation is not that costly,
uselessly running anything 2,500,000,000 times over gets a bit
slow.

A much cheaper test (which is always true if the areas check is
true) is to just test dm_stats_get_nr_regions() or dms->regions;
if either is true it implies at least one area exists.

Old:

 Performance counter stats for 'dmstats delete --allregions --alldevices':

      98117.791458      task-clock (msec)         #    1.000 CPUs utilized
               127      context-switches          #    0.001 K/sec
                 3      cpu-migrations            #    0.000 K/sec
             6,631      page-faults               #    0.068 K/sec
   307,711,724,562      cycles                    #    3.136 GHz
   544,762,959,577      instructions              #    1.77  insn per cycle
    84,287,824,115      branches                  #  859.047 M/sec
         2,538,875      branch-misses             #    0.00% of all branches

      98.119578733 seconds time elapsed

New:

 Performance counter stats for 'dmstats delete --allregions --alldevices':

       6427.251074      task-clock (msec)         #    1.000 CPUs utilized
                 6      context-switches          #    0.001 K/sec
                 0      cpu-migrations            #    0.000 K/sec
             6,634      page-faults               #    0.001 M/sec
    21,613,018,724      cycles                    #    3.363 GHz
     3,794,755,445      instructions              #    0.18  insn per cycle
       852,974,026      branches                  #  132.712 M/sec
           808,625      branch-misses             #    0.09% of all branches

       6.428953647 seconds time elapsed
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 2fc00da..411fd80 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2051,7 +2051,7 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 		goto bad;
 	}
 
-	if (!dm_stats_get_nr_areas(dms)) {
+	if (!dm_stats_get_nr_regions(dms)) {
 		log_error("Could not delete region ID " FMTu64 ": "
 			  "no regions found", region_id);
 		goto bad;


