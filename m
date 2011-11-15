From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:29:52 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111115172952.31921.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:29:52

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin update prompt message
	
	Enhance message with info about how many thin volumes are going to
	be removed with thin pool removal.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.335&r2=1.336

--- LVM2/lib/metadata/lv_manip.c	2011/11/15 17:27:41	1.335
+++ LVM2/lib/metadata/lv_manip.c	2011/11/15 17:29:52	1.336
@@ -3257,10 +3257,12 @@
 	}
 
 	if (lv_is_used_thin_pool(lv)) {
-		/* remove thin LVs first */
+		/* Remove thin LVs first */
 		if ((force == PROMPT) &&
-		    yes_no_prompt("Do you really want to remove all thin volumes when removing"
-				  " pool logical volume %s? [y/n]: ", lv->name) == 'n') {
+		    yes_no_prompt("Removing pool %s will also remove %u "
+				  "thin volume(s). OK? [y/n]: ", lv->name,
+				  /* Note: Snaphosts not included */
+				  dm_list_size(&lv->segs_using_this_lv)) == 'n') {
 			log_error("Logical volume %s not removed.", lv->name);
 			return 0;
 		}


