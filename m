From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:39 +0000 (GMT)
Subject: master - writecache: show error in lv_health_status and lv_attr
Message-ID: <20200610173139.50F0B38708DA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce772bfab976d89f6a35a442434d1a49ceb634c7
Commit:        ce772bfab976d89f6a35a442434d1a49ceb634c7
Parent:        240062a18365a7f6725ebcf1b035a6e0a3b12803
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 25 16:20:05 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:13:48 2020 -0500

writecache: show error in lv_health_status and lv_attr

lv_attr is 'E' and lv_health_status is 'error'
when dm-writecache status reports error.
---
 lib/metadata/lv.c   | 3 +++
 lib/report/report.c | 6 ++++++
 man/lvs.8_end       | 4 ++++
 3 files changed, 13 insertions(+)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4ee58b419..fac47e530 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1412,6 +1412,9 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 	} else if (lvdm->seg_status.type == SEG_STATUS_THIN) {
 		if (lvdm->seg_status.thin->fail)
 			repstr[8] = 'F';
+	} else if (lvdm->seg_status.type == SEG_STATUS_WRITECACHE) {
+		if (lvdm->seg_status.writecache->error)
+			repstr[8] = 'E';
 	} else if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
 		repstr[8] = 'X'; /* Unknown */
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 170df6995..e1c630576 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3802,6 +3802,12 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 			health = "failed";
 		else if (lvdm->seg_status.cache->read_only)
 			health = "metadata_read_only";
+	} else if (lv_is_writecache(lv) && (lvdm->seg_status.type != SEG_STATUS_NONE)) {
+		if (lvdm->seg_status.type != SEG_STATUS_WRITECACHE)
+			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
+						GET_FIELD_RESERVED_VALUE(health_undef));
+		if (lvdm->seg_status.writecache->error)
+			health = "error";
 	} else if (lv_is_thin_pool(lv) && (lvdm->seg_status.type != SEG_STATUS_NONE)) {
 		if (lvdm->seg_status.type != SEG_STATUS_THIN_POOL)
 			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
diff --git a/man/lvs.8_end b/man/lvs.8_end
index 6efc9cb4f..5a4ecc83c 100644
--- a/man/lvs.8_end
+++ b/man/lvs.8_end
@@ -74,5 +74,9 @@ Related to Thin Logical Volumes: (F)ailed.
 .br
 (F)ailed is set when related thin pool enters Failed state and no further I/O
 is permitted at all.
+.IP
+Related to writecache logical volumes: (E)rror.
+.br
+(E)rror is set dm-writecache reports an error.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.


