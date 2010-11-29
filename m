From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 12:42:11 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20101129124211.26148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 12:42:11

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Remove dead assignment in _mirror_emit_segment_line
	
	Remove unused 'r' assignment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/libdm/libdm-deptree.c	2010/11/29 11:26:00	1.88
+++ LVM2/libdm/libdm-deptree.c	2010/11/29 12:42:10	1.89
@@ -1536,7 +1536,6 @@
 				     uint64_t *seg_start, char *params,
 				     size_t paramsize)
 {
-	int r;
 	int block_on_error = 0;
 	int handle_errors = 0;
 	int dm_log_userspace = 0;
@@ -1643,7 +1642,7 @@
 
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
-	if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0)
+	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
 		return_0;
 
 	if (handle_errors)


