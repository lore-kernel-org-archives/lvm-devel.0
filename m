From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:28 +0000 (UTC)
Subject: master - dmstats: use 'statsname' and 'groupid' in default fields
Message-ID: <20160705183528.0C28661241@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59a3705577c0533c12834ba97c8a83ea8bf8c997
Commit:        59a3705577c0533c12834ba97c8a83ea8bf8c997
Parent:        76f7f28dac2190866b88208a1eed7f997656673d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 12:10:47 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:51 2016 +0100

dmstats: use 'statsname' and 'groupid' in default fields

Replace the 'name' field with 'statsname' in order to report alias
names for groups, and include the 'group_id' field between statsname
and the 'region_id' field to make it clear to the user when groups
are in use.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 6900ba2..be6a276 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4312,7 +4312,7 @@ static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 		"await,read_await,write_await"
 
 /* Device, region and area metadata. */
-#define STATS_DEV_INFO "name,region_id"
+#define STATS_DEV_INFO "statsname,group_id,region_id"
 #define STATS_AREA_INFO "area_id,area_start,area_len"
 #define STATS_AREA_INFO_FULL STATS_DEV_INFO ",region_start,region_len,area_count,area_id,area_start,area_len"
 #define STATS_REGION_INFO STATS_DEV_INFO ",region_start,region_len,area_count,area_len"


