From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:13 +0000 (UTC)
Subject: master - dmstats: rename 'type' field to 'obj_type'
Message-ID: <20160705185513.977F5613E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b05e4a874b3398271dbbad5f5d7a72e15eadfce
Commit:        0b05e4a874b3398271dbbad5f5d7a72e15eadfce
Parent:        c014425b6f6d1f963cddfbea362141f0815c1837
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 12:27:46 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

dmstats: rename 'type' field to 'obj_type'

Rename the field and remove whitespace from the column heading:

  "Object Type" -> "ObjType"
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index be6a276..c543972 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4284,7 +4284,7 @@ FIELD_F(STATS_META, STR, "#Bins", 9, dm_stats_hist_bins, "hist_bins", "The numbe
 FIELD_F(STATS_META, STR, "Histogram Bounds", 16, dm_stats_hist_bounds, "hist_bounds", "Latency histogram bin boundaries.")
 FIELD_F(STATS_META, STR, "Histogram Ranges", 16, dm_stats_hist_ranges, "hist_ranges", "Latency histogram bin ranges.")
 FIELD_F(STATS_META, STR, "Name", 16, dm_stats_name, "stats_name", "Stats name of current object.")
-FIELD_F(STATS_META, STR, "Object Type", 11, dm_stats_object_type, "type", "Type of stats object being reported.")
+FIELD_F(STATS_META, STR, "ObjType", 11, dm_stats_object_type, "obj_type", "Type of stats object being reported.")
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


