From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 15:58:20 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111103155820.32449.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 15:58:20

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Thin keep pool device in the same state
	
	Leave the optimalisation to be done differently and preserve
	availability state of the pool device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/lib/metadata/thin_manip.c	2011/11/03 14:57:04	1.21
+++ LVM2/lib/metadata/thin_manip.c	2011/11/03 15:58:20	1.22
@@ -307,10 +307,11 @@
 
 	if (activate) {
 		/* If the pool was not yet activated, do it */
-		if (!lv_is_active(lv) &&
-		    !activate_lv_excl(lv->vg->cmd, lv)) {
-			log_error("Failed to activate %s.", lv->name);
-			return 0;
+		if (!lv_is_active(lv)) {
+			if (!activate_lv_excl(lv->vg->cmd, lv))
+				return_0;
+			if (!deactivate_lv(lv->vg->cmd, lv))
+				return_0;
 		}
 		/* If already active, do suspend resume
 		 *


