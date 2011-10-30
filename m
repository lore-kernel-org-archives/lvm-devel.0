From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:02:18 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111030220218.5633.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:02:18

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Cleanup unsuccessfully created thin LV
	
	If something fails during creation of thin LV remove such LV
	and deactivate in case it's been already tried to activate
	(i.e. thin kernel driver fails for some reason.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.314&r2=1.315

--- LVM2/lib/metadata/lv_manip.c	2011/10/30 22:01:39	1.314
+++ LVM2/lib/metadata/lv_manip.c	2011/10/30 22:02:18	1.315
@@ -4150,7 +4150,7 @@
 		    !deactivate_lv(cmd, pool_lv)) {
 			log_error("Failed to deactivate unused pool %s.",
 				  pool_lv->name);
-			return NULL;
+			goto revert_new_lv;
 		}
 
 		/*
@@ -4159,12 +4159,16 @@
 		 */
 
 		if (!(first_seg(lv)->device_id =
-		      get_free_pool_device_id(first_seg(pool_lv))))
-			return_NULL;
+		      get_free_pool_device_id(first_seg(pool_lv)))) {
+			stack;
+			goto revert_new_lv;
+		}
 
 		if (!attach_pool_message(first_seg(pool_lv),
-					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
-			return_NULL;
+					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0)) {
+			stack;
+			goto revert_new_lv;
+		}
 	}
 
 	if (lp->log_count &&
@@ -4194,7 +4198,7 @@
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate thin %s.",
 				  lv->name);
-			goto revert_new_lv;
+			goto deactivate_and_revert_new_lv;
 		}
 	} else if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {


