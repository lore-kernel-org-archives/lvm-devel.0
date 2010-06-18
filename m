From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Jun 2010 10:19:31 -0000
Subject: LVM2 ./WHATS_NEW man/Makefile.in man/lvmconf.8 ...
Message-ID: <20100618101931.14117.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-18 10:19:30

Modified files:
	.              : WHATS_NEW 
	man            : Makefile.in 
Added files:
	man            : lvmconf.8.in lvmsadc.8.in lvmsar.8.in 

Log message:
	Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1617&r2=1.1618
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmconf.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmsadc.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmsar.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2010/06/17 13:15:51	1.1617
+++ LVM2/WHATS_NEW	2010/06/18 10:19:29	1.1618
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.
   Fix exit code when requesting help using documented -o help option.
   Do not use internal DLM lock definitions in generic LVM2 clvmd code.
   Add dmeventd man page.
/cvs/lvm2/LVM2/man/lvmconf.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmconf.8.in
+++ -	2010-06-18 10:19:31.055236000 +0000
@@ -0,0 +1,41 @@
+.TH "LVMCONF" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.SH "NAME"
+.B lvmconf
+\- LVM configuration modifier
+
+.SH "SYNOPSIS"
+.B lvmconf
+[\-\-enable-cluster]
+[\-\-disable-cluster]
+[\-\-lockinglibdir <dir>]
+[\-\-lockinglib <lib>]
+[\-\-file <configfile>]
+
+.SH "DESCRIPTION"
+.B lvmconf
+is a helper tool to modify cluster locking in \fBlvm.conf\fP(5).
+
+.SH "OPTIONS"
+.TP
+.BR \-\-disable-cluster
+Set the default non-cluster \fBlocking_type\fR.
+.TP
+.BR \-\-enable-cluster
+Set a cluster-wide \fBlocking_type\fR available on the system.
+.TP
+.BR \-\-lockinglibdir " " \fI<dir>\fR
+Set \fBlocking_dir\fR directory where LVM2 places its files locks.
+.TP
+.BR \-\-lockinglib " " \fI<lib>\fR
+Set external \fBlocking_library\fR locking library to load.
+.TP
+.BR \-\-file " " \fI<configfile>\fR
+Use non-default \fBconfigfile\fR instead of \fB#DEFAULT_SYS_DIR#/lvm.conf\fR.
+
+.SH FILES
+.I #DEFAULT_SYS_DIR#/lvm.conf
+
+.SH "SEE ALSO"
+.BR lvm (8),
+.BR lvm.conf (5)
/cvs/lvm2/LVM2/man/lvmsadc.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmsadc.8.in
+++ -	2010-06-18 10:19:31.166237000 +0000
@@ -0,0 +1,14 @@
+.TH "LVMSADC" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.SH "NAME"
+lvmsadc \- LVM system activity data collector
+
+.SH "SYNOPSIS"
+.B lvmsadc
+
+.SH "DESCRIPTION"
+.B lvmsadc
+is not currently supported under LVM2.
+
+.SH "SEE ALSO"
+.BR lvm (8)
/cvs/lvm2/LVM2/man/lvmsar.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmsar.8.in
+++ -	2010-06-18 10:19:31.267614000 +0000
@@ -0,0 +1,14 @@
+.TH "LVMSAR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.SH "NAME"
+lvmsar \- LVM system activity reporter
+
+.SH "SYNOPSIS"
+.B lvmsar
+
+.SH "DESCRIPTION"
+.B lvmsar
+is not currently supported under LVM2.
+
+.SH "SEE ALSO"
+.BR lvm (8)
--- LVM2/man/Makefile.in	2010/06/17 12:14:43	1.38
+++ LVM2/man/Makefile.in	2010/06/18 10:19:30	1.39
@@ -30,7 +30,7 @@
 
 MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
-	lvmchange.8 lvmdiskscan.8 lvmdump.8 \
+	lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
 	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \


