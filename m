From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 15:07:41 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110609150741.9287.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 15:07:41

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Accept kernel version 3 (3.0-rc and similar).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.468&r2=1.469
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW_DM	2011/04/29 19:05:11	1.468
+++ LVM2/WHATS_NEW_DM	2011/06/09 15:07:40	1.469
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Accept new kernel version 3 formats in initialisation.
 
 Version 1.02.64 - 29th April 2011
 ==================================
--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/25 23:50:35	1.103
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/09 15:07:40	1.104
@@ -73,9 +73,9 @@
 static unsigned _dm_version_patchlevel = 0;
 static int _log_suppress = 0;
 
-static int _kernel_major;
-static int _kernel_minor;
-static int _kernel_release;
+static int _kernel_major = 0;
+static int _kernel_minor = 0;
+static int _kernel_release = 0;
 
 /*
  * If the kernel dm driver only supports one major number
@@ -152,6 +152,7 @@
 {
 	static int _uts_set = 0;
 	struct utsname _uts;
+	int parts;
 
 	if (_uts_set)
 		return 1;
@@ -160,10 +161,14 @@
 		log_error("uname failed: %s", strerror(errno));
 		return 0;
 	}
-	if (sscanf(_uts.release, "%d.%d.%d",
+
+	parts = sscanf(_uts.release, "%d.%d.%d",
 			&_kernel_major,
 			&_kernel_minor,
-			&_kernel_release) != 3) {
+			&_kernel_release);
+
+	/* Kernels with a major number of 2 always had 3 parts. */
+	if (parts < 1 || (_kernel_major < 3 && parts < 3)) {
 		log_error("Could not determine kernel version used.");
 		return 0;
 	}


