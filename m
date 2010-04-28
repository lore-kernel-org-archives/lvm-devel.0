From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Apr 2010 17:41:31 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100428174131.16633.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-28 17:41:31

Modified files:
	tools          : lvconvert.c 

Log message:
	Don't attempt to convert the log type of an LV if the LV
	is not a mirror.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/tools/lvconvert.c	2010/04/26 18:31:58	1.132
+++ LVM2/tools/lvconvert.c	2010/04/28 17:41:30	1.133
@@ -1074,7 +1074,7 @@
 	/*
 	 * Converting the log type
 	 */
-	if (old_log_count != new_log_count) {
+	if ((lv->status & MIRRORED) && (old_log_count != new_log_count)) {
 		if (!_lv_update_log_type(cmd, lp, lv,
 					 operable_pvs, new_log_count)) {
 			stack;


