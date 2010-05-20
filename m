From: agk@sourceware.org <agk@sourceware.org>
Date: 20 May 2010 22:24:37 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20100520222437.12972.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-20 22:24:35

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	If unable to obtain snapshot percentage leave value blank on reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1571&r2=1.1572
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2010/05/20 14:45:14	1.1571
+++ LVM2/WHATS_NEW	2010/05/20 22:24:33	1.1572
@@ -1,5 +1,6 @@
 Version 2.02.66 - 
 ===============================
+  If unable to obtain snapshot percentage leave value blank on reports.
   Add install_system_dirs and install_initscripts makefile targets.
   Add configure options for system and locking directories.
   Generate example.conf so default lvm.conf contents can be configured.
--- LVM2/lib/report/report.c	2010/02/15 20:27:33	1.115
+++ LVM2/lib/report/report.c	2010/05/20 22:24:35	1.116
@@ -1019,7 +1019,7 @@
 	}
 
 	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
-	    (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)) {
+	    !lv_info(lv->vg->cmd, lv, &info, 0, 0) || !info.exists) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;


