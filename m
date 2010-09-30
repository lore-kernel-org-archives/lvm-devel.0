From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Sep 2010 11:40:15 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/lvm2 ...
Message-ID: <20100930114015.19637.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-09-30 11:40:14

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 

Log message:
	Fix leaked pool report
	
	Swap pool destruction order in dmeventd_lvm2_exit() to fix leak report.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1739&r2=1.1740
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/09/30 11:32:40	1.1739
+++ LVM2/WHATS_NEW	2010/09/30 11:40:14	1.1740
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Swap pool destruction order in dmeventd_lvm2_exit() to fix leak report.
   Read whole /proc/self/maps file before working with maps entries.
   Speed up unquoting of quoted double quotes and backslashes.
   Speed up CRC32 calculations by using a larger lookup table.
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/07/09 15:34:41	1.4
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/09/30 11:40:14	1.5
@@ -131,10 +131,10 @@
 
 	if (!--_register_count) {
 		lvm2_run(_lvm_handle, "_memlock_dec");
-		lvm2_exit(_lvm_handle);
-		_lvm_handle = NULL;
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
+		lvm2_exit(_lvm_handle);
+		_lvm_handle = NULL;
 	}
 
 	pthread_mutex_unlock(&_register_mutex);


