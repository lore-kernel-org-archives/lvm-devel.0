From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Sep 2011 09:48:52 -0000
Subject: LVM2 ./WHATS_NEW man/pvcreate.8.in
Message-ID: <20110907094852.27759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-07 09:48:51

Modified files:
	.              : WHATS_NEW 
	man            : pvcreate.8.in 

Log message:
	Fix typo

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2098&r2=1.2099
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2011/09/07 08:50:35	1.2098
+++ LVM2/WHATS_NEW	2011/09/07 09:48:49	1.2099
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix 'not not' typo in pvcreate man page.
   Improve man page style for fsadm, lvreduce, lvremove, lvrename, lvresize.
   Support break for vgchange and vgrefresh operation.
   Switch int to unsigned type for pvmetadatacopies for pv_create().
--- LVM2/man/pvcreate.8.in	2011/02/04 21:19:03	1.11
+++ LVM2/man/pvcreate.8.in	2011/09/07 09:48:50	1.12
@@ -125,7 +125,7 @@
 Ignore or un-ignore metadata areas on this physical volume.
 The default is "n".  This setting can be changed with \fBpvchange\fP.
 If metadata areas on a physical volume are ignored, LVM will
-not not store metadata in the metadata areas present on this Physical
+not store metadata in the metadata areas present on this Physical
 Volume.  Metadata areas cannot be created or extended after Logical
 Volumes have been allocated on the device. If you do not want to store
 metadata on this device, it is still wise always to allocate a metadata


