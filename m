From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2007 10:58:01 -0000
Subject: LVM2 man/lvdisplay.8 ./WHATS_NEW
Message-ID: <20070724105801.22255.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-24 10:58:01

Modified files:
	man            : lvdisplay.8 
	.              : WHATS_NEW 

Log message:
	Trivial fix to lvdisplay man pg to correct volume size units

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.668&r2=1.669

--- LVM2/man/lvdisplay.8	2005/12/02 20:35:06	1.4
+++ LVM2/man/lvdisplay.8	2007/07/24 10:58:01	1.5
@@ -29,7 +29,7 @@
 * logical volume status
 * internal logical volume number
 * open count of logical volume
-* logical volume size in kilobytes
+* logical volume size in sectors
 * current logical extents associated to logical volume
 * allocated logical extents of logical volume
 * allocation policy of logical volume
--- LVM2/WHATS_NEW	2007/07/23 17:27:54	1.668
+++ LVM2/WHATS_NEW	2007/07/24 10:58:01	1.669
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Trivial fix to lvdisplay man page.
   Add vg_lock_and_read() external library function.
   Fix loading of persistent cache if cache_dir is used. (2.02.23)
   Eliminate uses of strdup+basename.  Use last_path_component instead.


