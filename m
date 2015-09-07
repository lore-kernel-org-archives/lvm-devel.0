From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 10:16:42 +0000 (UTC)
Subject: master - dmsetup: fix bounds leak in _do_stats_create_regions()
Message-ID: <20150907101642.B981B602FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a26523330e8f461b90eca7d2dcea0d0a6866e635
Commit:        a26523330e8f461b90eca7d2dcea0d0a6866e635
Parent:        2a022e9e6ef24741c5ebf1ebeaff6241cc505287
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 11:14:28 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 11:14:28 2015 +0100

dmsetup: fix bounds leak in _do_stats_create_regions()

If we fail to create the DM_DEVICE_TABLE dm_task destroy the bounds
object before returning.
---
 tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 61ad5a9..8b7ad74 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4674,6 +4674,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 		return_0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
+		dm_histogram_bounds_destroy(bounds);
 		dm_stats_destroy(dms);
 		return_0;
 	}


