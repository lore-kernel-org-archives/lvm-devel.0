From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:28:00 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20111115172800.28946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:27:42

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Reorder AND test condition
	
	Take the easiest condition for checking first since they must
	apply all together, check local conditions first before doing
	more expensive tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2184&r2=1.2185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.334&r2=1.335

--- LVM2/WHATS_NEW	2011/11/15 11:54:15	1.2184
+++ LVM2/WHATS_NEW	2011/11/15 17:27:41	1.2185
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Reorder prompt conditions for removal of active volumes.
   Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
   Fix --enable-static_link unless using --enable-dmeventd / --enable-udev_sync.
   Move gentoo MAKEDEV to /sbin in lvm2create_initrd.
--- LVM2/lib/metadata/lv_manip.c	2011/11/15 17:23:51	1.334
+++ LVM2/lib/metadata/lv_manip.c	2011/11/15 17:27:41	1.335
@@ -3179,8 +3179,9 @@
 		if (!lv_check_not_in_use(cmd, lv, &info))
 			return_0;
 
-		if (lv_is_active(lv) && (force == PROMPT) &&
+		if ((force == PROMPT) &&
 		    lv_is_visible(lv) &&
+		    lv_is_active(lv) &&
 		    yes_no_prompt("Do you really want to remove active "
 				  "%slogical volume %s? [y/n]: ",
 				  vg_is_clustered(vg) ? "clustered " : "",


