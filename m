From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:29:07 -0000
Subject: LVM2/tools lvchange.c vgchange.c
Message-ID: <20111028202907.6640.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:29:07

Modified files:
	tools          : lvchange.c vgchange.c 

Log message:
	Thin works only with exclusive activation
	
	Enforce exclusive activation with thin targets.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/tools/lvchange.c	2011/10/28 20:28:01	1.131
+++ LVM2/tools/lvchange.c	2011/10/28 20:29:06	1.132
@@ -135,7 +135,9 @@
 		if (!deactivate_lv(cmd, lv))
 			return_0;
 	} else {
-		if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
+		if ((activate == CHANGE_AE) ||
+		    lv_is_origin(lv) ||
+		    lv_is_thin_type(lv)) {
 			log_verbose("Activating logical volume \"%s\" "
 				    "exclusively", lv->name);
 			if (!activate_lv_excl(cmd, lv))
--- LVM2/tools/vgchange.c	2011/10/28 20:28:01	1.125
+++ LVM2/tools/vgchange.c	2011/10/28 20:29:06	1.126
@@ -149,10 +149,10 @@
 				stack;
 				continue;
 			}
-		} else if (lv_is_origin(lv) ||
-			   lv_is_thin_pool(lv) ||
-			   lv_is_thin_volume(lv) ||
-			   (activate == CHANGE_AE)) {
+		} else if ((activate == CHANGE_AE) ||
+			   lv_is_origin(lv) ||
+			   lv_is_thin_type(lv)) {
+			/* FIXME: duplicated test code with lvchange */
 			if (!activate_lv_excl(cmd, lv)) {
 				stack;
 				continue;


