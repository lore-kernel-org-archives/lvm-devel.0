From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 08:38:40 +0000 (UTC)
Subject: master - dmstats: fix 'obj_type' field width
Message-ID: <20160706083840.E5F8D61259@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21b946dfb75c893827ce5caafd16cb09be4fbeeb
Commit:        21b946dfb75c893827ce5caafd16cb09be4fbeeb
Parent:        95ef0cdb461dfb7b7e6ac8e2484564fe0b5ec0ed
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 09:37:59 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 09:37:59 2016 +0100

dmstats: fix 'obj_type' field width

The header for 'obj_type' was changed from 'Object Type' to
'ObjType': update the minimum field width to match this change.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ed03c2b..4d9bb07 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4286,7 +4286,7 @@ FIELD_F(STATS_META, STR, "#Bins", 9, dm_stats_hist_bins, "hist_bins", "The numbe
 FIELD_F(STATS_META, STR, "Histogram Bounds", 16, dm_stats_hist_bounds, "hist_bounds", "Latency histogram bin boundaries.")
 FIELD_F(STATS_META, STR, "Histogram Ranges", 16, dm_stats_hist_ranges, "hist_ranges", "Latency histogram bin ranges.")
 FIELD_F(STATS_META, STR, "Name", 16, dm_stats_name, "stats_name", "Stats name of current object.")
-FIELD_F(STATS_META, STR, "ObjType", 11, dm_stats_object_type, "obj_type", "Type of stats object being reported.")
+FIELD_F(STATS_META, STR, "ObjType", 7, dm_stats_object_type, "obj_type", "Type of stats object being reported.")
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


