From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2007 11:29:55 -0000
Subject: LVM2/man lvdisplay.8
Message-ID: <20070724112955.14179.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-24 11:29:55

Modified files:
	man            : lvdisplay.8 

Log message:
	Trivial fix to lvdisplay man pg to recommend lvs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/man/lvdisplay.8	2007/07/24 10:58:01	1.5
+++ LVM2/man/lvdisplay.8	2007/07/24 11:29:55	1.6
@@ -12,7 +12,9 @@
 like size, read/write status, snapshot information etc.
 .P
 \fBlvs\fP (8) is an alternative that provides the same information 
-in the style of \fBps\fP (1).
+in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
+\fBlvdisplay\fP.
+
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP


