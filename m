From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2010 20:27:34 -0000
Subject: LVM2/lib/report report.c
Message-ID: <20100215202734.10324.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-02-15 20:27:33

Modified files:
	lib/report     : report.c 

Log message:
	Use dm_report_field_int32 instead of dm_report_field_uint64 for printing '-1'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/lib/report/report.c	2010/02/15 18:35:06	1.114
+++ LVM2/lib/report/report.c	2010/02/15 20:27:33	1.115
@@ -50,7 +50,8 @@
 	}
 }
 
-static const uint64_t _minusone = UINT64_C(-1);
+static const uint64_t _minusone64 = UINT64_C(-1);
+static const int32_t _minusone32 = INT32_C(-1);
 
 /*
  * Data-munging functions to prepare each data type for display and sorting
@@ -247,7 +248,7 @@
 	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.major);
 
-	return dm_report_field_uint64(rh, field, &_minusone);
+	return dm_report_field_int32(rh, field, &_minusone32);
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
@@ -260,7 +261,7 @@
 	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.minor);
 
-	return dm_report_field_uint64(rh, field, &_minusone);
+	return dm_report_field_int32(rh, field, &_minusone32);
 }
 
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
@@ -643,7 +644,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO) {
-		dm_report_field_set_value(field, "auto", &_minusone);
+		dm_report_field_set_value(field, "auto", &_minusone64);
 		return 1;
 	}
 
@@ -659,7 +660,7 @@
 	struct lvinfo info;
 
 	if (!lv_info(lv->vg->cmd, lv, &info, 0, 1) || !info.exists)
-		return dm_report_field_uint64(rh, field, &_minusone);
+		return dm_report_field_int32(rh, field, &_minusone32);
 
 	return _size32_disp(rh, mem, field, &info.read_ahead, private);
 }


