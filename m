From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jan 2007 15:07:21 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20070122150721.15625.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-22 15:07:21

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	Streamline dm_report_field_* interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.549&r2=1.550
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2007/01/19 22:21:44	1.549
+++ LVM2/WHATS_NEW	2007/01/22 15:07:20	1.550
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Streamline dm_report_field_* interface.
   Change remaining dmeventd terminology 'register' to 'monitor'.
   Update reporting man pages.
   No longer necessary to specify alignment for report fields.
--- LVM2/lib/report/report.c	2007/01/18 17:48:29	1.52
+++ LVM2/lib/report/report.c	2007/01/22 15:07:21	1.53
@@ -66,7 +66,7 @@
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
-	return dm_report_field_string(rh, mem, field, data);
+	return dm_report_field_string(rh, field, (const char **) data);
 }
 
 static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -75,7 +75,7 @@
 {
 	const char *name = dev_name(*(const struct device **) data);
 
-	return dm_report_field_string(rh, mem, field, &name);
+	return dm_report_field_string(rh, field, &name);
 }
 
 static int _devices_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -227,9 +227,9 @@
 	uint64_t minusone = UINT64_C(-1);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
-		return dm_report_field_int(rh, mem, field, &info.major);
+		return dm_report_field_int(rh, field, &info.major);
 
-	return dm_report_field_int(rh, mem, field, &minusone);
+	return dm_report_field_uint64(rh, field, &minusone);
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -241,9 +241,9 @@
 	uint64_t minusone = UINT64_C(-1);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
-		return dm_report_field_int(rh, mem, field, &info.minor);
+		return dm_report_field_int(rh, field, &info.minor);
 
-	return dm_report_field_int(rh, mem, field, &minusone);
+	return dm_report_field_uint64(rh, field, &minusone);
 }
 
 static int _lvstatus_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -423,8 +423,8 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv_is_cow(lv))
-		return dm_report_field_string(rh, mem, field,
-					      &origin_from_cow(lv)->name);
+		return dm_report_field_string(rh, field,
+					      (const char **) &origin_from_cow(lv)->name);
 
 	dm_report_field_set_value(field, "", NULL);
 	return 1;
@@ -440,8 +440,8 @@
 	list_iterate_items(seg, &lv->segments) {
 		if (!seg_is_mirrored(seg) || !seg->log_lv)
 			continue;
-		return dm_report_field_string(rh, mem, field,
-					      &seg->log_lv->name);
+		return dm_report_field_string(rh, field,
+					      (const char **) &seg->log_lv->name);
 	}
 
 	dm_report_field_set_value(field, "", NULL);
@@ -458,7 +458,7 @@
 
 	if (lv_is_visible(lv)) {
 		repstr = lv->name;
-		return dm_report_field_string(rh, mem, field, &repstr);
+		return dm_report_field_string(rh, field, (const char **) &repstr);
 	}
 
 	len = strlen(lv->name) + 3;
@@ -494,7 +494,7 @@
 		if (!(seg->status & PVMOVE))
 			continue;
 		name = dev_name(seg_dev(seg, 0));
-		return dm_report_field_string(rh, mem, field, &name);
+		return dm_report_field_string(rh, field, &name);
 	}
 
 	dm_report_field_set_value(field, "", NULL);
@@ -708,14 +708,14 @@
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
-	return dm_report_field_uint32(rh, mem, field, data);
+	return dm_report_field_uint32(rh, field, data);
 }
 
 static int _int32_disp(struct dm_report *rh, struct dm_pool *mem,
 		       struct dm_report_field *field,
 		       const void *data, void *private)
 {
-	return dm_report_field_int32(rh, mem, field, data);
+	return dm_report_field_int32(rh, field, data);
 }
 
 static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,


