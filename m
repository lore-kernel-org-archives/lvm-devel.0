From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:15 +0000 (UTC)
Subject: master - dmstats: add 'statsname' and 'obj_type' to default stats fields
Message-ID: <20160705185515.A6FF3613E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b926511b4b53b7240213845457dfb54649c38899
Commit:        b926511b4b53b7240213845457dfb54649c38899
Parent:        0b05e4a874b3398271dbbad5f5d7a72e15eadfce
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 12:29:13 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

dmstats: add 'statsname' and 'obj_type' to default stats fields

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index c543972..e0cade0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4312,7 +4312,7 @@ static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 		"await,read_await,write_await"
 
 /* Device, region and area metadata. */
-#define STATS_DEV_INFO "statsname,group_id,region_id"
+#define STATS_DEV_INFO "statsname,group_id,region_id,obj_type"
 #define STATS_AREA_INFO "area_id,area_start,area_len"
 #define STATS_AREA_INFO_FULL STATS_DEV_INFO ",region_start,region_len,area_count,area_id,area_start,area_len"
 #define STATS_REGION_INFO STATS_DEV_INFO ",region_start,region_len,area_count,area_len"


