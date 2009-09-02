From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:27:55 -0000
Subject: LVM2/tools vgmerge.c
Message-ID: <20090902212755.13004.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:27:55

Modified files:
	tools          : vgmerge.c 

Log message:
	Refactor vgmerge - introduce lock_vg_from_first flag.
	
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/tools/vgmerge.c	2009/07/08 14:33:17	1.60
+++ LVM2/tools/vgmerge.c	2009/09/02 21:27:55	1.61
@@ -21,6 +21,7 @@
 	struct volume_group *vg_to, *vg_from;
 	struct lv_list *lvl1, *lvl2;
 	int r = ECMD_FAILED;
+	int lock_vg_from_first = 0;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
@@ -116,8 +117,13 @@
 		  vg_from->name, vg_to->name);
 	r = ECMD_PROCESSED;
 bad:
-	unlock_and_release_vg(cmd, vg_from, vg_name_from);
-	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	if (lock_vg_from_first) {
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+	} else {
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	}
 	return r;
 }
 


