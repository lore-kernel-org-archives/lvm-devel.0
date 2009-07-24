From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 15:01:44 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c tools ...
Message-ID: <20090724150144.13026.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 15:01:44

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	tools          : vgcreate.c vgextend.c 

Log message:
	Revert previous patch that moved VG_ORPHAN lock inside vg_extend.
	
	We must hold the VG_ORPHAN lock until we commit to disk.  Otherwise,
	we risk a race condition on vgcreate / vgextend.  Reverts the following
	commit:
	
	commit 72a41480ba66d7dc2d05ef8583080b6b08208507
	Author: Dave Wysochanski <dwysocha@redhat.com>
	Date:   Fri Jul 10 20:09:21 2009 +0000
	
	Move orphan lock obtain/release inside vg_extend().
	
	With this change we now have vgcreate/vgextend liblvm functions.
	Note that this changes the lock order of the following functions as the
	orphan lock is now obtained first.  With our policy of non-blocking
	second locks, this should not be a problem.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1199&r2=1.1200
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.258&r2=1.259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2009/07/23 23:55:01	1.1199
+++ LVM2/WHATS_NEW	2009/07/24 15:01:43	1.1200
@@ -1,5 +1,7 @@
 Version 2.02.50 - 
 ================================
+  Fix race condition with vgcreate and vgextend on same device (2.02.49).
+  Remove redundant validate_name call from vgreduce.
   Add lvm_{pv|vg|lv}_get_{name|uuid} liblvm functions.
   Add lvm_vg_list_pvs and lvm_vg_list_lvs liblvm functions.
   Remove unused handles lvseg, pvseg inside liblvm/lvm.h.
--- LVM2/lib/metadata/metadata.c	2009/07/16 20:18:16	1.258
+++ LVM2/lib/metadata/metadata.c	2009/07/24 15:01:43	1.259
@@ -518,11 +518,6 @@
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return 0;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
 		if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
@@ -536,13 +531,11 @@
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
-	unlock_vg(cmd, VG_ORPHANS);
 	return 1;
 
       bad:
 	log_error("Unable to add physical volume '%s' to "
 		  "volume group '%s'.", pv_names[i], vg->name);
-	unlock_vg(cmd, VG_ORPHANS);
 	return 0;
 }
 
--- LVM2/tools/vgcreate.c	2009/07/10 20:09:21	1.64
+++ LVM2/tools/vgcreate.c	2009/07/24 15:01:44	1.65
@@ -57,6 +57,11 @@
 	    !vg_set_alloc_policy(vg, vp_new.alloc))
 		goto_bad;
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		goto bad_orphan;
+	}
+
 	/* attach the pv's */
 	if (!vg_extend(vg, argc - 1, argv + 1))
 		goto_bad;
@@ -106,6 +111,7 @@
 		goto bad;
 	}
 
+	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vp_new.vg_name);
 
 	backup(vg);
@@ -117,6 +123,8 @@
 	return ECMD_PROCESSED;
 
 bad:
+	unlock_vg(cmd, VG_ORPHANS);
+bad_orphan:
 	vg_release(vg);
 	unlock_vg(cmd, vp_new.vg_name);
 	return ECMD_FAILED;
--- LVM2/tools/vgextend.c	2009/07/14 02:14:05	1.47
+++ LVM2/tools/vgextend.c	2009/07/24 15:01:44	1.48
@@ -42,6 +42,7 @@
 		vg_release(vg);
 		return ECMD_FAILED;
 	}
+
 /********** FIXME
 	log_print("maximum logical volume size is %s",
 		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
@@ -52,6 +53,11 @@
 	if (!archive(vg))
 		goto error;
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return ECMD_FAILED;
+	}
+
 	/* extend vg */
 	if (!vg_extend(vg, argc, argv))
 		goto error;
@@ -69,6 +75,7 @@
 	r = ECMD_PROCESSED;
 
 error:
+	unlock_vg(cmd, VG_ORPHANS);
 	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }


