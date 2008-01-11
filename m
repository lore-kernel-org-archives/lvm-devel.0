From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jan 2008 20:24:25 -0000
Subject: LVM2/man lvm.8
Message-ID: <20080111202425.7848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-11 20:24:25

Modified files:
	man            : lvm.8 

Log message:
	Fixup lvm man pg

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/man/lvm.8	2008/01/11 19:24:25	1.11
+++ LVM2/man/lvm.8	2008/01/11 20:24:25	1.12
@@ -67,8 +67,6 @@
 .TP
 \fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
 .TP
-\fBpvresize\fP \(em Resize a disk or partition in use by LVM2.
-.TP
 \fBpvs\fP \(em Report information about physical volumes.
 .TP
 \fBpvscan\fP \(em Scan all disks for physical volumes.
@@ -137,7 +135,7 @@
 .TP
 \fBlvscan\fP \(em Scan (all disks) for logical volumes.
 .TP
-The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata, pvresize.
+The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata.
 .SH OPTIONS
 The following options are available for many of the commands. 
 They are implemented generically and documented here rather 


