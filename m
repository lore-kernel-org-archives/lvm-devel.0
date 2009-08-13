From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Aug 2009 12:03:47 -0000
Subject: LVM2/tools vgextend.c
Message-ID: <20090813120347.6299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-13 12:03:47

Modified files:
	tools          : vgextend.c 

Log message:
	Fix vgextend error path - if ORPHAN lock fails, unlock and release vg.
	
	Full changes
	- Fix vgextend error path when lock_vol(VG_ORPHANS) fails
	- Move lock_vol(VG_ORPHANS) before archive(vg) - safe & simpler error paths
	- Remove legacy comment/code that no longer applies
	
	Found in review - Milan Broz <mbroz@redhat.com>
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/tools/vgextend.c	2009/07/24 15:01:44	1.48
+++ LVM2/tools/vgextend.c	2009/08/13 12:03:46	1.49
@@ -43,21 +43,15 @@
 		return ECMD_FAILED;
 	}
 
-/********** FIXME
-	log_print("maximum logical volume size is %s",
-		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
-	dm_free(dummy);
-	dummy = NULL;
-**********/
-
-	if (!archive(vg))
-		goto error;
-
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return ECMD_FAILED;
 	}
 
+	if (!archive(vg))
+		goto error;
+
 	/* extend vg */
 	if (!vg_extend(vg, argc, argv))
 		goto error;


