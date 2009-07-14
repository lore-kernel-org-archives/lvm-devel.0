From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 19:37:18 -0000
Subject: LVM2/tools vgck.c vgremove.c
Message-ID: <20090714193718.31466.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 19:37:18

Modified files:
	tools          : vgck.c vgremove.c 

Log message:
	Fix vgck and vgremove segfault if non-existent vg given.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/tools/vgck.c	2009/07/01 17:00:52	1.22
+++ LVM2/tools/vgck.c	2009/07/14 19:37:18	1.23
@@ -21,6 +21,9 @@
 		       struct volume_group *vg,
 		       void *handle __attribute((unused)))
 {
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
--- LVM2/tools/vgremove.c	2009/07/10 20:08:38	1.53
+++ LVM2/tools/vgremove.c	2009/07/14 19:37:18	1.54
@@ -22,6 +22,9 @@
 	unsigned lv_count;
 	force_t force;
 
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 


