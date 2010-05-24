From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 May 2010 09:03:42 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20100524090342.15596.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-24 09:03:39

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Replicator: update activate code for vgchange
	
	Activate only the first replicator-dev LV, that activates all other
	related LVs from Replicator. In case of error during this activation,
	it will not retry again for other heads (less confusing error log).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1593&r2=1.1594
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2010/05/24 09:01:05	1.1593
+++ LVM2/WHATS_NEW	2010/05/24 09:03:39	1.1594
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Activate only first head of Replicator for vgchange -ay.
   Add Replicators' LVs to dtree for activation.
   Avoid print activation message if there is a missing VG (Replicator).
   Fixed scripts/relpath.awk to work in mawk
--- LVM2/tools/vgchange.c	2010/05/24 08:59:30	1.103
+++ LVM2/tools/vgchange.c	2010/05/24 09:03:39	1.104
@@ -104,6 +104,11 @@
 		if ((lv->status & MIRROR_IMAGE) || (lv->status & MIRROR_LOG))
 			continue;
 
+		/* Only request activation of the first replicator-dev LV */
+		/* Avoids retry with all heads in case of failure */
+		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
+			continue;
+
 		/* Can't deactivate a pvmove LV */
 		/* FIXME There needs to be a controlled way of doing this */
 		if (((activate == CHANGE_AN) || (activate == CHANGE_ALN)) &&


