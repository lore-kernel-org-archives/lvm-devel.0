From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 30 Mar 2007 14:10:05 -0400
Subject: [PATCH] add pvck command stub
Message-ID: <1175278205.19799.4.camel@linux-cxyg.rtp.netapp.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add stub for pvck, a command to check physical volume consistency.

Index: LVM2/man/pvck.8
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ LVM2/man/pvck.8	2007-03-30 12:30:58.000000000 -0400
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
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h	2007-03-30 12:04:38.000000000 -0400
+++ LVM2/tools/commands.h	2007-03-30 12:41:19.000000000 -0400
@@ -407,6 +407,15 @@ xx(pvresize,
 
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
Index: LVM2/tools/pvck.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ LVM2/tools/pvck.c	2007-03-30 12:31:14.000000000 -0400
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
Index: LVM2/man/lvm.8
===================================================================
--- LVM2.orig/man/lvm.8	2006-12-14 00:19:07.000000000 -0500
+++ LVM2/man/lvm.8	2007-03-30 12:32:15.000000000 -0400
@@ -194,6 +194,7 @@ All tools return a status code of zero o
 .BR lvs (8),
 .BR lvscan (8),
 .BR pvchange (8),
+.BR pvck (8),
 .BR pvcreate (8),
 .BR pvdisplay (8),
 .BR pvmove (8),
Index: LVM2/tools/Makefile.in
===================================================================
--- LVM2.orig/tools/Makefile.in	2007-02-22 14:03:27.000000000 -0500
+++ LVM2/tools/Makefile.in	2007-03-30 12:33:40.000000000 -0400
@@ -38,6 +38,7 @@ SOURCES =\
 	lvscan.c \
 	polldaemon.c \
 	pvchange.c \
+	pvck.c \
 	pvcreate.c \
 	pvdisplay.c \
 	pvmove.c \
Index: LVM2/man/Makefile.in
===================================================================
--- LVM2.orig/man/Makefile.in	2006-12-14 00:19:07.000000000 -0500
+++ LVM2/man/Makefile.in	2007-03-30 12:34:40.000000000 -0400
@@ -20,7 +20,7 @@ MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmdiskscan.8 lvmdump.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
-	lvscan.8 pvchange.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
+	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 vgrename.8 \
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-03-30 12:04:50.000000000 -0400
+++ LVM2/WHATS_NEW	2007-03-30 12:45:36.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add pvck command stub.
   Update lists of attribute characters in man pages.
   Change cling alloc policy attribute character from 'C' to l'.
   Fix creation and conversion of mirrors with tags.



