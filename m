From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 05:33:38 -0000
Subject: LVM2 doc/example.conf lib/metadata/metadata.c ...
Message-ID: <20080919053338.29607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 05:33:37

Modified files:
	doc            : example.conf 
	lib/metadata   : metadata.c 
	lib/config     : defaults.h 
	.              : WHATS_NEW 

Log message:
	Add device/md_chunk_alignment to lvm.conf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.958&r2=1.959

--- LVM2/doc/example.conf	2008/04/10 18:50:37	1.36
+++ LVM2/doc/example.conf	2008/09/19 05:33:36	1.37
@@ -93,6 +93,11 @@
     # 1 enables; 0 disables.
     md_component_detection = 1
 
+    # By default, if a PV is placed directly upon an md device, LVM2
+    # will align its data blocks with the the chunk_size exposed in sysfs.
+    # 1 enables; 0 disables.
+    md_chunk_alignment = 1
+
     # If, while scanning the system for PVs, LVM2 encounters a device-mapper
     # device that has its I/O suspended, it waits for it to become accessible.
     # Set this to 1 to skip such devices.  This should only be needed
--- LVM2/lib/metadata/metadata.c	2008/09/19 05:19:09	1.189
+++ LVM2/lib/metadata/metadata.c	2008/09/19 05:33:36	1.190
@@ -27,6 +27,7 @@
 #include "display.h"
 #include "locking.h"
 #include "archiver.h"
+#include "defaults.h"
 
 #include <sys/param.h>
 
@@ -74,7 +75,9 @@
 	/*
 	 * Align to chunk size of underlying md device if present
 	 */
-	if (pv->dev)
+	if (pv->dev &&
+	    find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
+				  DEFAULT_MD_CHUNK_ALIGNMENT))
 		pv->pe_align = MAX(pv->pe_align,
 				   dev_md_chunk_size(pv->fmt->cmd->sysfs_dir,
 						     pv->dev));
--- LVM2/lib/config/defaults.h	2008/06/24 22:48:53	1.42
+++ LVM2/lib/config/defaults.h	2008/09/19 05:33:37	1.43
@@ -32,6 +32,7 @@
 #define DEFAULT_PROC_DIR "/proc"
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
+#define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 
 #define DEFAULT_LOCK_DIR "/var/lock/lvm"
--- LVM2/WHATS_NEW	2008/09/19 05:19:08	1.958
+++ LVM2/WHATS_NEW	2008/09/19 05:33:37	1.959
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Add device/md_chunk_alignment to lvm.conf.
   Pass struct physical_volume to pe_align and adjust for md chunk size.
   Store sysfs location in struct cmd_context.
   Avoid shuffling remaining mirror images when removing one, retaining primary.


