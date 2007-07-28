From: meyering@sourceware.org <meyering@sourceware.org>
Date: 28 Jul 2007 15:20:37 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-file.c
Message-ID: <20070728152037.21872.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-28 15:20:36

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-file.c 

Log message:
	Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.673&r2=1.674
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2007/07/28 12:26:21	1.673
+++ LVM2/WHATS_NEW	2007/07/28 15:20:36	1.674
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
   Remove create_dir function; use now-equivalent dm_create_dir instead
   Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
   Fix clvmd if compiled with gulm support. (2.02.26)
--- LVM2/lib/misc/lvm-file.c	2007/07/28 12:26:21	1.22
+++ LVM2/lib/misc/lvm-file.c	2007/07/28 15:20:36	1.23
@@ -245,6 +245,7 @@
 
 	if (fcntl(lockfd, F_SETLKW, &lock)) {
 		log_sys_error("fcntl", file);
+		close(lockfd);
 		return -1;
 	}
 


