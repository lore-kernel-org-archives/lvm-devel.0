From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 11:13:36 -0000
Subject: LVM2/tools vgreduce.c
Message-ID: <20090724111336.14041.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 11:13:36

Modified files:
	tools          : vgreduce.c 

Log message:
	Remove redundant validate_name in vgreduce.
	
	This check is now done in vg_read_for_update, thanks to mornfall.
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/tools/vgreduce.c	2009/07/15 05:50:22	1.96
+++ LVM2/tools/vgreduce.c	2009/07/24 11:13:36	1.97
@@ -502,12 +502,6 @@
 	argv++;
 	argc--;
 
-	if (!validate_name(vg_name)) {
-		log_error("Volume group name \"%s\" is invalid",
-			  vg_name);
-		return ECMD_FAILED;
-	}
-
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
 	if (repairing) {


