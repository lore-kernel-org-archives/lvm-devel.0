From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Jan 2008 00:18:37 -0000
Subject: LVM2 ./WHATS_NEW tools/pvcreate.c
Message-ID: <20080109001837.5131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-01-09 00:18:37

Modified files:
	.              : WHATS_NEW 
	tools          : pvcreate.c 

Log message:
	Prevent pvcreate from overwriting MDA-less PVs belonging to active VGs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.752&r2=1.753
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2008/01/07 20:42:56	1.752
+++ LVM2/WHATS_NEW	2008/01/09 00:18:36	1.753
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Prevent pvcreate from overwriting MDA-less PVs belonging to active VGs.
   Fix a segfault if using pvs with --all argument. (2.02.29)
   Update --uuid argument description in man pages.
   Fix vgreduce PV list processing not to process every PV in the VG. (2.02.29)
--- LVM2/tools/pvcreate.c	2007/11/22 01:25:06	1.58
+++ LVM2/tools/pvcreate.c	2008/01/09 00:18:36	1.59
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "metadata.h"
 
 struct pvcreate_params {
 	int zero;
@@ -43,6 +44,17 @@
 	/* FIXME Use partial mode here? */
 	pv = pv_read(cmd, name, NULL, NULL, 0);
 
+	/*
+         * If a PV has no MDAs it may appear to be an orphan until the
+         * metadata is read off another PV in the same VG.  Detecting
+         * this means checking every VG by scanning every PV on the
+         * system.
+	 */
+	if (pv && is_orphan(pv)) {
+		(void) get_vgs(cmd, 1);
+		pv = pv_read(cmd, name, NULL, NULL, 0);
+	}
+
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */
 	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG) != 2) {


