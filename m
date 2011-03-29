From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 21:49:19 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20110329214919.19743.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 21:49:18

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Const warning fixes
	
	With recent update of dm_report_field_string() API call to accept
	completely const objects - we no longer need loose constness here
	and keep it forwarding.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.458&r2=1.459
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/WHATS_NEW_DM	2011/03/25 23:50:35	1.458
+++ LVM2/WHATS_NEW_DM	2011/03/29 21:49:18	1.459
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Fix const cast in dmsetup calls of dm_report_field_string().
   Streamline /dev/mapper/control node code for common cases.
   Use hard-coded dm control node device number for 2.6.36 kernels and above.
   Improve stack debug reporting in dm_task_create().
--- LVM2/tools/dmsetup.c	2011/03/02 02:44:56	1.156
+++ LVM2/tools/dmsetup.c	2011/03/29 21:49:18	1.157
@@ -2455,7 +2455,7 @@
 			       struct dm_report_field *field, const void *data,
 			       void *private __attribute__((unused)))
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static int _dm_vg_name_disp(struct dm_report *rh,
@@ -2464,7 +2464,7 @@
 			     void *private __attribute__((unused)))
 {
 
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static int _dm_lv_name_disp(struct dm_report *rh,
@@ -2473,7 +2473,7 @@
 			     void *private __attribute__((unused)))
 
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static int _dm_lv_layer_name_disp(struct dm_report *rh,
@@ -2482,7 +2482,7 @@
 				   void *private __attribute__((unused)))
 
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static void *_task_get_obj(void *obj)


