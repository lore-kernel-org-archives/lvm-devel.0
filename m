From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jul 2009 12:15:36 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090715121536.17170.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-15 12:15:36

Modified files:
	tools          : toollib.c 

Log message:
	Fix memory leak in _process_one_vg error path.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/tools/toollib.c	2009/07/15 05:50:22	1.162
+++ LVM2/tools/toollib.c	2009/07/15 12:15:36	1.163
@@ -432,8 +432,10 @@
 
 	vg = vg_read(cmd, vg_name, vgid, flags);
 	if (vg_read_error(vg) == FAILED_ALLOCATION ||
-	    vg_read_error(vg) == FAILED_NOTFOUND)
+	    vg_read_error(vg) == FAILED_NOTFOUND) {
+		vg_release(vg);
 		return ECMD_FAILED;
+	}
 
 	if (!dm_list_empty(tags)) {
 		/* Only process if a tag matches or it's on arg_vgnames */


