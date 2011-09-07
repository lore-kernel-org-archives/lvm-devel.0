From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Sep 2011 08:37:49 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20110907083749.25465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-07 08:37:48

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Remove unused passed parameters

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.497&r2=1.498
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW_DM	2011/09/01 21:04:14	1.497
+++ LVM2/WHATS_NEW_DM	2011/09/07 08:37:48	1.498
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Remove unused passed parameters for _mirror_emit_segment_line().
   Add dm_config and string character escaping functions to libdevmapper.
   Mark unreleased memory pools as internal error.
 
--- LVM2/libdm/libdm-deptree.c	2011/08/19 17:02:48	1.108
+++ LVM2/libdm/libdm-deptree.c	2011/09/07 08:37:48	1.109
@@ -1594,10 +1594,8 @@
 /*
  * Returns: 1 on success, 0 on failure
  */
-static int _mirror_emit_segment_line(struct dm_task *dmt, uint32_t major,
-				     uint32_t minor, struct load_segment *seg,
-				     uint64_t *seg_start, char *params,
-				     size_t paramsize)
+static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *seg,
+				     char *params, size_t paramsize)
 {
 	int block_on_error = 0;
 	int handle_errors = 0;
@@ -1784,8 +1782,7 @@
 		break;
 	case SEG_MIRRORED:
 		/* Mirrors are pretty complicated - now in separate function */
-		r = _mirror_emit_segment_line(dmt, major, minor, seg, seg_start,
-					      params, paramsize);
+		r = _mirror_emit_segment_line(dmt, seg, params, paramsize);
 		if (!r)
 			return_0;
 		break;


