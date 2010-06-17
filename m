From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2010 12:14:44 -0000
Subject: LVM2 ./WHATS_NEW man/Makefile.in man/dmeventd.8.in
Message-ID: <20100617121444.31792.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-17 12:14:44

Modified files:
	.              : WHATS_NEW 
	man            : Makefile.in 
Added files:
	man            : dmeventd.8.in 

Log message:
	Add man page for dmeventd
	(inspired by patch from Danny Rawlins, monster.romster at gmail dot com)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1614&r2=1.1615
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmeventd.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2010/06/17 11:25:43	1.1614
+++ LVM2/WHATS_NEW	2010/06/17 12:14:43	1.1615
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Add dmeventd man page.
   Update lvresize/extend/reduce manpages with --nofsck, --resizefs options.
   Fix lvm2cmd example in documentation.
   Allow use of lvm2app and lvm2cmd headers in C++ mode.
/cvs/lvm2/LVM2/man/dmeventd.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/dmeventd.8.in
+++ -	2010-06-17 12:14:44.651455000 +0000
@@ -0,0 +1,42 @@
+.TH DMEVENTD 8 "DM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.SH NAME
+dmeventd \- Device-mapper event daemon
+.SH SYNOPSIS
+.B dmeventd
+[\-V]
+[\-d]
+[\-f]
+[\-h]
+[\-?]
+.SH DESCRIPTION
+dmeventd is the event monitoring daemon for device-mapper devices.
+Plugins are supported.
+
+.br
+LVM plugins:
+.TP
+Snapshot: monitor the filling of snapshot and emits a warning through 
+syslog, when the use of snapshot exceedes 80%.
+The warning is repeated when 85%, 90% and 95% of the snapshot are filled.
+(see \fBlvm.conf\fP)
+.TP
+Mirror: attempts to recover from failures (see \fBlvm.conf\fP).
+.SH OPTIONS
+.TP
+.I \-V
+Show version of dmeventd.
+.TP
+.I \-d
+Repeat from 1 to 3 times (-d, -dd, -ddd) to increase the detail of
+debug messages sent to syslog.
+Each extra d adds more debugging information.
+.TP
+.I \-f
+Don't fork, run in the foreground.
+.TP
+.I \-h, \-?
+Show help information.
+
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvm.conf (5)
--- LVM2/man/Makefile.in	2010/05/20 13:47:22	1.37
+++ LVM2/man/Makefile.in	2010/06/17 12:14:43	1.38
@@ -22,6 +22,12 @@
 FSADMMAN =
 endif
 
+ifeq ("@DMEVENTD@", "yes")
+DMEVENTDMAN = dmeventd.8
+else
+DMEVENTDMAN =
+endif
+
 MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmdiskscan.8 lvmdump.8 \
@@ -30,7 +36,7 @@
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(DMEVENTDMAN)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -45,8 +51,8 @@
 MAN5DIR=$(mandir)/man5
 MAN8DIR=$(mandir)/man8
 
-CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
-DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8
+CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(DMEVENTDMAN) $(MAN8DM)
+DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8
 
 include $(top_builddir)/make.tmpl
 


