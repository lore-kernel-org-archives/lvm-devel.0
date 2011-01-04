From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 4 Jan 2011 21:33:11 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110104213311.25559.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-04 21:33:08

Modified files:
	.              : WHATS_NEW 

Log message:
	Change to correct cmirrord return code is user visible - update WHATS_NEW
	file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1856&r2=1.1857

--- LVM2/WHATS_NEW	2010/12/23 14:23:30	1.1856
+++ LVM2/WHATS_NEW	2011/01/04 21:33:06	1.1857
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Correct return code of cmirrord when issuing 'start' when already running.
   Fix wrongly paired unlocking of global lock in pvchange. (2.02.66)
   Add backtraces for backup and backup_remove fail paths.
   Detect errors from dm_task_set calls in _get_device_info (dmeventd).


