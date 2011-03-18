From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Mar 2011 13:21:05 -0000
Subject: LVM2 libdm/libdm-common.c libdm/ioctl/libdm-if ...
Message-ID: <20110318132105.18078.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-18 13:21:03

Modified files:
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 
	.              : WHATS_NEW_DM 

Log message:
	Improve debug stack trace
	
	dm_check_version reports log_error() - so use return_NULL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.456&r2=1.457

--- LVM2/libdm/libdm-common.c	2011/03/03 13:05:41	1.113
+++ LVM2/libdm/libdm-common.c	2011/03/18 13:21:02	1.114
@@ -183,7 +183,7 @@
 
 	if (!dm_check_version()) {
 		dm_free(dmt);
-		return NULL;
+		return_NULL;
 	}
 
 	dmt->type = type;
--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/18 12:17:58	1.100
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/18 13:21:02	1.101
@@ -965,8 +965,10 @@
 	if (_check_version(dmversion, sizeof(dmversion), _dm_compat))
 		return 1;
 
-	if (!_dm_compat)
+	if (!_dm_compat) {
+		log_error("Support for older device-mapped version is disabled.");
 		goto bad;
+	}
 
 	log_verbose("device-mapper ioctl protocol version %u failed. "
 		    "Trying protocol version 1.", _dm_version);
--- LVM2/WHATS_NEW_DM	2011/03/18 12:17:57	1.456
+++ LVM2/WHATS_NEW_DM	2011/03/18 13:21:03	1.457
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Improve stack debug reporting in dm_task_create().
   Fallback to control node creation only if node doesn't exist yet.
   Change dm_hash API for binary data to accept const void *key.
   Fix memory access of empty params string in _reload_with_suppression_v4().


