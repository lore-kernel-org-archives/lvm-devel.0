From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 12:06:41 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120213120641.6073.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 12:06:40

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Ensure allocated device does not leak on error path
	
	For unimplementd canonicalize_file_name set to NULL

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.555&r2=1.556
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/WHATS_NEW_DM	2012/02/13 11:24:09	1.555
+++ LVM2/WHATS_NEW_DM	2012/02/13 12:06:39	1.556
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Fix memory leak in fail path of parse_loop_device_name() in dmsetup.
   Check for missing reply_uuid in dm_event_get_registered_device().
   Check for allocation failure in dmeventd restart().
   Add few missing allocation failures tests in dmsetup.
--- LVM2/tools/dmsetup.c	2012/02/13 11:13:44	1.175
+++ LVM2/tools/dmsetup.c	2012/02/13 12:06:40	1.176
@@ -3043,6 +3043,8 @@
 	_path = canonicalize_file_name(path);
 #else
 	/* FIXME Provide alternative */
+	log_error(INTERNAL_ERROR "Unimplemented _get_abspath.");
+	_path = NULL;
 #endif
 	return _path;
 }
@@ -3050,7 +3052,7 @@
 static char *parse_loop_device_name(const char *dev, const char *dev_dir)
 {
 	char *buf;
-	char *device;
+	char *device = NULL;
 
 	if (!(buf = dm_malloc(PATH_MAX)))
 		return NULL;
@@ -3083,7 +3085,9 @@
 	return buf;
 
 error:
+	dm_free(device);
 	dm_free(buf);
+
 	return NULL;
 }
 


