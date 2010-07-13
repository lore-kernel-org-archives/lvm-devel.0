From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Jul 2010 21:53:08 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100713215308.19532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-13 21:53:08

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix for bug 612311: Split of linear provides no error msg
	
	An unhandled condition allowed the command to terminate
	cleanly without a warning.  Added a check for the
	'--splitmirrors' argument to allow execution to the lower
	level function that has the check to see if the user is
	trying to split a linear device.  You should now see a
	message if you try to use --splitmirrors on a linear device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/tools/lvconvert.c	2010/07/09 15:34:48	1.138
+++ LVM2/tools/lvconvert.c	2010/07/13 21:53:07	1.139
@@ -861,7 +861,8 @@
 	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = *old_mimage_count + lp->mirrors;
 	else if (lp->mirrors_sign == SIGN_MINUS)
-		lp->mirrors = *old_mimage_count - lp->mirrors;
+		lp->mirrors = (*old_mimage_count > lp->mirrors) ?
+			*old_mimage_count - lp->mirrors: 0;
 	else
 		lp->mirrors += 1;
 
@@ -876,8 +877,8 @@
 
 	/* Did the user try to subtract more legs than available? */
 	if (lp->mirrors < 1) {
-		log_error("Logical volume %s only has %" PRIu32 " mirrors.",
-			  lv->name, *old_mimage_count);
+		log_error("Unable to reduce images by specified amount - only %d in %s",
+			  *old_mimage_count, lv->name);
 		return 0;
 	}
 
@@ -1561,7 +1562,9 @@
 			stack;
 			return ECMD_FAILED;
 		}
-	} else if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
+	} else if (arg_count(cmd, mirrors_ARG) ||
+		   arg_count(cmd, splitmirrors_ARG) ||
+		   (lv->status & MIRRORED)) {
 		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;


