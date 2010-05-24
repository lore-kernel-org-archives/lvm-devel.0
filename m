From: agk@sourceware.org <agk@sourceware.org>
Date: 24 May 2010 23:11:37 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c lib/mis ...
Message-ID: <20100524231137.27689.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-24 23:11:36

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 
	lib/misc       : util.h 
	libdm          : libdm-deptree.c 

Log message:
	Replace strncmp kernel version number checks with proper ones

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1597&r2=1.1598
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/WHATS_NEW	2010/05/24 22:53:48	1.1597
+++ LVM2/WHATS_NEW	2010/05/24 23:11:34	1.1598
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Replace strncmp kernel version number checks with proper ones.
   Avoid selecting names under /dev/block if there is an alternative.
   Update clustered log kernel module name to log-userspace for 2.6.31 onwards.
   Activate only first head of Replicator for vgchange -ay.
--- LVM2/lib/mirror/mirrored.c	2010/05/24 17:46:47	1.70
+++ LVM2/lib/mirror/mirrored.c	2010/05/24 23:11:35	1.71
@@ -474,6 +474,7 @@
 	unsigned maj2, min2, patchlevel2;
 	char vsn[80];
 	struct utsname uts;
+	unsigned kmaj, kmin, krel;
 
 	if (!_mirrored_checked) {
 		_mirrored_present = target_present(cmd, "mirror", 1);
@@ -511,8 +512,9 @@
 			 * The dm-log-userspace module was added to the
 			 * 2.6.31 kernel.
 			 */
-			/* FIXME Replace the broken string comparison! */
-			if (!uname(&uts) && strncmp(uts.release, "2.6.31", 6) < 0) {
+			if (!uname(&uts) &&
+			    (sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) == 3) &&
+			    KERNEL_VERSION(kmaj, kmin, krel) < KERNEL_VERSION(2, 6, 31)) {
 				if (module_present(cmd, "log-clustered"))
 					_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 			} else if (module_present(cmd, "log-userspace"))
--- LVM2/lib/misc/util.h	2008/06/23 19:04:34	1.5
+++ LVM2/lib/misc/util.h	2010/05/24 23:11:35	1.6
@@ -27,4 +27,6 @@
 
 #define uninitialized_var(x) x = x
 
+#define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
+
 #endif
--- LVM2/libdm/libdm-deptree.c	2010/05/24 17:46:47	1.80
+++ LVM2/libdm/libdm-deptree.c	2010/05/24 23:11:35	1.81
@@ -1540,9 +1540,9 @@
 	int pos = 0;
 	char logbuf[DM_FORMAT_DEV_BUFSIZE];
 	const char *logtype;
+	unsigned kmaj, kmin, krel;
 
-	r = uname(&uts);
-	if (r)
+	if (!uname(&uts) || sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) != 3)
 		return_0;
 
 	if ((seg->flags & DM_BLOCK_ON_ERROR)) {
@@ -1556,7 +1556,7 @@
 		 * "handle_errors" by the dm-mirror module's version
 		 * number (>= 1.12) or by the kernel version (>= 2.6.22).
 		 */
-		if (strncmp(uts.release, "2.6.22", 6) >= 0)
+		if (KERNEL_VERSION(kmaj, kmin, krel) >= KERNEL_VERSION(2, 6, 22))
 			handle_errors = 1;
 		else
 			block_on_error = 1;
@@ -1575,8 +1575,7 @@
 		 * The dm-log-userspace module was added to the
 		 * 2.6.31 kernel.
 		 */
-		/* FIXME Replace the broken string comparison! */
-		if (strncmp(uts.release, "2.6.31", 6) >= 0)
+		if (KERNEL_VERSION(kmaj, kmin, krel) >= KERNEL_VERSION(2, 6, 31))
 			dm_log_userspace = 1;
 	}
 


