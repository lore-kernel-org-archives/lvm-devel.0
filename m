From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Sep 2007 22:35:01 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20070906223501.11736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-06 22:35:01

Modified files:
	tools          : lvresize.c 

Log message:
	Fix last checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/tools/lvresize.c	2007/09/06 21:08:16	1.81
+++ LVM2/tools/lvresize.c	2007/09/06 22:35:01	1.82
@@ -132,7 +132,6 @@
 }
 
 static int do_resizefs_reduce(struct cmd_context *cmd, struct volume_group *vg,
-			      struct logical_volume *lv,
 			      struct lvresize_params *lp)
 {
 	char lv_path[PATH_MAX];
@@ -552,7 +551,7 @@
 	}
 
 	if (lp->resizefs) {
-		if (!do_resizefs_reduce(cmd, vg, lv_path, lp))
+		if (!do_resizefs_reduce(cmd, vg, lp))
 		    return ECMD_FAILED;
 	}
 


