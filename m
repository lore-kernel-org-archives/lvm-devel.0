From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Nov 2010 14:10:47 -0000
Subject: LVM2 ./WHATS_NEW man/fsadm.8.in
Message-ID: <20101101141047.14026.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-01 14:10:47

Modified files:
	.              : WHATS_NEW 
	man            : fsadm.8.in 

Log message:
	Add DIAGNOSTICS section to fsadm man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1784&r2=1.1785
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2010/11/01 14:08:51	1.1784
+++ LVM2/WHATS_NEW	2010/11/01 14:10:46	1.1785
@@ -1,5 +1,6 @@
 Version 2.02.76 - 
 ===================================
+  Add DIAGNOSTICS section to fsadm man page.
   Modify fsadm to return different status code for check of mounted filesystem.
   Update VG metadata only once in vgchange when making multiple changes.
   Allow independent vgchange arguments to be used together.
--- LVM2/man/fsadm.8.in	2010/01/07 09:42:51	1.3
+++ LVM2/man/fsadm.8.in	2010/11/01 14:10:46	1.4
@@ -37,6 +37,13 @@
 or an absolute size using a suffix (in powers of 1024).
 If new_size is not supplied, the whole device is used.
 
+.SH "DIAGNOSTICS"
+On successful completion, the status code is 0.
+A status code of 2 indicates the operation was interrupted by the user.
+A status code of 3 indicates the requested check operation could not be performed
+because the filesystem is mounted and does not support an online fsck.
+A status code of 1 is used for other failures.
+
 .SH "EXAMPLES"
 "fsadm \-e \-y resize /dev/vg/test 1000M" tries to resize the filesystem
 on logical volume /dev/vg/test. If /dev/vg/test contains ext2/ext3/ext4


