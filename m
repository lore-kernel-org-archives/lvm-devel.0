From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Jun 2011 21:31:22 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110622213122.1831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-06-22 21:31:21

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	lib/metadata   : mirror.c 

Log message:
	Fix issue preventing cluster mirror creation.
	
	Mirrors used to be created by first creating a linear device and then adding
	the other images plus the log.  Now mirrors are created by creating all the
	images in one go and then adding the log separately.  The new way ran into
	the condition that cluster mirrors cannot change the log type (in the case
	of creation, from core -> disk) while the mirror is not active.  (It isn't
	active because it is in the process of being created.)  The reason this
	condition is in place is because a remote node may have the mirror active, and
	we don't want to alter the log underneath it.
	
	What we really needed was a way of checking if the mirror was active remotely
	but not locally, and in that case do not allow a change of the log.  I've added
	this check, and cluster mirrors can now be created again.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2023&r2=1.2024
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.202&r2=1.203
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/WHATS_NEW	2011/06/17 14:50:53	1.2023
+++ LVM2/WHATS_NEW	2011/06/22 21:31:21	1.2024
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix issue preventing cluster mirror creation.
   Disable udev fallback by default and add activation/udev_fallback to lvm.conf.
   Call vg_mark_partial_lvs() before VG structure is returned from the cache.
   Remove unused internal flag ACTIVATE_EXCL from the code.
--- LVM2/lib/activate/activate.c	2011/06/17 14:30:58	1.202
+++ LVM2/lib/activate/activate.c	2011/06/22 21:31:21	1.203
@@ -823,13 +823,11 @@
 	return _lv_is_active(lv, NULL, NULL);
 }
 
-/*
-int lv_is_active_locally(struct logical_volume *lv)
+int lv_is_active_but_not_locally(struct logical_volume *lv)
 {
 	int l;
-	return _lv_is_active(lv, &l, NULL) && l;
+	return _lv_is_active(lv, &l, NULL) && !l;
 }
-*/
 
 int lv_is_active_exclusive_locally(struct logical_volume *lv)
 {
--- LVM2/lib/activate/activate.h	2011/06/17 14:14:19	1.77
+++ LVM2/lib/activate/activate.h	2011/06/22 21:31:21	1.78
@@ -101,6 +101,7 @@
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(struct logical_volume *lv);
+int lv_is_active_but_not_locally(struct logical_volume *lv);
 int lv_is_active_exclusive_locally(struct logical_volume *lv);
 int lv_is_active_exclusive_remotely(struct logical_volume *lv);
 
--- LVM2/lib/metadata/mirror.c	2011/06/17 14:27:35	1.154
+++ LVM2/lib/metadata/mirror.c	2011/06/22 21:31:21	1.155
@@ -1857,15 +1857,9 @@
 		return 0;
 	}
 
-	/*
-	 * We are unable to convert the log of inactive cluster mirrors
-	 * due to the inability to detect whether the mirror is active
-	 * on remote nodes (even though it is inactive on this node)
-	 */
-	if (vg_is_clustered(lv->vg) &&
-	    !(lv_info(cmd, lv, 0, &info, 0, 0) && info.exists)) {
-		log_error("Unable to convert the log of inactive "
-			  "cluster mirror %s", lv->name);
+	if (lv_is_active_but_not_locally(lv)) {
+		log_error("Unable to convert the log of a mirror, %s, that is "
+			  "active remotely but not locally", lv->name);
 		return 0;
 	}
 


