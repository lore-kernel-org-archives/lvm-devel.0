From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:00:28 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20120227100028.11061.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:00:24

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Always check result of _set_vg_name()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2311&r2=1.2312
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.255&r2=1.256

--- LVM2/WHATS_NEW	2012/02/27 09:58:18	1.2311
+++ LVM2/WHATS_NEW	2012/02/27 10:00:23	1.2312
@@ -1,6 +1,7 @@
 Version 2.02.94 - 
-====================================
-  Drop unused call to uname() during clvmd initia.lization.
+====================================                       
+  Always check result of _set_vg_name() in lvcreate.
+  Drop unused call to uname() during clvmd initialization.
   Test allocation result in sysfs filter creation.
   Limit sscanf parameters with buffer size in clvmd get_initial_state().
   Use const lv pointer for lv_is_active...() functions. 
--- LVM2/tools/lvcreate.c	2012/02/23 17:36:36	1.255
+++ LVM2/tools/lvcreate.c	2012/02/27 10:00:23	1.256
@@ -93,8 +93,9 @@
 				lp->origin = ptr + 1;
 		}
 
-		if (!lp->vg_name)
-			_set_vg_name(lp, extract_vgname(cmd, NULL));
+		if (!lp->vg_name &&
+		    !_set_vg_name(lp, extract_vgname(cmd, NULL)))
+			return_0;
 
 		if (!lp->vg_name) {
 			log_error("The origin name should include the "
@@ -115,8 +116,9 @@
 			if (!_set_vg_name(lp, extract_vgname(cmd, lp->pool)))
 				return_0;
 
-			if (!lp->vg_name)
-				_set_vg_name(lp, extract_vgname(cmd, NULL));
+			if (!lp->vg_name &&
+			    !_set_vg_name(lp, extract_vgname(cmd, NULL)))
+				return_0;
 
 			if (!lp->vg_name) {
 				log_error("The pool name should include the "


