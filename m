From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:49:23 -0000
Subject: LVM2/lib/report report.c
Message-ID: <20100113014923.26427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:49:22

Modified files:
	lib/report     : report.c 

Log message:
	When there is merging snapshot, report percentage on the origin LV.
	Because the snapshot LV will be hidden this is needed so the user can
	see merging progress with "lvs" command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/lib/report/report.c	2010/01/13 01:48:38	1.108
+++ LVM2/lib/report/report.c	2010/01/13 01:49:22	1.109
@@ -1023,7 +1023,7 @@
 		return 0;
 	}
 
-	if (!lv_is_cow(lv) ||
+	if ((!lv_is_cow(lv) && !lv->merging_snapshot) ||
 	    (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);


