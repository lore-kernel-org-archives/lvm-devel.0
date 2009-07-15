From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jul 2009 05:23:20 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090715052320.26833.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-15 05:23:20

Modified files:
	tools          : toollib.c 

Log message:
	Check for certain vg_read errors in _process_one_vg iterator.
	
	In _process_one_vg, we should never proceed if the VG read fails with certain
	conditions.  If we cannot allocate or construct the volume_group structure,
	we should not proceed - this is true regardless of the tool calling the
	iterator.  In other cases, when the volume group structure is constructed but
	there is some error (PVs missing, metadata corrupted, etc), some tools may
	want to process the VG while others may not.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161

--- LVM2/tools/toollib.c	2009/07/07 01:18:35	1.160
+++ LVM2/tools/toollib.c	2009/07/15 05:23:19	1.161
@@ -431,6 +431,9 @@
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
 	vg = vg_read(cmd, vg_name, vgid, flags);
+	if (vg_read_error(vg) == FAILED_ALLOCATION ||
+	    vg_read_error(vg) == FAILED_NOTFOUND)
+		return ECMD_FAILED;
 
 	if (!dm_list_empty(tags)) {
 		/* Only process if a tag matches or it's on arg_vgnames */


