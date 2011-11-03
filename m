From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:59:21 -0000
Subject: LVM2/tools lvchange.c toollib.c
Message-ID: <20111103145921.1089.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:59:20

Modified files:
	tools          : lvchange.c toollib.c 

Log message:
	Thin removing limitation on activation of pool device.
	
	Since activation of pool is now independent on thin activation,
	user may do whatever he needs - thought preferable thin should stay alive,
	but it it will be found inactivate, update_pool will bring the pool up.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.232&r2=1.233

--- LVM2/tools/lvchange.c	2011/11/03 14:41:18	1.134
+++ LVM2/tools/lvchange.c	2011/11/03 14:59:20	1.135
@@ -534,12 +534,6 @@
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_used_thin_pool(lv) &&
-	    (arg_count(cmd, available_ARG))) {
-		log_error("Can't change pool volume \"%s\".", lv->name);
-		return ECMD_FAILED;
-	}
-
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)) &&
 	    arg_count(cmd, available_ARG)) {
 		log_error("Can't change snapshot logical volume \"%s\"",
--- LVM2/tools/toollib.c	2011/10/28 20:28:01	1.232
+++ LVM2/tools/toollib.c	2011/11/03 14:59:20	1.233
@@ -126,11 +126,6 @@
 		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
-		/* Only unused thin pool can change its availability */
-		if (!lvargs_supplied && lv_is_used_thin_pool(lvl->lv) &&
-		    arg_count(cmd, available_ARG))
-			continue;
-
 		/*
 		 * Only let hidden LVs through it --all was used or the LVs 
 		 * were specifically named on the command line.


