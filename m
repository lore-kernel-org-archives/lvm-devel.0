From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:28:44 -0000
Subject: LVM2/tools vgmerge.c
Message-ID: <20090902212844.13413.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:28:44

Modified files:
	tools          : vgmerge.c 

Log message:
	Change vgmerge behavior to open/lock first vg based on alphabetical ordering.
	
	This enforces our alphabetical lock ordering rules for vgmerge.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/tools/vgmerge.c	2009/09/02 21:28:27	1.63
+++ LVM2/tools/vgmerge.c	2009/09/02 21:28:43	1.64
@@ -41,14 +41,28 @@
 		return ECMD_FAILED;
 	}
 
-	vg_to = _vgmerge_vg_read(cmd, vg_name_to);
-	if (!vg_to)
-		return ECMD_FAILED;
+	if (strcmp(vg_name_to, vg_name_from) > 0)
+		lock_vg_from_first = 1;
 
-	vg_from = _vgmerge_vg_read(cmd, vg_name_from);
-	if (!vg_from) {
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
-		return ECMD_FAILED;
+	if (lock_vg_from_first) {
+		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
+		if (!vg_from)
+			return ECMD_FAILED;
+		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
+		if (!vg_to) {
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			return ECMD_FAILED;
+		}
+	} else {
+		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
+		if (!vg_to)
+			return ECMD_FAILED;
+
+		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
+		if (!vg_from) {
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
+			return ECMD_FAILED;
+		}
 	}
 
 	if (!vgs_are_compatible(cmd, vg_from, vg_to))


