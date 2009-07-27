From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 10:18:32 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20090727101832.15466.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 10:18:32

Modified files:
	lib/display    : display.c 

Log message:
	Update display.c to use vg_free(vg) instead of duplicating the calculation.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/lib/display/display.c	2009/07/07 19:28:57	1.98
+++ LVM2/lib/display/display.c	2009/07/27 10:18:31	1.99
@@ -636,8 +636,7 @@
 			       vg->extent_size));
 
 	log_print("Free  PE / Size       %u / %s", vg->free_count,
-		  display_size(vg->cmd,
-			       (uint64_t) vg->free_count * vg->extent_size));
+		  display_size(vg->cmd, vg_free(vg)));
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
 		stack;
@@ -708,8 +707,7 @@
 		  display_size(vg->cmd,
 			       ((uint64_t) vg->extent_count -
 				vg->free_count) * vg->extent_size),
-		  display_size(vg->cmd,
-			       (uint64_t) vg->free_count * vg->extent_size));
+		  display_size(vg->cmd, vg_free(vg)));
 	return;
 }
 


