From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Oct 2011 09:53:17 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in
Message-ID: <20111021095317.22960.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-21 09:53:16

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in 

Log message:
	Make units for chunksize more obvious

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2164&r2=1.2165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2011/10/19 16:49:13	1.2164
+++ LVM2/WHATS_NEW	2011/10/21 09:53:16	1.2165
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Improve lvcreate man documentation of the chunksize option.
   Improve man page style for lvcreate.
   Avoid recursive calls to dmeventd in its LVM plugins.
   Log dev name now returned to kernel for registering during cmirror CTR.
--- LVM2/man/lvcreate.8.in	2011/10/19 16:49:14	1.23
+++ LVM2/man/lvcreate.8.in	2011/10/21 09:53:16	1.24
@@ -129,7 +129,9 @@
 on one node and \fB-a\fIly\fR will activate only on the local node.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize
-Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
+Power of 2 chunk size in sector units (512b).
+For snapshot logical volume the value must be between 8 (4KB) and 1024 (512KB)
+and the default value is 8.
 .TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Sets or resets the contiguous allocation policy for


