From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 17 Nov 2016 11:43:21 +0000 (UTC)
Subject: master - libdm: separate dm_stats_populate() error cases
Message-ID: <20161117114321.B89966072D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a86f54b09312db58b662b1779557466a639567f
Commit:        2a86f54b09312db58b662b1779557466a639567f
Parent:        6de05cf5f5aa7c4125b20c11a13356b58ea2ff14
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Nov 17 11:39:43 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Nov 17 11:39:43 2016 +0000

libdm: separate dm_stats_populate() error cases

There are two possible errors in _dm_stats_populate_region():

  * No region struct in dms->regions[region_id]
  * Failure to parse data from @stats_print

These have very different causes: the first occurs where a client
program is populating one region at a time (region_id is a single
region identifier), and has not previously called dm_stats_list()
to dimension the region tables; this is an API usage error.

The second occurs when either we read unparseable data from the
kernel (kernel bug), or where various resource allocations fail.

Separate these two cases out and log separate messages for each
(allocation failures in the path already have their own distinct
message), since the "failed to parse.." message in the un-listed
handle case is confusing and misleading.
---
 libdm/libdm-stats.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 55e2a42..ad3e624 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2241,7 +2241,11 @@ static int _dm_stats_populate_region(struct dm_stats *dms, uint64_t region_id,
 	if (!_stats_bound(dms))
 		return_0;
 
-	if (!region || !_stats_parse_region(dms, resp, region, region->timescale)) {
+	if (!region) {
+		log_error("Cannot populate empty handle before dm_stats_list().");
+		return 0;
+	}
+	if (!_stats_parse_region(dms, resp, region, region->timescale)) {
 		log_error("Could not parse @stats_print message response.");
 		return 0;
 	}


