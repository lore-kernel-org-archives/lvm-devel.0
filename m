From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 5 Jan 2011 20:02:46 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20110105200246.25601.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-05 20:02:45

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Prevent the user from simultaneously adding a mirror log while removing
	a mirror image (or removing a log while adding a mirror).  Advise the
	user to use two separate commands instead.
	
	This issue become especially problematic when PVs are specified, as they
	tend to mean different things when adding vs removing.  In a command that
	mixes adding and removing, it is impossible to decern exactly what the
	user wants.
	
	This change prevents bug 603912.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1860&r2=1.1861
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/WHATS_NEW	2011/01/05 14:03:36	1.1860
+++ LVM2/WHATS_NEW	2011/01/05 20:02:45	1.1861
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Prevent adding/removing mirror log while removing/adding an image.
   Add missing tests in _setup_task().
   Fail poll daemon creation when lvmcache_init() fails.
   Return defined value for errors in _copy_percent() and _snap_percent().
--- LVM2/tools/lvconvert.c	2010/12/08 20:50:51	1.152
+++ LVM2/tools/lvconvert.c	2011/01/05 20:02:45	1.153
@@ -927,6 +927,25 @@
 	}
 
 	/*
+	 * Disallow adding logs while removing images or
+	 *          adding images while removing logs
+	 */
+	if ((*old_log_count < *new_log_count) &&
+	    (*old_mimage_count > *new_mimage_count)) {
+		log_error("Mirror logs cannot be added while images are"
+			  " being removed.");
+		log_error("Try two separate commands.");
+		return 0;
+	}
+	if ((*old_log_count > *new_log_count) &&
+	    (*old_mimage_count < *new_mimage_count)) {
+		log_error("Mirror images cannot be added while logs are"
+			  " being removed.");
+		log_error("Try two separate commands.");
+		return 0;
+	}
+
+	/*
 	 * No mirrored logs for cluster mirrors until
 	 * log daemon is multi-threaded.
 	 */


