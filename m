From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 10:16:44 +0000 (UTC)
Subject: master - libdm: do not permit grouping regions with histograms
Message-ID: <20160706101644.D97DE61BEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28658541daef567f0f767190c244a100ea45476f
Commit:        28658541daef567f0f767190c244a100ea45476f
Parent:        1faa208067df2989c716fff40568f3948392b186
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 11:10:23 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 11:10:23 2016 +0100

libdm: do not permit grouping regions with histograms

Although not harmful do not allow a group containing regions with
histograms since it is not currently possible to present histogram
data aggregated for the group.
---
 libdm/libdm-stats.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index c669b51..06aa645 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3767,7 +3767,11 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 				  FMTu64, i, dms->regions[i].group_id);
 			goto bad;
 		}
-
+		if (dms->regions[i].bounds) {
+			log_error("Region ID %d: grouping regions with "
+				  "histograms is not yet supported", i);
+			goto bad;
+		}
 		if (dms->regions[i].timescale == 1)
 			precise++;
 


