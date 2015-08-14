From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 21:05:12 +0000 (UTC)
Subject: master - dmstats: add 'stat_' prefix to stats report columns
Message-ID: <20150814210512.450C160F0D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=666722324f870c7ef0fb03acb043a00567067188
Commit:        666722324f870c7ef0fb03acb043a00567067188
Parent:        bfb58b7e1c2d2142c0e4439d193a7ff5b07a3c67
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 17:10:47 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 22:03:37 2015 +0100

dmstats: add 'stat_' prefix to stats report columns

---
 tools/dmsetup.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d386ca3..7dd58b1 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3882,8 +3882,8 @@ static const struct dm_report_object_type _report_types[] = {
 	{ DR_DEPS, "Mapped Device Relationship Information", "", _deps_get_obj },
 	{ DR_TREE, "Mapped Device Relationship Information", "", _tree_get_obj },
 	{ DR_NAME, "Mapped Device Name Components", "", _split_name_get_obj },
-	{ DR_STATS, "Mapped Device Statistics","", _stats_get_obj },
-	{ DR_STATS_META, "Mapped Device Statistics Region Information","", _stats_get_obj },
+	{ DR_STATS, "Mapped Device Statistics","stats_", _stats_get_obj },
+	{ DR_STATS_META, "Mapped Device Statistics Region Information","stats_region_", _stats_get_obj },
 	{ 0, "", "", NULL }
 };
 
@@ -4000,7 +4000,7 @@ static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 #define WR_STATS "writes,writes_merged,write_sectors,write_nsecs,total_wr_nsecs"
 #define IO_STATS "in_progress,io_nsecs,weighted_io_nsecs"
 #define METRICS "rrqm,wrqm,rs,ws,rsize_sec,wsize_sec,arqsz,qusz,util,await,r_await,w_await"
-static const char *_stats_default_report_options = DEV_INFO_STATS ",area_id," METRICS;
+static const char *_stats_default_report_options = DEV_INFO_STATS ",area_id,area_start,area_len," METRICS;
 static const char *_stats_list_options = "name,region_id,region_start,region_len,area_len,area_count,program_id";
 
 static int _report_init(const struct command *cmd, const char *subcommand)


