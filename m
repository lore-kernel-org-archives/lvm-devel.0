From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jul 2009 03:30:05 -0000
Subject: LVM2/tools vgcfgbackup.c
Message-ID: <20090715033005.20555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-15 03:30:04

Modified files:
	tools          : vgcfgbackup.c 

Log message:
	Fix FAILED_INCONSISTENT case in vg_backup_single - typeo on 'if' condition.
	
	In vg_backup_single, we should error out if we vg_read_error(vg) and the
	error code we received was anything other than FAILED_INCONSISTENT.
	Original code contained an error because C operator precedence.
	Note - this was part of the vg_read() so no WHATS_NEW entry neceesary.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/tools/vgcfgbackup.c	2009/07/01 17:00:52	1.28
+++ LVM2/tools/vgcfgbackup.c	2009/07/15 03:30:04	1.29
@@ -54,7 +54,7 @@
 	char **last_filename = (char **)handle;
 	char *filename;
 
-	if (vg_read_error(vg) && !vg_read_error(vg) == FAILED_INCONSISTENT)
+	if (vg_read_error(vg) && (vg_read_error(vg) != FAILED_INCONSISTENT))
 		return ECMD_FAILED;
 
 	if (arg_count(cmd, file_ARG)) {


