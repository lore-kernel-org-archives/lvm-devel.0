From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Nov 2009 14:35:40 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h tools/l ...
Message-ID: <20091127143540.12555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-27 14:35:39

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Do not allow creating mirrors of more than 8 images.
	
	This is kernel limitation in all kernel versions,
	so better detect this early.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1334&r2=1.1335
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.210&r2=1.211

--- LVM2/WHATS_NEW	2009/11/27 14:32:16	1.1334
+++ LVM2/WHATS_NEW	2009/11/27 14:35:38	1.1335
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Do not allow creating mirrors of more than 8 images.
   Use locking_type 3 (compiled in cluster locking) in lvmconf.
   Remove duplicate dm_list macros and functions.
   Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.
--- LVM2/lib/config/defaults.h	2009/10/05 12:44:21	1.53
+++ LVM2/lib/config/defaults.h	2009/11/27 14:35:39	1.54
@@ -47,6 +47,7 @@
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_DEV_FAULT_POLICY "remove"
+#define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
 
--- LVM2/tools/lvconvert.c	2009/11/03 15:50:44	1.97
+++ LVM2/tools/lvconvert.c	2009/11/27 14:35:39	1.98
@@ -571,6 +571,12 @@
 	else
 		lp->mirrors += 1;
 
+	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Only up to %d images in mirror supported currently.",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
 	if (repair) {
 		cmd->handles_missing_pvs = 1;
 		cmd->partial_activation = 1;
--- LVM2/tools/lvcreate.c	2009/11/04 14:47:28	1.210
+++ LVM2/tools/lvcreate.c	2009/11/27 14:35:39	1.211
@@ -500,6 +500,12 @@
 		return 0;
 	}
 
+	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Only up to %d images in mirror supported currently.",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
 	/*
 	 * Read ahead.
 	 */


