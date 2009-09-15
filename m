From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Sep 2009 11:41:40 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-co ...
Message-ID: <20090915114140.26016.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-15 11:41:39

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	dm release cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1262&r2=1.1263
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.298&r2=1.299
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/WHATS_NEW	2009/09/15 10:57:16	1.1262
+++ LVM2/WHATS_NEW	2009/09/15 11:41:38	1.1263
@@ -5,17 +5,13 @@
   Make readonly locking available as locking type 4.
   Fix readonly locking to permit writeable global locks (for vgscan). (2.02.49)
   Add lvm_vg_is_clustered, lvm_vg_is_exported, and lvm_vg_is_partial.
-  Add manpage entry for dmsetup's udevcomplete_all and udevcookies commands.
   Add DM_UDEV_RULES_VSN udev enviroment variable.
-  Check that udev is running and set internal state appropriately.
   Add libudev configuration check.
   Add lvm2app.sh to nightly tests conditional upon configure --enable-applib.
   Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
   Enforce an alphabetical lock ordering for vgname locks.
   Refactor vgsplit, vgmerge, and vgrename to obey vgname ordering rules.
   Implement write lock prioritisation for file locking and make it default.
-  Fix clogd build direcory.
-  Drop unrequired clogd Makefile.
   Fix clvmd autodetection check and cleanup related configure messages.
   Fix Makefile distclean target.
   Make clvmd check corosync to see what cluster interface it should use.
@@ -25,6 +21,7 @@
   Fix pvcreate on a partition (2.02.51).
   Fix vgcfgrestore error paths when locking fails (2.02.49).
   Added configure --enable-cmirrord to build the cluster mirror log daemon.
+  Rename clogd to cmirrord.
   Make lvchange --refresh only take a read lock on volume group.
   Fix bug where non-blocking file locks could be granted in error.
   Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
--- LVM2/WHATS_NEW_DM	2009/09/15 10:57:16	1.298
+++ LVM2/WHATS_NEW_DM	2009/09/15 11:41:38	1.299
@@ -1,9 +1,12 @@
 Version 1.02.37 - 15th September 2009
-====================================
-  Add y|--yes option for dmsetup to provide a default 'YES' answer to questions.
-  Fix Makefile to take into account dmsetup's reconfiguration.
+=====================================
+  Add dmsetup manpage entries for udevcomplete_all and udevcookies.
+  Check udev is running when processing cookies and retain state internally.
+  Add y|--yes option to dmsetup for default 'yes' answer to prompts.
+  Fix tools Makefile to process dmsetup sources separately.
   Restore umask when device node creation fails.
-  Fix mirror table CTR code to handle 'block_on_error' and 'cluster' features
+  Check kernel vsn to use 'block_on_error' or 'handle_errors' in mirror table.
+  Add dm-log-userspace.h to tree for cmirrord builds.
 
 Version 1.02.36 - 6th August 2009
 =================================
--- LVM2/libdm/libdm-common.c	2009/09/11 16:11:25	1.80
+++ LVM2/libdm/libdm-common.c	2009/09/15 11:41:39	1.81
@@ -833,27 +833,29 @@
 
 static int _check_udev_is_running(void)
 {
-	#ifndef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+
+#  ifndef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+
 	log_debug("Could not get udev state because libudev library "
 		  "was not found and it was not compiled in. "
 		  "Assuming udev is not running.");
 	return 0;
-	#else	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
+
+#  else	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
+
 	struct udev *udev;
 	struct udev_queue *udev_queue;
 	int r;
 
 	if (!(udev = udev_new()))
-		goto error;
+		goto_bad;
 
 	if (!(udev_queue = udev_queue_new(udev))) {
 		udev_unref(udev);
-		goto error;
+		goto_bad;
 	}
 
-	r = udev_queue_get_udev_is_active(udev_queue);
-
-	if (!r)
+	if (!(r = udev_queue_get_udev_is_active(udev_queue)))
 		log_debug("Udev is not running. "
 			  "Not using udev synchronisation code.");
 
@@ -862,10 +864,12 @@
 
 	return r;
 
-error:
-	log_debug("Could not get udev state. Assuming udev is not running.");
+bad:
+	log_error("Could not get udev state. Assuming udev is not running.");
 	return 0;
-	#endif	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
+
+#  endif	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
+
 }
 
 void dm_udev_set_sync_support(int sync_with_udev)


