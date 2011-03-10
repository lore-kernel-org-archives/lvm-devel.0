From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 15:20:11 -0000
Subject: LVM2/man lvm.conf.5.in
Message-ID: <20110310152011.8388.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 15:20:10

Modified files:
	man            : lvm.conf.5.in 

Log message:
	Document pv_min_size in lvm.conf manpage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/man/lvm.conf.5.in	2010/11/09 12:34:43	1.16
+++ LVM2/man/lvm.conf.5.in	2011/03/10 15:20:10	1.17
@@ -171,6 +171,15 @@
 the limit set here, no further I/O is sent to that device for the remainder of
 the respective operation. Setting the parameter to 0 disables the counters
 altogether.
+.IP
+\fBpv_min_size\fP \(em
+Minimal size (in KB) of the block device which can be used as a PV.
+In clustered environment all nodes have to use the same value.
+Any value smaller then 512KB is ignored. An example to
+ignore devices smaller then 2MB (i.e. floppy drives):
+.IP
+pv_min_size = 2048
+.IP
 .TP
 \fBallocation\fP \(em Space allocation policies
 .IP


