From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:07:39 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20120301100739.8781.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:07:39

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Check for version string buffer
	
	Since lvm seems to call driver_version(NULL, 0)  this would lead
	to crash. Though the combination of the code is probably very hard to hit.
	If the user doesn't supply version buffer, just skip printing to buffer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.577&r2=1.578
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/WHATS_NEW_DM	2012/03/01 09:50:04	1.577
+++ LVM2/WHATS_NEW_DM	2012/03/01 10:07:38	1.578
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Support dm_task_get_driver_version() query without version string.
   Log failure of pthread_join when cleaning unused threads in dmeventd.
   Fix empty string warning logic in _find_config_str. (1.02.68)
   Fix dm_task_set_name to properly resolve path to dm name (1.02.71).
--- LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 12:17:34	1.138
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/03/01 10:07:38	1.139
@@ -467,14 +467,21 @@
 	unsigned *v;
 
 	if (!dmt->dmi.v4) {
-		version[0] = '\0';
+		if (version)
+			version[0] = '\0';
 		return 0;
 	}
 
 	v = dmt->dmi.v4->version;
-	snprintf(version, size, "%u.%u.%u", v[0], v[1], v[2]);
 	_dm_version_minor = v[1];
 	_dm_version_patchlevel = v[2];
+	if (version &&
+	    (snprintf(version, size, "%u.%u.%u", v[0], v[1], v[2]) < 0)) {
+		log_error("Buffer for version is to short.");
+		if (size > 0)
+			version[0] = '\0'
+		return 0;
+	}
 
 	return 1;
 }
@@ -494,7 +501,8 @@
 		_log_suppress = 1;
 
 	r = dm_task_run(task);
-	dm_task_get_driver_version(task, version, size);
+	if (!dm_task_get_driver_version(task, version, size))
+		stack;
 	dm_task_destroy(task);
 	_log_suppress = 0;
 


