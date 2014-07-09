From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Jul 2014 13:57:53 +0000 (UTC)
Subject: master - cleanup: move _lvactive_disp and _thinzero_disp under 'attribute' display functions
Message-ID: <20140709135753.D10E560F59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1bed36b670660527caf70182c39080764df71d0
Commit:        c1bed36b670660527caf70182c39080764df71d0
Parent:        bccc2bef33af081264bbc356e37efe89ef78b796
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 9 14:37:01 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 9 15:57:05 2014 +0200

cleanup: move _lvactive_disp and _thinzero_disp under 'attribute' display functions

So all attribute reporting functions are all in one section of code
for quick orientation (all these functions are defined in the order
of their attribute character displayed in pv/vg/lv_attr field).
---
 lib/report/report.c |   52 +++++++++++++++++++++++++-------------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index d28c767..198fdfa 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -750,18 +750,6 @@ static int _chunksize_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &size, private);
 }
 
-static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
-			   struct dm_report_field *field,
-			   const void *data, void *private)
-{
-	const struct lv_segment *seg = (const struct lv_segment *) data;
-
-	if (seg_is_thin_pool(seg))
-		return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
-
-	return _field_set_value(field, "", &_reserved_number_undef_64);
-}
-
 static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 				struct dm_report_field *field,
 				const void *data, void *private)
@@ -1275,20 +1263,6 @@ static int _lvhost_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
-static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
-			     struct dm_report_field *field,
-			     const void *data, void *private)
-{
-	char *repstr;
-
-	if (!(repstr = lv_active_dup(mem, (const struct logical_volume *) data))) {
-		log_error("Failed to allocate buffer for active.");
-		return 0;
-	}
-
-	return _field_set_value(field, repstr, NULL);
-}
-
 /* PV/VG/LV Attributes */
 
 static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1477,6 +1451,20 @@ static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor), private);
 }
 
+static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	char *repstr;
+
+	if (!(repstr = lv_active_dup(mem, (const struct logical_volume *) data))) {
+		log_error("Failed to allocate buffer for active.");
+		return 0;
+	}
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
 				 struct dm_report_field *field,
 				 const void *data, void *private)
@@ -1626,6 +1614,18 @@ static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _string_disp(rh, mem, field, &target_type, private);
 }
 
+static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_thin_pool(seg))
+		return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
+
+	return _field_set_value(field, "", &_reserved_number_undef_64);
+}
+
 static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 				struct dm_report_field *field,
 				const void *data, void *private)


