From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:32 +0000 (UTC)
Subject: master - dmstats: add 'statsname' and 'obj_type' to default stats fields
Message-ID: <20160705183532.3DE2E61253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc6177284a4c08e115368c938f03899b443b5edf
Commit:        cc6177284a4c08e115368c938f03899b443b5edf
Parent:        c2e043f0c188953e0d6fac91c0d08a4dfbc7fd23
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 12:29:13 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:51 2016 +0100

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


