From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  4 Jul 2016 11:17:16 +0000 (UTC)
Subject: master - dmstats: fix RgStart and RgSize field widths
Message-ID: <20160704111716.7F9226072E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62dce13c7a00a71c73926340e05053b7ebee48e9
Commit:        62dce13c7a00a71c73926340e05053b7ebee48e9
Parent:        f27e95b25a639ca5cf8329f6f26f6a040706bf57
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jun 27 12:41:58 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 4 12:16:51 2016 +0100

dmstats: fix RgStart and RgSize field widths

---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b61b42f..03e2519 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4189,8 +4189,8 @@ FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampli
 
 /* Stats report meta-fields */
 FIELD_F(STATS_META, NUM, "RgID", 4, dm_stats_region_id, "region_id", "Region ID.")
-FIELD_F(STATS_META, SIZ, "RgStart", 5, dm_stats_region_start, "region_start", "Region start.")
-FIELD_F(STATS_META, SIZ, "RgSize", 5, dm_stats_region_len, "region_len", "Region length.")
+FIELD_F(STATS_META, SIZ, "RgStart", 7, dm_stats_region_start, "region_start", "Region start.")
+FIELD_F(STATS_META, SIZ, "RgSize", 6, dm_stats_region_len, "region_len", "Region length.")
 FIELD_F(STATS_META, NUM, "ArID", 4, dm_stats_area_id, "area_id", "Area ID.")
 FIELD_F(STATS_META, SIZ, "ArStart", 7, dm_stats_area_start, "area_start", "Area offset from start of device.")
 FIELD_F(STATS_META, SIZ, "ArSize", 6, dm_stats_area_len, "area_len", "Area length.")


