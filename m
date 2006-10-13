From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Oct 2006 13:22:44 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20061013132244.10623.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-13 13:22:44

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Propogate clustered flag in vgsplit and require resizeable flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.467&r2=1.468
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2006/10/12 18:20:45	1.467
+++ LVM2/WHATS_NEW	2006/10/13 13:22:44	1.468
@@ -1,5 +1,6 @@
 Version 2.02.12 -
 ===================================
+  Propogate clustered flag in vgsplit and require resizeable flag.
 
 Version 2.02.11 - 12th October 2006
 ===================================
--- LVM2/tools/vgsplit.c	2006/09/02 01:18:17	1.19
+++ LVM2/tools/vgsplit.c	2006/10/13 13:22:44	1.20
@@ -209,6 +209,12 @@
 		return ECMD_FAILED;
 	}
 
+	if (!(vg_from->status & RESIZEABLE_VG)) {
+		log_error("Volume group \"%s\" is not resizeable", vg_from->name);
+		unlock_vg(cmd, vg_name_from);
+		return ECMD_FAILED;
+	}
+
 	if (!(vg_from->status & LVM_WRITE)) {
 		log_error("Volume group \"%s\" is read-only", vg_from->name);
 		unlock_vg(cmd, vg_name_from);
@@ -248,6 +254,9 @@
 				vg_from->alloc, 0, NULL)))
 		goto error;
 
+	if (vg_from->status & CLUSTERED)
+		vg_to->status |= CLUSTERED;
+
 	/* Archive vg_from before changing it */
 	if (!archive(vg_from))
 		goto error;


