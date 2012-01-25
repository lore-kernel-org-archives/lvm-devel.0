From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 13:11:54 -0000
Subject: LVM2/lib/report report.c
Message-ID: <20120125131154.8883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 13:11:53

Modified files:
	lib/report     : report.c 

Log message:
	Thin read  percent info from layered device
	
	Since we only need layered device - check for tpool device presence,
	so user doesn't need to activate thin pool explicitely for percent info.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/lib/report/report.c	2012/01/20 22:02:04	1.149
+++ LVM2/lib/report/report.c	2012/01/25 13:11:52	1.150
@@ -919,7 +919,7 @@
 	char *repstr;
 
 	/* Suppress data percent if not thin pool/volume or not using driver */
-	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) || !info.exists) {
+	if (!lv_info(lv->vg->cmd, lv, 1, &info, 0, 0) || !info.exists) {
 		dm_report_field_set_value(field, "", NULL);
 		return 1;
 	}


