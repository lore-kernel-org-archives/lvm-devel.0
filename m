From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jan 2007 02:09:07 -0000
Subject: LVM2 ./WHATS_NEW tools/reporter.c
Message-ID: <20070127020907.21750.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-27 02:09:06

Modified files:
	.              : WHATS_NEW 
	tools          : reporter.c 

Log message:
	Fix vgs to treat args as VGs even when PV fields are displayed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.563&r2=1.564
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2007/01/26 17:15:16	1.563
+++ LVM2/WHATS_NEW	2007/01/27 02:09:05	1.564
@@ -1,5 +1,6 @@
 Version 2.02.21 -
 ===================================
+  Fix vgs to treat args as VGs even when PV fields are displayed.
   Fix md signature check to handle both endiannesses.
 
 Version 2.02.20 - 25th January 2007
--- LVM2/tools/reporter.c	2007/01/25 14:37:48	1.18
+++ LVM2/tools/reporter.c	2007/01/27 02:09:06	1.19
@@ -138,6 +138,18 @@
 	return ret;
 }
 
+static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
+		      struct volume_group *vg, int consistent,
+		      void *handle)
+{
+	if (!vg) {
+		log_error("Volume group %s not found", vg_name);
+		return ECMD_FAILED;
+	}                     
+
+	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
+}
+
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
@@ -146,8 +158,8 @@
 	char *str;
 	const char *keys = NULL, *options = NULL, *separator;
 	int r = ECMD_PROCESSED;
-
 	int aligned, buffered, headings;
+	unsigned args_are_pvs;
 
 	aligned = find_config_tree_int(cmd, "report/aligned",
 				  DEFAULT_REP_ALIGNED);
@@ -158,6 +170,8 @@
 	separator = find_config_tree_str(cmd, "report/separator",
 				    DEFAULT_REP_SEPARATOR);
 
+	args_are_pvs = (report_type == PVS || report_type == PVSEGS) ? 1 : 0;
+
 	switch (report_type) {
 	case LVS:
 		keys = find_config_tree_str(cmd, "report/lvs_sort",
@@ -292,16 +306,24 @@
 				    report_handle, &_vgs_single);
 		break;
 	case PVS:
-		r = process_each_pv(cmd, argc, argv, NULL, report_handle,
-				    &_pvs_single);
+		if (args_are_pvs)
+			r = process_each_pv(cmd, argc, argv, NULL,
+					    report_handle, &_pvs_single);
+		else
+			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
 		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
 				    &_lvsegs_single);
 		break;
 	case PVSEGS:
-		r = process_each_pv(cmd, argc, argv, NULL, report_handle,
-				    &_pvsegs_single);
+		if (args_are_pvs)
+			r = process_each_pv(cmd, argc, argv, NULL,
+					    report_handle, &_pvsegs_single);
+		else
+			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+					    report_handle, &_pvs_in_vg);
 		break;
 	}
 


