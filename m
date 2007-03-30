From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Mar 2007 21:00:31 -0000
Subject: LVM2 man/lvm.8 man/Makefile.in tools/commands. ...
Message-ID: <20070330210031.18518.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-03-30 22:00:27

Modified files:
	man            : lvm.8 Makefile.in 
	tools          : commands.h Makefile.in 
	.              : WHATS_NEW 
Added files:
	man            : pvck.8 
	tools          : pvck.c 

Log message:
	Add stub for pvck, a command to check physical volume consistency.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvck.8.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvck.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.594&r2=1.595

/cvs/lvm2/LVM2/man/pvck.8,v  -->  standard output
revision 1.1
--- LVM2/man/pvck.8
+++ -	2007-03-30 22:00:30.440519000 +0100
@@ -0,0 +1,15 @@
+.TH PVCK 8 "LVM TOOLS" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+pvck \- check physical volume metadata
+.SH SYNOPSIS
+.B pvck
+[\-d/\-\-debug] [\-h/\-?/\-\-help] [\-v/\-\-verbose] [PhysicalVolume...]
+.SH DESCRIPTION
+pvck checks physical volume LVM metadata for consistency.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvcreate (8),
+.BR pvscan (8)
+.BR vgck (8)
--- LVM2/man/lvm.8	2006/10/08 12:01:12	1.9
+++ LVM2/man/lvm.8	2007/03/30 21:00:25	1.10
@@ -194,6 +194,7 @@
 .BR lvs (8),
 .BR lvscan (8),
 .BR pvchange (8),
+.BR pvck (8),
 .BR pvcreate (8),
 .BR pvdisplay (8),
 .BR pvmove (8),
--- LVM2/man/Makefile.in	2006/11/20 20:03:26	1.18
+++ LVM2/man/Makefile.in	2007/03/30 21:00:25	1.19
@@ -20,7 +20,7 @@
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmdiskscan.8 lvmdump.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
-	lvscan.8 pvchange.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
+	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 vgrename.8 \
/cvs/lvm2/LVM2/tools/pvck.c,v  -->  standard output
revision 1.1
--- LVM2/tools/pvck.c
+++ -	2007-03-30 22:00:31.021537000 +0100
@@ -0,0 +1,30 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "tools.h"
+
+static int _pvck_single(struct cmd_context * cmd,
+			struct volume_group * vg,
+			struct physical_volume * pv,
+			void *handle)
+{
+	return ECMD_PROCESSED;
+}
+
+int pvck(struct cmd_context *cmd, int argc, char **argv)
+{
+	/* FIXME: Correlate findings of each PV */
+	return process_each_pv(cmd, argc, argv, NULL, NULL, _pvck_single);
+}
--- LVM2/tools/commands.h	2007/01/23 13:08:34	1.94
+++ LVM2/tools/commands.h	2007/03/30 21:00:26	1.95
@@ -407,6 +407,15 @@
 
    physicalvolumesize_ARG, test_ARG)
 
+xx(pvck,
+   "Check the consistency of physical volume(s)",
+   "pvck "
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]" "\n"
+   "\tPhysicalVolume [PhysicalVolume...]\n" )
+
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
    "pvcreate " "\n"
--- LVM2/tools/Makefile.in	2007/01/11 17:12:27	1.78
+++ LVM2/tools/Makefile.in	2007/03/30 21:00:26	1.79
@@ -38,6 +38,7 @@
 	lvscan.c \
 	polldaemon.c \
 	pvchange.c \
+	pvck.c \
 	pvcreate.c \
 	pvdisplay.c \
 	pvmove.c \
--- LVM2/WHATS_NEW	2007/03/29 13:59:32	1.594
+++ LVM2/WHATS_NEW	2007/03/30 21:00:26	1.595
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add pvck command stub.
   Update lists of attribute characters in man pages.
   Change cling alloc policy attribute character from 'C' to l'.
   Fix creation and conversion of mirrors with tags.


