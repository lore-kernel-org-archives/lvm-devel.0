From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Dec 2007 18:00:38 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20071203180038.4796.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-03 18:00:38

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	fix changed parms

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/lib/activate/dev_manager.c	2007/11/29 15:04:12	1.129
+++ LVM2/lib/activate/dev_manager.c	2007/12/03 18:00:38	1.130
@@ -142,9 +142,10 @@
 	if (!dm_task_get_info(dmt, info))
 		goto_out;
 
-	if (with_read_ahead)
-		*read_ahead = dm_task_get_read_ahead(dmt);
-	else if (read_ahead)
+	if (with_read_ahead) {
+		if (!dm_task_get_read_ahead(dmt, read_ahead))
+			goto_out;
+	} else if (read_ahead)
 		*read_ahead = DM_READ_AHEAD_NONE;
 
 	r = 1;


