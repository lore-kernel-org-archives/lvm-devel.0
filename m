From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 11 Jan 2016 12:04:05 +0000 (UTC)
Subject: master - report: fix invalid memory read when reporting cache LV policy name
Message-ID: <20160111120405.E2CAB6103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a83d611a86e6da31f255d5d87adf14cb3d62a05a
Commit:        a83d611a86e6da31f255d5d87adf14cb3d62a05a
Parent:        0dac4f09b4fcf752b039a80707653d3b655fc020
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 11 12:51:08 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 11 12:51:08 2016 +0100

report: fix invalid memory read when reporting cache LV policy name

Fix regression caused by commit c2d4330f27277717bc3b684b702189079b257b77
which removed the dm_pool_strdup for the cache policy name in
_cache_policy_disp report function.

This regression was hit with buffered reporting only (which is
used by default). The reason is that for buffered reporting, we're
iterating over LVs in VG (process_each_lv) while gathering
all the information that is needed for the report. In this case,
the LV's cache policy name has not been duped, but only the pointer
to the original VG buffer was stored. When the LV iteration finished,
the VG buffer was freed and any report to output called later
(dm_report_output call) accessed already freed VG data.

This didn't appear if unbuffered reporting was used (--unbuffered)
because in this case, the data were reported to output as
soon as they were processed, hence it was reported to output
before the VG data was freed.
---
 WHATS_NEW           |    1 +
 lib/report/report.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 15f835b..d622c9f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Fix invalid memory read when reporting cache LV policy_name (2.02.126).
 
 Version 2.02.139 - 8th January 2016
 ===================================
diff --git a/lib/report/report.c b/lib/report/report.c
index 91522b1..2fdf509 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1417,6 +1417,7 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const char *cache_policy_name;
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
@@ -1429,7 +1430,12 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 		return 0;
 	}
 
-	return _field_set_value(field, seg->policy_name, NULL);
+	if (!(cache_policy_name = dm_pool_strdup(mem, seg->policy_name))) {
+		log_error("dm_pool_strdup failed");
+		return 0;
+	}
+
+	return _field_set_value(field, cache_policy_name, NULL);
 }
 
 static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,


