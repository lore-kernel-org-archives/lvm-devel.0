From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:17:17 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20110617141717.1056.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:17:17

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2017&r2=1.2018
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/WHATS_NEW	2011/06/17 14:14:19	1.2017
+++ LVM2/WHATS_NEW	2011/06/17 14:17:16	1.2018
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag.
   Add lv_activate_opts structure for activation (replacing activation flags).
   Fix a problem with inconsistent pre-commit metadata on MISSING_PV devices.
   Add proper udev library context initialization and finalization to liblvm.
--- LVM2/lib/mirror/mirrored.c	2011/06/17 14:14:20	1.88
+++ LVM2/lib/mirror/mirrored.c	2011/06/17 14:17:17	1.89
@@ -360,8 +360,7 @@
 	 * Use clustered mirror log for non-exclusive activation
 	 * in clustered VG.
 	 */
-	if ((!(seg->lv->status & ACTIVATE_EXCL) &&
-	      (vg_is_clustered(seg->lv->vg))))
+	if (!laopts->exclusive && vg_is_clustered(seg->lv->vg))
 		clustered = 1;
 
 	if (seg->log_lv) {


