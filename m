From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Aug 2007 20:29:08 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20070801202908.2611.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2007-08-01 20:29:07

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	lib/activate/activate.c:_lv_activate tries to monitor a device
	regardless of whether it was successfully activated.  Now fixed
	to only monitor if it was successfully activated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.674&r2=1.675
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2007/07/28 15:20:36	1.674
+++ LVM2/WHATS_NEW	2007/08/01 20:29:07	1.675
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Don't try to monitor devices which we failed to create.
   Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
   Remove create_dir function; use now-equivalent dm_create_dir instead
   Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
--- LVM2/lib/activate/activate.c	2007/07/02 11:17:21	1.124
+++ LVM2/lib/activate/activate.c	2007/08/01 20:29:07	1.125
@@ -963,7 +963,7 @@
 	memlock_dec();
 	fs_unlock();
 
-	if (!monitor_dev_for_events(cmd, lv, 1))
+	if (r && !monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
 	return r;


