From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Nov 2006 17:44:15 -0000
Subject: LVM2/man lvmdump.8
Message-ID: <20061123174415.15168.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-23 17:44:15

Modified files:
	man            : lvmdump.8 

Log message:
	mention new env vars on man page

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdump.8.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/man/lvmdump.8	2006/11/16 16:44:48	1.1
+++ LVM2/man/lvmdump.8	2006/11/23 17:44:15	1.2
@@ -37,4 +37,14 @@
 By default, lvmdump will produce a single compressed tarball containing all the information. Using this option, it can be instructed to only produce the raw dump tree, rooted in \fBdirectory\fP.
 .TP
 \fB\-c\fR \(em if clvmd is running, gather cluster data as well
+.SH ENVIRONMENT VARIABLES
+.TP
+\fBLVM_BINARY\fP 
+The LVM2 binary to use.
+Defaults to "lvm".
+Sometimes you might need to set this to "/sbin/lvm.static", for example.
+.TP
+\fBDMSETUP_BINARY\fP 
+The dmsetup binary to use.
+Defaults to "dmsetup".
 .PP


