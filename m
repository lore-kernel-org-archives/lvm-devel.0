From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Dec 2014 10:57:40 +0000 (UTC)
Subject: master - report: dup cache policy name string for report in cache_policy field
Message-ID: <20141218105740.3FD2960EEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6f32f39e4ef007fd8566fe32c00975f917fc807
Commit:        f6f32f39e4ef007fd8566fe32c00975f917fc807
Parent:        aaf25ec6bd2201d4219765d7bfca05636b554145
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 18 11:54:40 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 18 11:54:40 2014 +0100

report: dup cache policy name string for report in cache_policy field

The cache policy name taken as LV segment property must be duped
for report as the VG/LV/seg structure is destroyed after processing,
reporting happens later:

$ valgrind lvs -o+cache_policy
...
==16589== Invalid read of size 1
==16589==    at 0x54ABCC3: dm_report_compact_fields
(libdm-report.c:1739)
==16589==    by 0x153FC7: _report (reporter.c:619)
==16589==    by 0x1540A6: lvs (reporter.c:641)
==16589==    by 0x148021: lvm_run_command (lvmcmdline.c:1452)
==16589==    by 0x1495CB: lvm2_main (lvmcmdline.c:1907)
==16589==    by 0x164712: main (lvm.c:21)
==16589==  Address 0x7d465f2 is 8,338 bytes inside a block of size
16,384 free'd
==16589==    at 0x4C2ACE9: free (in
/usr/lib64/valgrind/vgpreload_memcheck-amd64-linux.so)
==16589==    by 0x54B8C85: _free_chunk (pool-fast.c:318)
==16589==    by 0x54B84FB: dm_pool_destroy (pool-fast.c:78)
==16589==    by 0x1E59C7: _free_vg (vg.c:78)
==16589==    by 0x1E5A6D: release_vg (vg.c:95)
==16589==    by 0x159B6E: _process_lv_vgnameid_list (toollib.c:1967)
==16589==    by 0x159DD7: process_each_lv (toollib.c:2030)
==16589==    by 0x153ED8: _report (reporter.c:598)
==16589==    by 0x1540A6: lvs (reporter.c:641)
==16589==    by 0x148021: lvm_run_command (lvmcmdline.c:1452)
==16589==    by 0x1495CB: lvm2_main (lvmcmdline.c:1907)
==16589==    by 0x164712: main (lvm.c:21)
---
 lib/report/report.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 173157d..a23b226 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -285,15 +285,20 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const char *cache_policy_name;
 
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 	else
 		return _field_set_value(field, "", FIRST_NAME(cache_policy_undef));
 
-	if (seg->policy_name)
-		return _field_set_value(field, seg->policy_name, NULL);
-	else {
+	if (seg->policy_name) {
+		if (!(cache_policy_name = dm_pool_strdup(mem, seg->policy_name))) {
+			log_error("dm_pool_strdup failed");
+			return 0;
+		}
+		return _field_set_value(field, cache_policy_name, NULL);
+	} else {
 		log_error(INTERNAL_ERROR "unexpected NULL policy name");
 		return_0;
 	}


