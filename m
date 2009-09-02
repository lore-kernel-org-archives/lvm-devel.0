From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:25:45 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090902212545.11411.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:25:45

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit to move existing_vg logic in a separate 'if' statement.
	
	This will aid in future refactorings and allow for us to reorder the source
	and destination vg based on alphabetical names.
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/tools/vgsplit.c	2009/07/14 02:16:05	1.85
+++ LVM2/tools/vgsplit.c	2009/09/02 21:25:44	1.86
@@ -290,6 +290,11 @@
 			goto bad2;
 		}
 
+	} else if (vg_read_error(vg_to) == SUCCESS) {
+		existing_vg = 0;
+	}
+
+	if (existing_vg) {
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
@@ -297,9 +302,7 @@
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
-	} else if (vg_read_error(vg_to) == SUCCESS) {
-		existing_vg = 0;
-
+	} else {
 		vp_def.vg_name = NULL;
 		vp_def.extent_size = vg_from->extent_size;
 		vp_def.max_pv = vg_from->max_pv;


