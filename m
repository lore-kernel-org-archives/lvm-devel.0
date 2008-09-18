From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Sep 2008 18:51:59 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20080918185159.25927.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-18 18:51:58

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Prevent resizing an LV while lvconvert is using it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.952&r2=1.953
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/WHATS_NEW	2008/09/16 18:05:11	1.952
+++ LVM2/WHATS_NEW	2008/09/18 18:51:58	1.953
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Prevent resizing an LV while lvconvert is using it.
   Avoid repeatedly wiping cache while VG_GLOBAL is held in vgscan & pvscan.
   Fix pvresize to not allow resize if PV has two metadata areas.
   Fix setting of volume limit count if converting to lvm1 format.
--- LVM2/tools/lvresize.c	2008/04/29 15:25:28	1.97
+++ LVM2/tools/lvresize.c	2008/09/18 18:51:58	1.98
@@ -308,6 +308,11 @@
 		return ECMD_FAILED;
 	}
 
+	if (lv->status & CONVERTING) {
+		log_error("Can't resize %s while lvconvert in progress", lv->name);
+		return ECMD_FAILED;
+	}
+
 	alloc = arg_uint_value(cmd, alloc_ARG, lv->alloc);
 
 	if (lp->size) {


