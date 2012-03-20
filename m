From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Mar 2012 10:47:03 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20120320104703.6315.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-20 10:47:03

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	Support improperly formated device numbers
	
	There are kernel drivers (smblk) which set '-1' as their device major number.
	This number is listed in /proc/devices then - but the kernel itself is using
	just 12 bits - thus device is accessible via 4095 - there is posted patch
	for 3.4 to fix this behavior (0 for auto allocation was mean to be used).
	
	However to still allow using such devices with older kernels add some code
	to use same behavior - so cut 12 bits from the major number from /proc/devices.
	
	For now use log_warn() - maybe the severity of the message could be lowered
	to just verbose level.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2359&r2=1.2360
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2012/03/16 12:53:05	1.2359
+++ LVM2/WHATS_NEW	2012/03/20 10:47:02	1.2360
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Support improperly formated device numbers in /proc/devices (2.02.91).
   Fix fsadm propagation of -e option.
   Fix fsadm parsing of /proc/mounts files (don't check for substrings).
   Fix fsadm usage of arguments with space.
--- LVM2/lib/filters/filter.c	2012/03/12 14:40:42	1.71
+++ LVM2/lib/filters/filter.c	2012/03/20 10:47:03	1.72
@@ -196,7 +196,7 @@
 	size_t dev_len = 0;
 	const struct dm_config_value *cv;
 	const char *name;
-
+	char *nl;
 
 	if (!*proc) {
 		log_verbose("No proc filesystem found: using all block device "
@@ -227,7 +227,20 @@
 
 		/* If it's not a number it may be name of section */
 		line_maj = atoi(((char *) (line + i)));
-		if ((line_maj <= 0) || (line_maj >= NUMBER_OF_MAJORS)) {
+
+		if (line_maj < 0 || line_maj >= NUMBER_OF_MAJORS) {
+			/*
+			 * Device numbers shown in /proc/devices are actually direct
+			 * numbers passed to registering function, however the kernel
+			 * uses only 12 bits, so use just 12 bits for major.
+			 */
+			if ((nl = strchr(line, '\n'))) *nl = '\0';
+			log_warn("WARNING: /proc/devices line: %s, replacing major with %d.",
+				 line, line_maj & (NUMBER_OF_MAJORS - 1));
+			line_maj &= (NUMBER_OF_MAJORS - 1);
+		}
+
+		if (!line_maj) {
 			blocksection = (line[i] == 'B') ? 1 : 0;
 			continue;
 		}


