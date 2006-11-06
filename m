From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 6 Nov 2006 14:11:40 -0000
Subject: LVM2 ./WHATS_NEW man/lvremove.8
Message-ID: <20061106141140.15998.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-11-06 14:11:40

Modified files:
	.              : WHATS_NEW 
	man            : lvremove.8 

Log message:
	Add note to lvremove man page: volumes must be inactive on
	all cluster nodes before being removed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.490&r2=1.491
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2006/11/04 03:34:09	1.490
+++ LVM2/WHATS_NEW	2006/11/06 14:11:39	1.491
@@ -1,5 +1,6 @@
 Version 2.02.14 - 
 ===================================
+  lvremove man page: volumes must be cluster inactive before being removed.
   Protect .cache manipulations with fcntl locking.
   Change .cache timestamp comparisons to use ctime.
   Fix mirror log LV writing to set all bits in whole LV.
--- LVM2/man/lvremove.8	2004/11/12 15:59:08	1.3
+++ LVM2/man/lvremove.8	2006/11/06 14:11:40	1.4
@@ -12,6 +12,10 @@
 Confirmation will be requested before deactivating any active logical
 volume prior to removal.  Logical volumes cannot be deactivated
 or removed while they are open (e.g. if they contain a mounted filesystem).
+.sp
+If the logical volume is clustered then it must be deactivated on all
+nodes in the cluster before it can be removed. A single lvchange command
+issued from one node can do this.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -28,7 +32,8 @@
 \	\fBlvremove vg00\fP
 .SH SEE ALSO
 .BR lvcreate (8), 
-.BR lvdisplay (8), 
+.BR lvdisplay (8),
+.BR lvchange (8),  
 .BR lvm (8), 
 .BR lvs (8),
 .BR lvscan (8),


