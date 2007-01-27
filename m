From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jan 2007 02:32:31 -0000
Subject: LVM2/tools reporter.c
Message-ID: <20070127023231.28858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-27 02:32:31

Modified files:
	tools          : reporter.c 

Log message:
	fix pvsegs report too

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/tools/reporter.c	2007/01/27 02:09:06	1.19
+++ LVM2/tools/reporter.c	2007/01/27 02:32:31	1.20
@@ -150,6 +150,18 @@
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
 
+static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
+			 struct volume_group *vg, int consistent,
+			 void *handle)
+{
+	if (!vg) {
+		log_error("Volume group %s not found", vg_name);
+		return ECMD_FAILED;
+	}                     
+
+	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
+}
+
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
@@ -323,7 +335,7 @@
 					    report_handle, &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
-					    report_handle, &_pvs_in_vg);
+					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
 


